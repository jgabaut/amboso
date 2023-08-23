#!/bin/bash

function hw_amboso {
  echo -e "Hello, World!";
  echo -n "Built using amboso API v"
  ./amboso "-qv";
  echo -n "amboso v";
  ./amboso "-qv";
  echo "" ;
}

function hw_prog {
  cat <( "./hello_world" )
}

function give {
  return "$1"
}

#hw_amboso
#hw_prog

if [[ $( hw_amboso ) = $( hw_prog ) ]] ; then {
  echo "[Success] versions matched!"
  give 0
} else {
  echo "[Fail] versions mismatch, you did not update one of them?"
  give 1
}
fi
