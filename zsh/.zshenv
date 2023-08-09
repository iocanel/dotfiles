export GPG_TTY=$(tty)

# Load environment variables
for e in $HOME/.zshenv.d/*;do
  source $e
done
