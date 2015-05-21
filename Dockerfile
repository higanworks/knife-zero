FROM higanworks/knife-zero-edgebase
MAINTAINER sawanoboriyu@higanworks.com

ADD .git/index /index

WORKDIR /home
RUN wget https://codeload.github.com/chef/chef-config/legacy.tar.gz/master -O chef-config.tgz
RUN tar xvzf chef-config.tgz && mv chef-chef-* chef-config
RUN wget https://codeload.github.com/chef/chef/legacy.tar.gz/master -O chef.tgz
RUN tar xvzf chef.tgz && mv chef-chef-* chef

WORKDIR /home/chef-config
RUN touch CONTRIBUTING.md
RUN sed 's/0.1.0.dev.0/12.4.0.dev.0/' lib/chef-config/version.rb -i
RUN gem build chef-config.gemspec
RUN gem install -V -b chef-config*.gem --no-ri --no-rdoc

WORKDIR /home/chef
RUN gem build chef.gemspec
RUN gem install -V -b chef*.gem --no-ri --no-rdoc

ADD . /home/knife-zero/
ADD integration_test/chef-repo /chef-repo/

WORKDIR /home/knife-zero

RUN gem build knife-zero.gemspec
RUN gem install -V -l knife-zero-*.gem
RUN gem install -V knife-helper

WORKDIR /chef-repo

CMD ["sh", "run.sh"]
