#!/bin/bash

# This script makes it easier to create a colored prompt script.
# Bash colored output works by sending an unprinted escape sequence to get the
# console to switch "pen color" non-printing escape sequences have to be
# enclosed in \[ESC[ and \].
END_COLOR='\[\e[0m\]'  #'\033'='\e'='^['='\0x1b'='ESC in ascii'
SET_COLOR=$END_COLOR

#Function to set color
function SET_C() {
    # If we get 0 parameters, then assume that we don't wish to change the color.
    if [ $# = 0 ]; then
        return
    fi
    # If we only get one parameter, then assume it's just the color. Call this
    # function with "plain" as the style
    if [ $# = 1 ]; then
        SET_C plain $1
        return
    fi

    case $1 in
        "plain")        STYLE='00';;
        "light")        STYLE='01';;
        "dark")         STYLE='02';;
        "italic")       STYLE='03';;
        "underline")    STYLE='04';;
        "reverse")      STYLE='07';;
        *)              SET_COLOR=END_COLOR; echo "error in style: '$1'"; return;;
    esac

    case $2 in
	"CLEAR")	COLOR="00";;
        "BLACK")        COLOR="30";;
        "RED")          COLOR="31";;
        "GREEN")        COLOR="32";;
        "YELLOW")       COLOR="33";;
        "BLUE")         COLOR="34";;
        "PURPLE")       COLOR="35";;
        "CYAN")         COLOR="36";;
        "WHITE")        COLOR="37";;
        *)              SET_COLOR=END_COLOR; echo "error in color: '$2'"; return;;
    esac
    # Start color variable
    SET_COLOR="\[\e[${STYLE};${COLOR}m\]"
    # We have to escape the brackets to make sure that bash knows how to
    # calculate PS1's length. Without the escaped brackets, bash would
    # miscalculate PS1's length and wrap around at the wrong time.
}

#This function makes my styling calls prettier.
#Usage: STYLE <VAR> <'string'> [[<style>] <color>]
function STYLE() {
  SET_C $3 $4
  eval "$1='${SET_COLOR}$2'" #This establishes $1 as a shell variable.
}

################################
parse_git_branch ()
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

################################
# Set the colors and parts of the prompt.

if [ "$(whoami)" = "ari" ]; then
  PS1_USER_BODY="Ari"
else
  PS1_USER_BODY="\u"
fi

STYLE PS1_TIME '[\@]' dark YELLOW
STYLE PS1_at 'at' CLEAR
STYLE PS1_USER "$PS1_USER_BODY" dark RED
STYLE PS1_in 'in' CLEAR
STYLE PS1_DIR '\W' dark GREEN
STYLE PS1_GIT_BRANCH '$(parse_git_branch)' YELLOW
#STYLE PS1_GIT '$(__git_ps1 "- (%s)")' RED
STYLE PS1_END '\n🚀 $ ' light BLUE

################################
# Assemble the parts as you wish
PS1="$PS1_TIME $PS1_at $PS1_USER $PS1_in $PS1_DIR $PS1_GIT_BRANCH $PS1_END"
################################
# Do the actual export, setting the color back to the default at the end
export PS1="${PS1}${END_COLOR}"
