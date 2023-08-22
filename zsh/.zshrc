source $HOME/workspace/src/github.com/marlonrichert/zsh-snap/znap.zsh

setopt -o nomatch

source $HOME/.zfunc.d/async
znap prompt iocanel/pure
eval $( dircolors -b $HOME/.dircolors )

# Load functions
fpath=( "$HOME/.zfunc.d" $fpath )

# Load configuration
for c in $HOME/.zshrc.d/*;do
  source $c
done

for c in $HOME/.zshenv.d/*;do
  source $c
done

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/iocanel/.sdkman"
[[ -s "/home/iocanel/.sdkman/bin/sdkman-init.sh" ]] && source "/home/iocanel/.sdkman/bin/sdkman-init.sh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/iocanel/google-cloud-sdk/path.zsh.inc' ]; then . '/home/iocanel/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/iocanel/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/iocanel/google-cloud-sdk/completion.zsh.inc'; fi


# Add Jbang to environment
export PATH="$HOME/.jbang/bin:$PATH"

source /usr/share/nvm/init-nvm.sh
eval "$(zoxide init zsh)"
