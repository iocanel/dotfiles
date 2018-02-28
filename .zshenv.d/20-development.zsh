#GOLANG
export GOPATH=$HOME/workspace
export GO15VENDOREXPERIMENT=1


#Java Tooling
export JAVA_HOME=/usr/lib/jvm/default
export JAVA_OPTS=-Xmx1024m
export GRADLE_HOME=$HOME/tools/gradle
export M2_HOME=$HOME/tools/maven
export VERTX_HOME=$HOME/tools/vertx

export PATH=$M2_HOME/bin:$VERTX_HOME/bin:$GOPATH/bin:$PATH
