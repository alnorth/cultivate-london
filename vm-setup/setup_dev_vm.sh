#!/bin/bash

# Don't prompt for password on MySQL installation
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -q -y upgrade

if [ ! -f ~/runonce ]
then
  apt-get -q -y install --no-install-recommends mysql-server-5.5 mysql-client-5.5 nodejs curl git git-core build-essential openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev libgdbm-dev ncurses-dev automake libtool bison subversion pkg-config libffi-dev libmysqlclient-dev

  su -c "/vagrant/vm-setup/rails.sh" vagrant

  touch ~/runonce
fi
