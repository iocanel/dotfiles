alias ls='ls --color=auto'
#alias vi='emacsclient -nw'
alias shutdown='shutdown -hP now'
alias ps-rss='ps ax -o pid,rss,command | numfmt --header --from-unit=1024 --to=iec --field 2|grep -v grep'
alias asciicast2gif='docker run --rm -v $PWD:/data asciinema/asciicast2gif'
alias idea="~/Idea/intellij/bin/idea.sh nosplash"
alias quarkus="java -jar ~/workspace/src/github.com/quarkusio/quarkus/devtools/cli/target/quarkus-cli-999-SNAPSHOT-runner.jar"
