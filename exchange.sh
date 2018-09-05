#!/bin/bash
########################## input validation ##########################
function usage() {
  printf "Usage (must be used in a git repository):\n\t"
  printf "${0##*/} <old word> <new word>"
}

if [[ $# != 2 ]]; then
  echo "Incorrect number of arguments. Need 2, have $#"
  usage
  exit 1
fi

############## rename input to make code more readable ##############
OLD=$1
NEW=$2

## get a list of the files to change, relative to the git root dir ##
FILES=`git grep --name-only $OLD | tr '\n' ' '`

################# check to see if we have work to do #################
if [ -z "$FILES" ]
then
  echo "no occurences of $OLD in repo."
  exit 0
fi

##################### enter git repo's root dir #####################
GIT_ROOT_DIR=`git rev-parse --show-toplevel`
cd "$GIT_ROOT_DIR"
######## run command with each file as the argument ########
CMD="sed -i '' \"s/$OLD/$NEW/g\""
for f in $FILES
do
  $CMD $f
done
