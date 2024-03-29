export EDITOR=vi
export TERMINAL=alacritty

#Scripts
SCRIPTS_HOME=$HOME/scripts

export PATH=$HOME/bin:${SCRIPTS_HOME}/arch:${SCRIPTS_HOME}:${SCRIPTS_HOME}/dev:${SCRIPTS_HOME}/install:${SCRIPTS_HOME}/k8s:${SCRIPTS_HOME}/notify:${SCRIPTS_HOME}/sound:${SCRIPTS_HOME}/util:${SCRIPTS_HOME}/wm:${SCRIPTS_HOME}/work:${SCRIPTS_HOME}/wrap:/bin:/usr/bin:/usr/local/bin:/var/lib/snapd/snap/bin:$HOME/bin

export HG2JJ_DIR=~/.local/share/hg2jj/
export OPENAI_API_KEY=`pass show services/openai/iocanel/api-key`
export QUARKUS_LANGCHAIN4J_OPENAI_API_KEY=`pass show services/openai/iocanel/api-key`
