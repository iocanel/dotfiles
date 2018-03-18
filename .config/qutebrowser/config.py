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
c.fonts.tabs="10pt FontAwesome"
c.fonts.completion.category="bold 10pt FontAwesome"
c.fonts.completion.entry="10pt FontAwesome"
c.fonts.debug_console="10pt FontAwesome"
c.fonts.downloads="12pt FontAwesome"
c.fonts.hints="bold 12pt FontAwesome"
c.fonts.keyhint="12pt FontAwesome"
c.fonts.messages.error="12pt FontAwesome"
c.fonts.messages.info="12pt FontAwesome"
c.fonts.messages.warning="12pt FontAwesome"
c.fonts.monospace="/Consolas, Terminal"
c.fonts.prompts="12pt sans-serif"
c.fonts.statusbar="10pt FontAwesome"

#SSL
c.content.ssl_strict=False

#Misc
c.tabs.position = "top"
c.tabs.show = "switching"
c.statusbar.hide = True

# Search engines
c.url.searchengines = {
        "DEFAULT": "https://duckduckgo.com/?q={}",
        "g": "https://www.google.com/search?q={}",
        "a": "https://www.google.com/search?q={}",
        "am": "https://www.amazon.com/s/field-keywords={}",
        "amu": "https://www.amazon.co.uk/s/field-keywords={}",
        "amd": "https://www.amazon.co.de/s/field-keywords={}",
        "at": "http://www.athinorama.gr/search/default.aspx?q={}",
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
        "w": "http://www.wikipedia.org/w/index.php?title=Special:Search&search={}",
        "yt": "https://www.youtube.com/results?search_query={}"
    }
