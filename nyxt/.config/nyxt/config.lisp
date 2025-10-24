(defparameter *config-directory* (merge-pathnames ".config/nyxt/" (user-homedir-pathname)))
(load (merge-pathnames "theme.lisp" *config-directory*))
(load (merge-pathnames "github.lisp" *config-directory*))
(load (merge-pathnames "youtube.lisp" *config-directory*))


;; Execute command
(define-configuration buffer
    ((override-map (let ((map (make-keymap "override-map")))
                     (define-key map "C-s" 'search-buffer) ; Align with swiper
                     (define-key map "M-x" 'execute-command)))))

;; Hints
(define-configuration :hint-mode
  ((nyxt/mode/hint:hints-alphabet "JFKDLSHGAURIEOWPQ")
   (nyxt/mode/hint:hinting-type :vi)
   (nyxt/mode/hint:show-hint-scope-p nil)))

;; Search engines
(define-configuration buffer
    ((search-engines
      (list
      (make-instance 'search-engine
                      :shortcut "ghb"
                      :search-url "https://github.com/search?q=~a"
                      :fallback-url "https://github.com/trending")
       (make-instance 'search-engine
                      :shortcut "dd"
                      :search-url "https://duckduckgo.com/?kae=d&q=~a"
                      :fallback-url "https://duckduckgo.com/")
       (make-instance 'search-engine
                      :shortcut "yt"
                      :search-url "https://youtube.com/results?search_query=~a"
                      :fallback-url "https://youtube.com/")
       (make-instance 'search-engine
                      :shortcut "so"
                      :search-url "https://stackoverflow.com/search?q=~a"
                      :fallback-url "https://stackoverflow.com/")
       (make-instance 'search-engine
                      :shortcut "tv"
                      :search-url "https://www.thingiverse.com/search?q=~a"
                      :fallback-url "https://www.thingiverse.com/")
       (make-instance 'search-engine
                      :shortcut "sk"
                      :search-url "https://www.skroutz.gr/search?keyphrase=~a"
                      :fallback-url "https://www.skroutz.gr/")
       (make-instance 'search-engine
                      :shortcut "wp"
                      :search-url "https://www.wikipedia.org/w/index.php?title=Special:Search&search=~a"
                      :fallback-url "https://www.wikipedia.org/")
       (make-instance 'search-engine
                      :shortcut "ggl"
                      :search-url "https://www.google.com/search?q=~a"
                      :fallback-url "https://www.google.com")
       (make-instance 'search-engine
                      :shortcut "np"
                      :search-url "https://search.nixos.org/packages?channel=24.05&from=0&size=50&sort=relevance&type=packages&query=~a"
                      :fallback-url "https://search.nixos.org")
       (make-instance 'search-engine
                      :shortcut "nc"
                      :search-url "https://search.nixos.org/options?channel=24.05&from=0&size=50&sort=relevance&type=packages&query=~a"
                      :fallback-url "https://search.nixos.org")))))

