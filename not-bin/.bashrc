#######################################################################
#                                                                     #
#   .bashrc file                                                      #
#                                                                     #
#   commands to perform from the bash shell at login time             #
#                                                                     #
#######################################################################

echo "Today's date is `date`"

#other
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:/mongodb/bin"
export EDITOR=vim
alias vi="vim"
alias ocaml="echo '        rlwrap enabled';rlwrap ocaml"
alias pwdd='. cowsay-pwd'

#alias to make downloading stuff from the seasnet server easier.
#It takes everything from "~/transfer" on the server and downloads it
alias transfer="scp -r  ari@lnxsrv06.seas.ucla.edu:~/transfer Downloads/"

#Sourcing my stuff
. "$HOME/bin/PS1_custom.sh"

# OPAM configuration (for OCaml)
. /Users/ari/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true
eval `opam config env`
