source ~/.zplug/init.zsh

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
