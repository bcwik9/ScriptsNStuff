# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

##############
echo ""
echo "Everyone here is walking their own path. And there are two roads you can take..."
echo "The first road leads right out that door, because you think you've heard it all."
echo "The other road begins right here, right now. Built by us, travelled by you."
echo "A wise man once said: The best way to predict the future is to invent it."
echo "So now, ladies and gentlemen..."
echo "Welcome to the Future"
echo ""
echo ""
echo "If you're in it to win it you just have to stick with it"
echo "through the good times and through the bad times"
echo ""
##############

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

alias ls='ls --color=auto -la'
export PS1='[\[\033[31;1m\u\[\033[0m@\[\033[34;1m\h\[\033[0m \[\033[32m\w\[\033[0m]>> '
