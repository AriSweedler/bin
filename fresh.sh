#!/usr/bin/env bash

#invoke with
# bash <(curl --silent https://raw.githubusercontent.com/AriSweedler/bin/master/fresh.sh)

################################ git installed ################################
function check-for-git() {
  if ! which git &>/dev/null; then
    echo "git is not installed. Please install git"
    # TODO automatically install git
    ############################################
    # You can download a tar.gz and make from source:
    # https://github.com/git/git/releases
    ############################################
    # OR based on which (OS this is/available binary), use the package manager
      # apt-get (debian)
      # rpm/yum/dnf (red hat, centos)
    ############################################
  fi
}

################################## Make a key ##################################
#TODO improve make-key to be able to print as wel
function make-key() {
  KEY="$1"
  if [ ! -f $KEY ]; then
    echo "Creating $KEY and $KEY.pub"
    # execute ssh-keygen with the RSA algorithm. Use an empty passphrase and
    # output to the file $KEY
    ssh-keygen -t rsa -N '' -f "$KEY"
    # TODO email the pubkey to my laptop? Somehow help me get it onto my GitHub
  else
    echo "$KEY already there"
  fi
}

######################## check authentication to GitHub ########################
function __check-github-auth() {
  # Attempt to ssh to GitHub
  ssh -T git@github.com
  RET=$?
  if [ $RET == 1 ]; then
    return 0
  elif [ $RET == 255 ]; then
    echo "You need a pubkey on GitHub"
    read -p "Press any key to continue... " -n 1
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
    echo "You have no pubkey. Generating and catting one"
    make-key $KEY
    cat "$KEY.pub"
  fi

  PS3="Select an option: "
  while true; do
    if __check-github-auth; then
      echo "User is authenticated on GitHub"
      return 0;
    else
      echo "User is not authenticated on GitHub"
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
          make-key $KEY;;
        "Cat key")
          echo "catting key, then checking again";
          cat "$KEY.pub";;
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
# TODO make sure pre-req programs are installed
  # curl ssh git vim

# make sure Git is installed
echo "Making sure git is installed..."
check-for-git
echo

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
echo

######################### run dotfiles update command #########################
echo "Running dotfiles update command"
source $HOME/dotfiles/update.sh
echo

echo "Done! Machine is freshly set up"
