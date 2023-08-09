source $HOME/workspace/src/github.com/zplug/zplug/init.zsh

setopt -o nomatch

eval $( dircolors -b $HOME/.dircolors )
# Load functions
fpath=( "$HOME/.zfunc.d" $fpath )

#
# Load configuration
for c in $HOME/.zshrc.d/*;do
  source $c
done

for c in $HOME/.zshenv.d/*;do
  source $c
done


# Then, source plugins and add commands to $PATH
zplug load

# These need to run after zplug load (?)
# source <(kubectl completion zsh)
# source <(oc completion zsh)

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/iocanel/.sdkman"
[[ -s "/home/iocanel/.sdkman/bin/sdkman-init.sh" ]] && source "/home/iocanel/.sdkman/bin/sdkman-init.sh"

unalias mvn

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/iocanel/google-cloud-sdk/path.zsh.inc' ]; then . '/home/iocanel/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/iocanel/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/iocanel/google-cloud-sdk/completion.zsh.inc'; fi


# Add Jbang to environment
alias j!=jbang
export PATH="$HOME/.jbang/bin:$PATH"
if [ -e /home/iocanel/.nix-profile/etc/profile.d/nix.sh ]; then . /home/iocanel/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Add nix
source /home/iocanel/.nix-profile/etc/profile.d/nix.sh

export PATH="$HOME/.poetry/bin:$PATH"
source /usr/share/nvm/init-nvm.sh
eval "$(zoxide init zsh)"
