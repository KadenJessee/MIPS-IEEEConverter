#!/usr/bin/env bash

# unofficial "strict mode"
set -euo pipefail
IFS=$'\n\t'

MARS=`dirname $0`/mars-4-5.jar

# test all test runners against example code
function test-activity 
{
  log "Testing challenge activity..."
  # Make sure the order of the test is as follows:
  # First input parameter is the test_ca.asm script
  # Second input parameter is the student file: ca.asm
  java -jar $MARS ae1 nc ca/test_ca.asm ca/ca.asm
  # done
}

# log a message
function log 
{
  echo "*- $@"
}

# if called with interpreter, run fn that matches first arg
[[ ${BASH_SOURCE[0]} = "$0" ]] && 
{
  eval "$1" "${@:2}"
}
