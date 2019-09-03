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
