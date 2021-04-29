FROM higanworks/knife-zero-edgebase
LABEL MAINTAINER=sawanoboriyu@higanworks.com

# ADD .git/index /index

WORKDIR /home
# RUN wget https://codeload.github.com/chef/chef-config/legacy.tar.gz/master -O chef-config.tgz
# RUN tar xvzf chef-config.tgz && mv chef-chef-* chef-config
RUN wget -nv https://codeload.github.com/chef/chef/legacy.tar.gz/master -O chef.tgz
RUN tar xvzf chef.tgz && mv chef-chef-* chef
RUN wget -nv https://codeload.github.com/chef/chef-cli/legacy.tar.gz/master -O chef-cli.tgz
RUN tar xvzf chef-cli.tgz && mv chef-chef-cli* chef-cli
# RUN wget -nv https://codeload.github.com/chef/chef-dk/legacy.tar.gz/master -O chef.tgz
# RUN tar xvzf chef.tgz && mv chef-boneyard-chef-dk* chef-dk
# use ohai latest
RUN wget -nv https://codeload.github.com/chef/ohai/legacy.tar.gz/master -O ohai.tgz
RUN tar xvzf ohai.tgz && mv chef-ohai-* ohai

WORKDIR /home/ohai
RUN gem build ohai.gemspec
RUN gem install -V -b ohai*.gem --no-document

WORKDIR /home/chef/chef-utils
RUN touch CONTRIBUTING.md
RUN gem build chef-utils.gemspec
RUN gem install -V -b chef-utils*.gem --no-document

WORKDIR /home/chef/chef-config
RUN touch CONTRIBUTING.md
RUN gem build chef-config.gemspec
RUN gem install -V -b chef-config*.gem --no-document

WORKDIR /home/chef
RUN gem build chef.gemspec
RUN gem install -V -b chef*.gem --no-document

WORKDIR /home/chef/knife
RUN touch CONTRIBUTING.md
RUN gem build knife.gemspec
RUN gem install -V -b knife*.gem --no-document

WORKDIR /home/chef/knife
RUN touch CONTRIBUTING.md
RUN gem build knife.gemspec
RUN gem install -V -b knife*.gem --no-document

# WORKDIR /home/chef-dk
# RUN gem build chef-dk
# RUN gem install -V -b chef-dk*.gem --no-document

WORKDIR /home/chef-cli
RUN gem build chef-cli
RUN gem install -V -b chef-cli*.gem --no-document

ADD . /home/knife-zero/
ADD integration_test/chef-repo /chef-repo/
ADD integration_test/fixtures /chef-repo/fixtures

WORKDIR /home/knife-zero

RUN gem build knife-zero.gemspec
RUN gem install -V -l knife-zero-*.gem --no-document
RUN gem install -V knife-helper --no-document
# RUN gem install -V chef-cli --no-document

WORKDIR /chef-repo

CMD ["sh", "run.sh"]
