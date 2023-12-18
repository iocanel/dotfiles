# Load autoconfiguration
config.load_autoconfig()

# Colors
c.colors.downloads.bar.bg="black"
c.colors.downloads.start.fg="white"
c.colors.statusbar.caret.bg="purple"
c.colors.statusbar.caret.fg="#a0b7c1"
c.colors.statusbar.command.bg="#262626"
c.colors.statusbar.insert.bg="#262626"
c.colors.statusbar.insert.fg="#555555"
c.colors.statusbar.normal.bg="#262626"
c.colors.statusbar.normal.fg="#a0b7c1"
c.colors.statusbar.passthrough.fg="white"
c.colors.statusbar.progress.bg="white"
c.colors.statusbar.url.error.fg="orange"
c.colors.statusbar.url.fg="#555555"
c.colors.statusbar.url.hover.fg="aqua"
c.colors.statusbar.url.success.http.fg="#a0b7c1"
c.colors.statusbar.url.success.https.fg="lime"
c.colors.statusbar.url.warn.fg="yellow"
c.colors.tabs.bar.bg="#555555"
c.colors.tabs.even.bg="#262626"
c.colors.tabs.even.fg="white"
c.colors.tabs.indicator.start="#0000aa"
c.colors.tabs.indicator.stop="#00aa00"
c.colors.tabs.odd.bg="#262626"
c.colors.tabs.selected.even.bg="#3a3a3a"
c.colors.tabs.selected.even.fg="white"
c.colors.tabs.selected.odd.bg="#3a3a3a"
c.colors.tabs.selected.odd.fg="white"
c.colors.webpage.bg="white"

# Fonts
#c.fonts.tabs="14pt DejaVu Sans Mono"
c.fonts.completion.category="bold 12pt DejaVu Sans Mono"
c.fonts.completion.entry="12pt DejaVu Sans Mono"
c.fonts.debug_console="12pt DejaVu Sans Mono"
c.fonts.downloads="12pt DejaVu Sans Mono"
c.fonts.hints="bold 12pt DejaVu Sans Mono"
c.fonts.keyhint="12pt DejaVu Sans Mono"
c.fonts.messages.error="12pt DejaVu Sans Mono"
c.fonts.messages.info="12pt DejaVu Sans Mono"
c.fonts.messages.warning="12pt DejaVu Sans Mono"
c.fonts.prompts="12pt sans-serif"
c.fonts.statusbar="12pt DejaVu Sans Mono"

#Misc
c.tabs.position = "top"
c.tabs.show = "never"
c.statusbar.show = "never"

# Insert mode
c.input.insert_mode.auto_enter=True
c.input.insert_mode.auto_leave=False
c.input.insert_mode.auto_load=True

# Search engines
c.url.searchengines = {
        "DEFAULT": "https://www.google.com/search?q={}",
        "bd": "https://duckduckgo.com/?q={}",
        "a": "https://www.google.com/search?q={}",
        "am": "https://www.amazon.com/s/field-keywords={}",
        "amu": "https://www.amazon.co.uk/s/field-keywords={}",
        "amd": "https://www.amazon.de/s/field-keywords={}",
        "at": "http://www.athinorama.gr/search/default.aspx?q={}",
        "eb": "https://www.ebay.co.uk/sch/i.html?_nkw={}&_sacat=0",
        "aw": "https://wiki.archlinux.org/index.php?search={}",
        "gw": "https://wiki.gentoo.org/?search={}",
        "gh": "https://github.com/search?q={}",
        "gk": "https://keep.google.com/u/0/#search/text={}",
        "jk": "https://wiki.jenkins-ci.org/dosearchsite.action?queryString={}",
        "kb": "https://kubernetes.io/docs/search?q={}",
        "os": "https://docs.openshift.com/search.html?query={}",
        "sk": "https://www.skroutz.gr/search?keyphrase={}",
        "so": "https://stackoverflow.com/search?q={}",
        "tw": "https://twitter.com/search?src=typd&q={}",
        "tv": "https://www.thingiverse.com/search?q={}",
        "w": "http://www.wikipedia.org/w/index.php?title=Special:Search&search={}",
        "yt": "https://www.youtube.com/results?search_query={}"
    }

# Keybindings

#
# Dmenu integration
#
# Copy the qutedmenu userscript under .local/share/qutebrowser/userscripts/
# Ensure that dmenu is installed or rofi linked to dmenu.
config.bind('o', 'spawn --userscript qutedmenu open')
config.bind('O', 'spawn --userscript qutedmenu tab')

config.bind('<Alt-a>', 'set tabs.show always')
config.bind('<Ctrl-p>', 'spawn --userscript qute-pass')

config.bind('<Ctrl-k>', 'spawn -v /bin/kubectl apply -f - {primary}')
config.bind('<Ctrl-k>', 'spawn -v /bin/kubectl apply -f - {primary}', mode='caret')

config.bind('<Ctrl-y>', 'spawn youtube-get {url}')
config.bind('<alt-y>', 'spawn youtube-mp3-get {url}')
config.bind('<alt-s>', 'hint')
config.bind('e', 'move-to-end-of-word')
config.bind('b', 'move-to-previous-word')
config.unbind('d') 
