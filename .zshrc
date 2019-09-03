source ~/.zplug/init.zsh
setopt +o nomatch

eval $( dircolors -b $HOME/.dircolors )
# Load functions
fpath=( "$HOME/.zfunc.d" $fpath )

#
# Load configuration
for c in $HOME/.zshrc.d/*;do
  source $c
done

# Then, source plugins and add commands to $PATH
zplug load

# These need to run after zplug load (?)
source <(kubectl completion zsh)
source <(oc completion zsh)

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/iocanel/.sdkman"
[[ -s "/home/iocanel/.sdkman/bin/sdkman-init.sh" ]] && source "/home/iocanel/.sdkman/bin/sdkman-init.sh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/iocanel/google-cloud-sdk/path.zsh.inc' ]; then . '/home/iocanel/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/iocanel/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/iocanel/google-cloud-sdk/completion.zsh.inc'; fi
