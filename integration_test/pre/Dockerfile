FROM ruby:2.7
LABEL MAINTAINER=sawanoboriyu@higanworks.com

RUN echo "deb-src http://ftp.jp.debian.org/debian/ buster main" >> /etc/apt/sources.list
RUN echo "deb-src http://security.debian.org/ buster/updates main" >> /etc/apt/sources.list

RUN apt-get -y update \
&& apt-get -y install sudo git build-essential openssh-server wget vim net-tools \
&& rm -rf /var/lib/apt/lists/*

RUN mkdir /run/sshd
RUN useradd -p $(perl -e'print crypt("docker", "docker")') -m docker
RUN echo '%docker ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/docker
CMD ["/bin/true"]
