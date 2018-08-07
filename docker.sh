#!/bin/sh
#
# run this by typing:
#
# sh docker.sh
#
# This will place you in a bash shell, in this folder
# robot will be in your path, 
# all commands from the tutorial can be executed in this environment
#
#docker run -v $PWD:/work -w /work --rm -ti obolibrary/odkfull bash
docker run -v $PWD:/work -w /work --rm -ti obolibrary/robot:v1.2.0-alpha bash
