export VISUAL=emacs
#GOLANG
export GOPATH=$HOME/workspace
export GO15VENDOREXPERIMENT=1


#Java Tooling
export JAVA_HOME=/usr/lib/jvm/default
export JAVA_OPTS=-Xmx1024m
export GRADLE_HOME=$HOME/tools/gradle
export M2_HOME=$HOME/tools/maven
export CXF_HOME=$HOME/tools/cxf
export VERTX_HOME=$HOME/tools/vertx

#GraalVM
export GRAALVM_HOME=$HOME/.sdkman/candidates/java/1.0.0-rc-16-grl

#export PATH=/bin:/usr/bin:/usr/local/bin:$HOME/bin
export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$CXF_HOME/bin:$VERTX_HOME/bin:$GOPATH/bin:$PATH
#export PATH=$PATH:$GRAALVM_HOME/bin

export MAVEN_OPTS=-DskipTests
