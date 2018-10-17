#!/bin/bash

# Bash colored output works by sending an unprinted escape sequence to get the
# console to switch "pen color". These characters that don't count for prompt
# script length, but only change the style have to be enclosed in \[ and \] so
# bash knows how to count length

reset="\[\e[0m\]"
black="\[\e[1;30m\]"
red="\[\e[1;31m\]"
green="\[\e[2;32m\]"
yellow="\[\e[1;33m\]"
blue="\[\e[0;34m\]"
purple="\[\e[1;35m\]"
dark_purple="\[\e[2;35m\]"
cyan="\[\e[0;36m\]"
white="\[\e[1;37m\]"

display_branch() {
  # Return nothing if we're not in a git repo
  if [ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]; then
    return
  fi
  echo "on ${1}$(git symbolic-ref --short HEAD)"

}

################################
# Set the colors and parts of the prompt.

PS1=''

PS1+="\[\033]0" # Start terminal title and prompt.
PS1+="\w \$(display_branch)"
PS1+="\007\]" # end terminal title and prompt.

# Highlight the user name when logged in as root.
if [ $EUID == 0 ]; then
  userStyle="${purple}"
  prompt="${purple}#"
else
  userStyle="${blue}"
  prompt="${dark_purple}$"
fi

PS1+="\n${userStyle}\u" # username
PS1+="${white} in "
PS1+="${green}\W" # working directory full path
PS1+="${reset} \$(display_branch '${cyan}')" # Git repository details
PS1+="\n" # newline, prompt, and reset color
PS1+="🚀 ${prompt} "
PS1+="${reset}"
export PS1

PS2="${yellow}→ ${reset}"
export PS1
