alias ls='ls --color=auto'
#alias vi='emacsclient -nw'
alias shutdown='shutdown -hP now'
alias ps-rss='ps ax -o pid,rss,command | numfmt --header --from-unit=1024 --to=iec --field 2|grep -v grep'
alias asciicast2gif='docker run --rm -v $PWD:/data asciinema/asciicast2gif'
alias idea="~/Idea/intellij/bin/idea.sh nosplash"
alias qs="java -jar ~/workspace/src/github.com/quarkusio/quarkus/devtools/cli/target/quarkus-cli-999-SNAPSHOT-runner.jar"
alias qton="java -jar ~/workspace/src/github.com/iocanel/qton/target/qton-999-SNAPSHOT-runner.jar"
alias njq="java -jar ~/workspace/src/github.com/iocanel/njq/target/njq-999-SNAPSHOT-runner.jar"
alias dekorate="java -jar ~/workspace/src/github.com/dekorateio/dekorate-cli/target/dekorate-cli-999-SNAPSHOT-runner.jar"
alias kubevirt="java -jar ~/workspace/src/github.com/quarkiverse/quarkus-kubevirt-client/cli/target/quarkus-kubevirt-cli-999-SNAPSHOT-runner.jar"
alias openshift-vm="java -jar ~/workspace/src/github.com/quarkiverse/quarkus-kubevirt-client/cli/target/quarkus-openshift-vm-cli-999-SNAPSHOT-runner.jar"
