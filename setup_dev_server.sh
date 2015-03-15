#!/bin/bash
# Designed for t2.micro AWS Ubuntu EC2 instance
# Run using: sh setup_dev_server.sh
# or sudo -i wget --no-check-certificate https://raw.githubusercontent.com/bcwik9/ScriptsNStuff/master/setup_dev_server.sh && sudo -i bash setup_dev_server.sh
# You can pass in params that will be installed via 'apt-get install'

exit_error()
{
    echo >&2 'WARNING: ABORTING, ERROR OCCURRED'
    exit 1
}

# call exit_error when there's a problem
trap 'exit_error' 0

set -e # fail on error


echo "*** Updating and Upgrading ***"
sudo apt-get update
# prevent any interactive menus from popping up and requiring user input
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

echo "*** Installing packages ***"
export package_list='curl libcurl4-openssl-dev'
sudo apt-get install -y $package_list $@

echo "*** Running RVM/Ruby/Rails install script ***"
wget --no-check-certificate https://raw.githubusercontent.com/bcwik9/railsready/master/railsready.sh && bash railsready.sh

echo "*** Installing nginx ***"
# First do swap
sudo dd if=/dev/zero of=/swap bs=1M count=1024
sudo mkswap /swap
sudo swapon /swap
# Now install
bash --login /usr/local/rvm/bin/rvmsudo /usr/local/rvm/gems/ruby-2.1.5/bin/passenger-install-nginx-module --auto-download --auto

echo "*** ALL DONE ***"
trap - 0 # clear trap so script doesn't fail at the end
exit 0
