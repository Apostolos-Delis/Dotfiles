#!/usr/bin/env zsh

function cdd() {
    if [ $# -eq 0 ]; then
        cdd-helper --help;
    elif [ ${1:0:1} != "-" ] && [ $1 != "add" ] && [ $1 != "rm" ];
    then
        DIR=`cdd-helper $@ -p`;
        if [[ ! -z $DIR ]]
        then
            cd $DIR;
        fi
    else
        cdd-helper $@;
    fi
}

function cs() {
  if [ $# -eq 0  ]; then
    cd && ls;
  else
    cd "$*" && ls;
  fi
}
alias cd='cs'
