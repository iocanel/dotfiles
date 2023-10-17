export ZNAP_HOME="$HOME/workspace/src/github.com/marlonrichert/zsh-snap/"

if [ ! -d "$ZNAP_HOME" ]; then
  mkdir -p $ZNAP_HOME
  pushd $ZNAP_HOME
  git init
  git remote add origin https://github.com/marlonrichert/zsh-snap.git
  git pull --rebase origin main
  popd
fi
source "$ZNAP_HOME/znap.zsh"

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
