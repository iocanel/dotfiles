#!/bin/bash

for i in `ls -a .`;do
	if [ "." == "$i" ]; then
		echo "Ignoring '.'"
	elif [ ".." == "$i" ]; then
		echo "Ignoring '..'"
	elif [ ".git" == "$i" ]; then
		echo "Ignoring '.git'"
	elif [ ".local" == "$i" ]; then
		echo "Ignoring '.local'"
		cp ~/.local/share/systemd/user/* `pwd`/.local/share/systemd/user/
	else
		source=~/$i
		target=`pwd`/$i
		if [ -f $source ]; then 
			echo "Copying $source to $target"
			cp $source $target
		elif [ -d $source ]; then 
			echo "Copying $source dir to $target/"
			cp -r $source/* $target/
		fi
	fi
done
