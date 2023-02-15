export VISUAL=vim
#GOLANG
export GOPATH=$HOME/workspace
export GO15VENDOREXPERIMENT=1


#Java Tooling
export JAVA_HOME=/usr/lib/jvm/default
export JAVA_OPTS=-Xmx1024m
export GRADLE_HOME=$HOME/tools/gradle
export M2_HOME=$HOME/.sdkman/candidates/maven/current
export CXF_HOME=$HOME/tools/cxf
export VERTX_HOME=$HOME/tools/vertx
export ANDROID_HOME=$HOME/tools/android-sdk
export ANDROID_SDK_ROOT=$HOME/tools/android-sdk

#GraalVM
export GRAALVM_HOME=$HOME/.sdkman/candidates/java/current

#Ruby
export GEM_HOME="$HOME/.gem"

#export PATH=/bin:/usr/bin:/usr/local/bin:$HOME/bin
export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$CXF_HOME/bin:$VERTX_HOME/bin:$GOPATH/bin:$PATH:$GEM_HOME/ruby/2.6.0/bin
#export PATH=$PATH:$GRAALVM_HOME/bin

export MAVEN_OPTS=-DskipTests

#Gren
export GREN_GITHUB_TOKEN=`pass show services/github.com/iocanel/token`

# Snowdrop bot
export GITHUB_TOKEN=`pass show services/github.com/snowdrop-bot/token`
export JIRA_USERNAME="iocanel"
export JIRA_PASSWORD=`pass show websites/jboss.org/iocanel`
