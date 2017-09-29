#Set color
function SET_C() {
    # If we only get one parameter, then assume it's just the color. Call this function with "plain" as the style
    if [ $# = 1 ]; then
        SET_C plain $1
        return
    fi

    case $1 in
        "plain")        STYLE='00';;
        "light")        STYLE='01';;
        "dark")            STYLE='02';;
        "italic")        STYLE='03';;
        "underline")    STYLE='04';;
        "reverse")        STYLE='07';;
        *) _SC='\033[0m'; echo "error in style: '$1'"; return;;
    esac

    case $2 in
        "BLACK")        COLOR="30";;
        "RED")            COLOR="31";;
        "GREEN")        COLOR="32";;
        "YELLOW")        COLOR="33";;
        "BLUE")            COLOR="34";;
        "PURPLE")        COLOR="35";;
        "CYAN")            COLOR="36";;
           "WHITE")        COLOR="37";;
        *) _SC='\033[0m';  echo "error in color: '$2'"; return;;
    esac
    # Start color variable
    _SC="\[\033[${STYLE};${COLOR}m\]"
}
#End color variable
_EC="\[\e[0m\]"

################################
# Set the colors and parts of the prompt.

SET_C dark YELLOW
PS1_TIME="$_SC[\@]$_EC"

SET_C underline RED
PS1_USER="${_SC}\u$_EC"

SET_C light RED
PS1_HOST="${_SC}\h$_EC"

SET_C light BLUE
PS1_MIDDLE="${_SC}@$_EC"

SET_C dark GREEN
PS1_DIR="$_SC\w$_EC"

SET_C light BLUE
PS1_END="$_SC> $_EC"

SET_C dark GREEN
PS1_OPENB="$_SC[$_EC"
PS1_CLOSEB="$_SC]$_EC"

################################
# Do the actual export, placing the parts in any order
export PS1="${PS1_OPENB}${PS1_USER}${PS1_MIDDLE}${PS1_HOST}${PS1_CLOSEB} $PS1_DIR $PS1_END"
