export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CACHE_HOME=$HOME/.cache

export GNUPGHOME=$HOME/.gnupg

if [ -f "$GNUPGHOME/.gpg-agent-info" ]; then
  source "$GNUPGHOME/.gpg-agent-info"
  export GPG_AGENT_INFO="$GNUPGHOME/gpg-agent.info"
fi


### BEGIN_GPG_PRESETS
/passbridge/init` > /dev/null 2>&1 & disown

