# Load autoconfiguration
config.load_autoconfig()

#
# Appearance
#
import catppuccin

# load your autoconfig, use this, if the rest of your config is empty!
config.load_autoconfig()

# set the flavor you'd like to use
# valid options are 'mocha', 'macchiato', 'frappe', and 'latte'
# last argument (optional, default is False): enable the plain look for the menu rows
catppuccin.setup(c, 'mocha', False)

# Custom stylesheet
config.set('content.user_stylesheets', '~/.config/qutebrowser/custom.css')

#Misc
c.zoom.default = "200%"
c.tabs.position = "top"
c.tabs.show = "never"
c.statusbar.show = "never"


#
# Colors
#
c.colors.completion.category.fg = '#FAB387'

#
# Downloads
#
c.downloads.location.directory = '~/Downloads'
c.downloads.location.prompt = True
c.downloads.location.remember = True
c.downloads.location.suggestion = 'both'

#
# Fonts
#
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
        "gp": "https://chat.openai.com/?q={}",
        "gw": "https://wiki.gentoo.org/?search={}",
        "gh": "https://github.com/search?q={}",
        "gk": "https://keep.google.com/u/0/#search/text={}",
        "jk": "https://wiki.jenkins-ci.org/dosearchsite.action?queryString={}",
        "kb": "https://kubernetes.io/docs/search?q={}",
        "np": "https://search.nixos.org/packages?channel=24.11&from=0&size=50&sort=relevance&type=packages&query={}",
        "nc": "https://search.nixos.org/options?channel=24.05&from=0&size=50&sort=relevance&type=packages&query=~{}",
        "os": "https://docs.openshift.com/search.html?query={}",
        "sk": "https://www.skroutz.gr/search?keyphrase={}",
        "so": "https://stackoverflow.com/search?q={}",
        "tw": "https://twitter.com/search?src=typd&q={}",
        "tv": "https://www.thingiverse.com/search?q={}",
        "w": "http://www.wikipedia.org/w/index.php?title=Special:Search&search={}",
        "yt": "https://www.youtube.com/results?search_query={}"
    }

# Keybindings
config.bind('<Alt-a>', 'set tabs.show always')
config.bind('<Ctrl-k>', 'spawn -v /bin/kubectl apply -f - {primary}')


config.bind('<Ctrl-m>', 'hint links spawn mpv {url}')
config.bind('<Ctrl-y>', 'spawn yt-dlp -f "bestvideo+bestaudio" -o "~/Downloads/%(title)s.%(ext)s"   {url}')
config.bind('<alt-y>', 'spawn youtube-mp3-get {url}')

config.bind('<alt-s>', 'hint')
config.bind('e', 'move-to-end-of-word')
config.bind('b', 'move-to-previous-word')

config.bind('E', 'cmd-set-text :open {url}')
config.bind('<Ctrl-e>', 'cmd-set-text :open {url}')
config.bind('<Ctrl-t>', 'cmd-set-text :open -t {url}')

config.bind('z', 'back')

config.unbind('d') 
config.unbind('h')  # Lot's of sentence starters start with h and it's a demo killer

#
# Github 
#

# Aliases
c.aliases['github-clone'] = 'spawn --userscript github-clone.sh {url}'
c.aliases['github-terminal'] = 'spawn --userscript github-terminal.sh {url}'
c.aliases['github-goto-fork'] =  'spawn --userscript github-goto-fork.sh {url}'
c.aliases['github-new-issue'] = 'spawn --userscript github-new-issue.sh {url}'
c.aliases['github-pr-checkout'] = 'spawn --userscript github-pr-checkout.sh {url}'

# Bindings
config.bind('<Ctrl-g>c', 'spawn --userscript github-clone.sh {url}')
config.bind('<Ctrl-g>t', 'spawn --userscript github-terminal.sh {url}')
config.bind('<Ctrl-g>f', 'spawn --userscript github-goto-fork.sh {url}')
config.bind('<Ctrl-g>i', 'spawn --userscript github-new-issue.sh {url}')
config.bind('<Ctrl-g>pc', 'spawn --userscript github-pr-checkout.sh {url}')


# User Agent
c.content.headers.user_agent = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                                "AppleWebKit/537.36 (KHTML, like Gecko) "
                                "Chrome/117.0.0.0 Safari/537.36")

# Cookies
config.set("content.javascript.enabled", True, "https://*.google.com/*")
config.set("content.cookies.accept", "all", "https://*.google.com/*")

# Clipboard
config.set("content.javascript.clipboard", "access", "https://chatgpt.com")
