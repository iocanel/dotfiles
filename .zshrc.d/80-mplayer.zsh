if [[ ! -a ~/.local/share/mplayer ]]; then
    mkdir -p ~/.local/share/mplayer
fi

if [[ ! -a ~/.local/share/mplayer/fifo ]]; then
    mkfifo ~/.local/share/mplayer/fifo
fi
