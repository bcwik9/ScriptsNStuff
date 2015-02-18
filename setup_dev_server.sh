#!/bin/bash

exit_error()
{
    echo >&2 'WARNING: ABORTING, ERROR OCCURRED'
    exit 1
}

trap 'exit_error' 0

set -e # fail on error


echo "Updating and Upgrading"
sudo apt-get update
sudo apt-get upgrade -y

echo "Installing packages"
export package_list='git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties bundler emacs libgdbm-dev libncurses5-dev automake libtool bison libffi-dev'
sudo apt-get install -y $package_list

echo "Installing RVM"
sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
sudo chmod 777 /home/ubuntu/.gnupg/
sudo curl -sSL https://get.rvm.io | bash -s stable
sudo echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc # add to bash

echo "Installing Ruby"
sudo -i source ~/.rvm/scripts/rvm && rvm install 2.1.3
sudo -i source ~/.rvm/scripts/rvm && rvm use 2.1.3 --default # set default ruby
