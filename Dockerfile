FROM higanworks/knife-zero-edgebase
MAINTAINER sawanoboriyu@higanworks.com

# ADD .git/index /index

WORKDIR /home
# RUN wget https://codeload.github.com/chef/chef-config/legacy.tar.gz/master -O chef-config.tgz
# RUN tar xvzf chef-config.tgz && mv chef-chef-* chef-config
RUN wget https://codeload.github.com/chef/chef/legacy.tar.gz/master -O chef.tgz
RUN tar xvzf chef.tgz && mv chef-chef-* chef
RUN wget https://codeload.github.com/chef/chef-dk/legacy.tar.gz/master -O chef.tgz
RUN tar xvzf chef.tgz && mv chef-chef-dk* chef-dk

## Helper
RUN wget https://codeload.github.com/higanworks/knife-helper/legacy.tar.gz/raise_if_none_zero_exit -O knife-helper.tgz
RUN tar xvzf knife-helper.tgz && mv higanworks-knife-helper-* knife-helper

WORKDIR /home/chef/chef-config
RUN touch CONTRIBUTING.md
RUN gem build chef-config.gemspec
RUN gem install -V -b chef-config*.gem --no-ri --no-rdoc

WORKDIR /home/chef
RUN gem build chef.gemspec
RUN gem install -V -b chef*.gem --no-ri --no-rdoc

WORKDIR /home/chef-dk
RUN gem build chef-dk.gemspec
RUN gem install -V -b chef-dk*.gem --no-ri --no-rdoc

ADD . /home/knife-zero/
ADD integration_test/chef-repo /chef-repo/
ADD integration_test/fixtures /chef-repo/fixtures

WORKDIR /home/knife-zero
RUN gem build knife-zero.gemspec
RUN gem install -V -l knife-zero-*.gem --no-ri --no-rdoc

WORKDIR /home/knife-helper
RUN gem build knife-helper.gemspec
RUN gem install -V -b knife-helper-*.gem --no-ri --no-rdoc

WORKDIR /chef-repo

CMD ["sh", "run.sh"]
