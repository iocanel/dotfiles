alias ls='ls --color=auto'
#alias vi='emacs'
alias shutdown='shutdown -hP now'
alias ps-rss='ps ax -o pid,rss,command | numfmt --header --from-unit=1024 --to=iec --field 2|grep -v grep'
