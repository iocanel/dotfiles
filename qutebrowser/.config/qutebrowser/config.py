# Load autoconfiguration
config.load_autoconfig()

import catppuccin

# load your autoconfig, use this, if the rest of your config is empty!
config.load_autoconfig()

# set the flavor you'd like to use
# valid options are 'mocha', 'macchiato', 'frappe', and 'latte'
# last argument (optional, default is False): enable the plain look for the menu rows
catppuccin.setup(c, 'mocha', False)

# Colors
c.colors.completion.category.fg = '#FAB387'

# Fonts
c.fonts.completion.category="bold 18pt JetBrains Mono Nerd Font Bold"
c.fonts.completion.entry="18pt JetBrains Mono Nerd Font Bold"
c.fonts.debug_console="18pt JetBrains Mono Nerd Font Bold"
c.fonts.downloads="18pt JetBrains Mono Nerd Font Bold"
c.fonts.hints="bold 18pt JetBrains Mono Nerd Font Bold"
c.fonts.keyhint="18pt JetBrains Mono Nerd Font Bold"
c.fonts.messages.error="18pt JetBrains Mono Nerd Font Bold"
c.fonts.messages.info="18pt JetBrains Mono Nerd Font Bold"
c.fonts.messages.warning="18pt JetBrains Mono Nerd Font Bold"
c.fonts.prompts="18pt sans-serif"
c.fonts.statusbar="18pt JetBrains Mono Nerd Font Bold"

#Misc
c.zoom.default = "200%"
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
        "g": "https://www.google.com/search?q={}",
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
#config.bind('o', 'spawn --userscript qutedmenu open')
#config.bind('O', 'spawn --userscript qutedmenu tab')

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


# User Agent
c.content.headers.user_agent = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                                "AppleWebKit/537.36 (KHTML, like Gecko) "
                                "Chrome/117.0.0.0 Safari/537.36")

# Cookies
config.set("content.javascript.enabled", True, "https://*.google.com/*")
config.set("content.cookies.accept", "all", "https://*.google.com/*")

# Clipboard
config.set("content.javascript.clipboard", "access", "https://chatgpt.com")
