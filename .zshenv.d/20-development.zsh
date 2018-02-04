#GOLANG
export GOPATH=$HOME/workspace
export GO15VENDOREXPERIMENT=1

#Java 1.7.0
export JAVA_HOME=$HOME/tools/oracle-jdk-7
#Java 1.8.0
export JAVA_HOME=$HOME/tools/oracle-jdk-8

#Java Tooling
export JAVA_OPTS=-Xmx1024m
export GRADLE_HOME=$HOME/tools/gradle
export M2_HOME=$HOME/tools/maven
export VERTX_HOME=$HOME/tools/vertx

export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$VERTX_HOME/bin:$GOPATH/bin:$PATH
