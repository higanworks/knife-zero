FROM ubuntu:15.04
MAINTAINER sawanoboriyu@higanworks.com

RUN apt-get -y update
RUN apt-get -y install sudo git build-essential ruby2.1 ruby2.1-dev openssh-server wget vim net-tools


RUN mkdir /var/run/sshd
RUN useradd -p $(perl -e'print crypt("docker", "docker")') -m docker
RUN echo '%docker ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/docker
CMD ["/bin/true"]
