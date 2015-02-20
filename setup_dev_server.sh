#!/bin/bash
# Run using: sh setup_dev_server.sh

exit_error()
{
    echo >&2 'WARNING: ABORTING, ERROR OCCURRED'
    exit 1
}

# call exit_error when there's a problem
trap 'exit_error' 0

set -e # fail on error


echo "Updating and Upgrading"
sudo apt-get update
sudo apt-get upgrade -y

echo "Installing packages"
export package_list='git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties bundler emacs libgdbm-dev libncurses5-dev automake libtool bison libffi-dev'
sudo apt-get install -y $package_list

echo "Installing RVM"
sudo curl -sSL https://github.com/wayneeseguin/rvm/tarball/stable -o rvm-stable.tar.gz
sudo mkdir rvm && cd rvm
sudo tar --strip-components=1 -xzf ../rvm-stable.tar.gz
sudo ./install --auto-dotfiles
export rmv_cmd="source /usr/local/rvm/scripts/rvm"
$rvm_cmd
sudo echo $rvm_cmd >> ~/.bashrc # add to bash
# clean up RVM install files
sudo rm -rf ../rvm/
sudo rm -f ../rvm-stable.tar.gz

echo "Installing Ruby"
sudo rvm install 2.1.3
sudo use 2.1.3 --default # set default ruby

echo "*** ALL DONE ***"
trap - 0 # clear trap so script doesn't fail at the end
exit 0
