
#For GPG
GNUPGHOME=~/.gnupg
GPG_TTY=$(tty)
export GPG_TTY

# Load environment variables
for e in $HOME/.zshenv.d/*;do
  source $e
done
