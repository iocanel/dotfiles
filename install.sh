#!/bin/bash

#
# Install dotfiles
#

TARGET_DIR="${HOME}"

while [[ $# -gt 0 ]]; do
    case $1 in
      --target-dir)
        TARGET_DIR="$2"
        shift # past argument
        shift # past argument
        ;;
      --cleanup)
        CLEANUP="true"
        shift # past argument
        ;;
      --dry-run)
        DRY_RUN="true"
        shift # past argument
        ;;
      --help)
        echo "install.sh"
        echo "Options:"
        echo "  --cleanup:          Cleanup original dirs after installation"
        echo "  --dry-run:          Show commands without executing them"
        exit 0
        ;;
      -*|--*)
        echo "Unknown option $1"
        exit 1
        ;;
      *)
        POSITIONAL_ARGS+=("$1") # save positional arg
        shift # past argument
        ;;
    esac
  done


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
		target="$TARGET_DIR/$i"
		source=`pwd`/$i
		move_cmd=""
		link_cmd=""
		rm_cmd=""
		if [ -f "$target" ]; then 
			move_cmd="mv ${target} ${target}.dtf"
			link_cmd="ln -s $source $target"
		elif [ -d "$target" ]; then 
			move_cmd="mv ${target} ${target}.dtf"
			link_cmd="ln -s $source $target"
		else
			link_cmd="ln -s $source $target"
		fi

		if [ -n "$CLEANUP" ]; then
			rm_cmd="rm -rf ${target}.dtf"
		fi

		if [ -n "$DRY_RUN" ]; then
			if [ -n "$move_cmd" ]; then
				echo "$move_cmd"
			fi
			if [ -n "$link_cmd" ]; then
				echo "$link_cmd"
			fi
			if [ -n "$rm_cmd" ]; then
				echo "$rm_cmd"
			fi
		else
			if [ -n "$move_cmd" ]; then
				eval "$move_cmd"
			fi
			if [ -n "$link_cmd" ]; then
				eval "$link_cmd"
			fi
			if [ -n "$rm_cmd" ]; then
				eval "$rm_cmd"
			fi

		fi
	fi
done