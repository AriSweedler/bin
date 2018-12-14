#!/usr/bin/env bash

#invoke with
# bash <(curl --silent https://raw.githubusercontent.com/AriSweedler/bin/master/fresh.sh)

################################ git installed ################################
function basic-programs() {
  PROGRAMS="curl ssh git vim"
  echo "Making sure we have $PROGRAMS"
  if which apt-get; then
    apt-get update
    apt-get -y install $PROGRAMS
  elif which yum; then
    yum install $PROGRAMS
  else
    echo "unable to install needed programs"
    exit 1
  fi
  return $?
}

################################## Make a key ##################################
function key-tool() {
  # Parse arguments
  KEY="$HOME/.ssh/id_rsa"
  while [ $1 ]; do
    case $1 in
      "-p"|"--print") PRINT=1 ;;
      "-m"|"--make") MAKE=1 ;;
      *) KEY="$1" ;;
    esac
    shift
  done

  # make the keypair if it doesn't already exist
  if [ $MAKE ]; then
    if [ ! -f $KEY ]; then
      echo "Creating $KEY and $KEY.pub"
      # execute ssh-keygen with the RSA algorithm. Use an empty passphrase and
      # output to the file $KEY
      ssh-keygen -t rsa -N '' -f "$KEY"
    else
      echo "$KEY already there"
    fi
  fi

  # print the key
  if [ $PRINT ]; then
    echo "------------------- VVV Your public key is VVV -------------------"
    cat "$KEY.pub"
    echo "------------------- ^^^ Your public key is ^^^ -------------------"
  fi
}

######################## check authentication to GitHub ########################
function __check-github-auth() {
  # Attempt to ssh to GitHub
  ssh -o "StrictHostKeyChecking=no" -T "git@github.com" &>/dev/null
  RET=$?
  if [ $RET == 1 ]; then
    return 0
  elif [ $RET == 255 ]; then
    return 1
  fi

  echo "unknown exit code to attempt to ssh into git@github.com"
  return 1
}

# a menu wrapper around the above command. If not authenticated, give user
# options: "Quit" "Check again" "Generate key"
function check-github-auth() {
  KEY="$HOME/.ssh/id_rsa"

  if [ ! -f $KEY ]; then
    mkdir -p $(dirname $KEY)
    echo "You have no pubkey. Generating and printing one"
    key-tool --make --print $KEY
    cat "$KEY.pub"
  fi

  PS3="Select an option: "
  while true; do
    if __check-github-auth; then
      echo "User is authenticated on GitHub"
      return 0;
    else
      echo "User is not authenticated on GitHub - please supply a pubkey"
      read -p "Press any key to continue... " -n 1
    fi

    select OPTION in "Quit" "Check again" "Generate key" "Cat key"; do
      case $OPTION in
        "Quit")
          echo "Quitting";
          exit 1;;
        "Check again")
          echo "Checking again";;
        "Generate key")
          echo "Generating key, then checking again";
          key-tool --make $KEY;;
        "Cat key")
          echo "Printing key, then checking again";
          key-tool --print $KEY;;
      esac
    done #select
  done #while
}

############################ clone necessary repos ############################
# Only clone the repo $1 if needed - running this on a Docker image with these
# already installed shouldn't blow away and re-clone them, it should simply
# update them
function home-repo() {
  pushd $HOME
  REPO=$1

  # if the repo doesn't exist, then clone it to MAKE it exist/
  if [ ! -d "$HOME/$REPO/.git" ]; then
    git clone "git@github.com:AriSweedler/$REPO.git"
  else
  # if the repo DOES exist, then make sure it's up to date.
    echo "Repo $REPO exists, updating it"
    pushd $REPO
    git pull
    popd
  fi

  popd
}

############################# Invoke the functions #############################
# make sure all the programs are installed
# all machines noramlly come with curl/ssh. git/vim ? Maybe. Special case this depending on what I need next summer

# make sure we're authenticated with GitHub as Ari Sweedler
echo "Making sure we're authenticated with GitHub"
check-github-auth
echo

# place these repos in our home dir
echo "cloning repos"
for REPO in "bin" "dotfiles"; do
  printf "  cloning $REPO... "
  home-repo $REPO &>/dev/null
  echo "done"
done
echo "repos cloned"

######################### run dotfiles update command #########################
echo "Running dotfiles update command"
source $HOME/dotfiles/update.sh
echo

echo "Done! Machine is freshly set up"
echo

