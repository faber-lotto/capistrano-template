#!/bin/bash

SCRIPT_PATH="`dirname \"$0\"`"

SCRIPT_PATH="`( cd \"$SCRIPT_PATH\" && pwd )`"
if [ -z "$SCRIPT_PATH" ] ; then
  exit 1
fi

(
    cd $SCRIPT_PATH

    vagrant up
    #vagrant ssh -- -t 'sudo rm ~/execute_some_thing.sh'
    rm -f $SCRIPT_PATH/log/*
    cap development check
    cap development setup
    vagrant ssh -- -t 'sudo ls -l ~/execute_some_thing.sh; sudo cat ~/execute_some_thing.sh'
    vagrant ssh -- -t 'sudo ls -l /var/www/execute_some_thing.sh; sudo cat /var/www/execute_some_thing.sh'
    vagrant halt
)