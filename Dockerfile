FROM higanworks/knife-zero-edgebase
MAINTAINER sawanoboriyu@higanworks.com

ADD .git/index /index

WORKDIR /home
RUN wget https://codeload.github.com/chef/chef/legacy.tar.gz/master
RUN tar xvzf master && mv chef-chef-* chef

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
