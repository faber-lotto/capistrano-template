#!/bin/bash

vagrant up
#vagrant ssh -- -t 'sudo rm ~/execute_some_thing.sh'
cap development check
cap development setup
vagrant ssh -- -t 'sudo ls -l ~/execute_some_thing.sh; sudo cat ~/execute_some_thing.sh'
