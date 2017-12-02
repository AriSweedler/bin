#!/bin/bash

#This script makes it easier to create a colored prompt script.
#Bash colored output works by sending an unprinted escape sequence to get the console to switch "pen color"
#non-printing escape sequences have to be enclosed in \[ESC[ and \].
NO_COL='\[\e[0m\]'  #'\033'='\e'='^['='\0x1b'='ESC in ascii'
SET_COL=$NO_COL

#Function to set color
function SET_C() {
    # If we get 0 parameters, then assume that we don't wish to change the color.
    if [ $# = 0 ]; then
        return
    fi
    # If we only get one parameter, then assume it's just the color. Call this function with "plain" as the style
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
        *)              SET_COL=NO_COL; echo "error in style: '$1'"; return;;
    esac

    case $2 in
        "BLACK")        COLOR="30";;
        "RED")          COLOR="31";;
        "GREEN")        COLOR="32";;
        "YELLOW")       COLOR="33";;
        "BLUE")         COLOR="34";;
        "PURPLE")       COLOR="35";;
        "CYAN")         COLOR="36";;
        "WHITE")        COLOR="37";;
        *)              SET_COL=NO_COL; echo "error in color: '$2'"; return;;
    esac
    # Start color variable
    SET_COL="\[\e[${STYLE};${COLOR}m\]"
    #Fun fact: we have to escape the brackets to make sure that bash knows how to calculate PS1's length.
    #Without the escaped brackets, bash would miscalculate PS1's length and wrap around at the wrong time.
}

#This function makes my styling calls prettier.
#Usage: STYLE <VAR> <'string'> [[<style>] <color>]
function STYLE() {
  SET_C $3 $4
  eval "$1='${SET_COL}$2${NO_COL}'" #This establishes $1 as a shell variable.
  #I place NO_COL at the end because having `plain` style doesn't overwrite.
  #If you underline the first chunk then leeave the rest as plain, everything will come out as underlined.
}

################################
# Set the colors and parts of the prompt. Below this is the customizable part. Get creative!
#Check out https://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html as a reference for special PS1 chars
STYLE PS1_TIME '[\@]' dark YELLOW
STYLE PS1_USER '\u' underline RED
STYLE PS1_AT '@' light BLUE
STYLE PS1_HOST '\h' light RED
STYLE PS1_DIR '\W' dark GREEN
STYLE PS1_END '> ' light BLUE
STYLE OPENB '[' dark GREEN; STYLE CLOSEB ']'

################################
# Do the actual export, placing the parts in any order
export PS1="${PS1_OPENB}${PS1_USER}${PS1_AT}${PS1_HOST}${PS1_CLOSEB} $PS1_DIR $PS1_END"
