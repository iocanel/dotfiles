#!/bin/bash

install_in_venv() {
  local project = $1
  if [ -z "$project" ]; then
    echo "Project can't be empty."
    exit 1
  fi

  virtualenv -p python3 ~/.virtualenvs/$project
  ~/.virtualenvs/$project/bin/pip install $project
  ln -s ~/.virtualenvs/bin/$project ~/.virtualenvs/bin
}

install_in_venv khard
install_in_venv khal
install_in_venv vdirsyncer

