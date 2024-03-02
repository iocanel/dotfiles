export VISUAL=vim
# LSP Mode use PLUSTS for performance
export LSP_USE_PLISTS=true

#GOLANG
export GOPATH=$HOME/workspace
export CARGO_PATH=$HOME/.cargo
export GO15VENDOREXPERIMENT=1

#Java Tooling
export JAVA_HOME=$HOME/.sdkman/candidates/java/current
#export JAVA_HOME=/usr/lib/jvm/default
export JAVA_OPTS=-Xmx1024m
export GRADLE_HOME=$HOME/tools/gradle
export M2_HOME=$HOME/.sdkman/candidates/maven/current
export CXF_HOME=$HOME/tools/cxf
export VERTX_HOME=$HOME/tools/vertx
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_AVD_HOME=$HOME/.android/avd

# React native
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin/
#GraalVM
export GRAALVM_HOME=$HOME/.sdkman/candidates/java/current

#Ruby
export GEM_HOME="$HOME/.gem"

#export PATH=/bin:/usr/bin:/usr/local/bin:$HOME/bin
export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$CXF_HOME/bin:$VERTX_HOME/bin:$GOPATH/bin:$CARGO_PATH/bin/:$PATH:$GEM_HOME/ruby/3.0.0/bin
#export PATH=$PATH:$GRAALVM_HOME/bin

#export MAVEN_OPTS=-DskipTests

#Gren
export GREN_GITHUB_TOKEN=`pass show services/github.com/iocanel/token`

# Snowdrop bot
#export GITHUB_TOKEN=`pass show services/github.com/snowdrop-bot/token`
export GITHUB_TOKEN=`pass show services/github.com/iocanel/token`
export JIRA_USERNAME="iocanel"
export JIRA_PASSWORD=`pass show websites/jboss.org/iocanel`

#
# Source Graph
#
#export SRC_ACCESS_TOKEN=`pass show services/sourcegraph/token`
#export SRC_ENDPOINT=https://sourcegraph.com
