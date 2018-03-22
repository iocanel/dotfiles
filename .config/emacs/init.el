(require 'package)
(setq package-enable-startup nil)
;;(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)

;; Install use package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Load the literate configuration
(org-babel-load-file (expand-file-name "~/.config/emacs/config.org"))

;;
;; Generated Stuff
;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("f770ddb6b7dfda47ca06531a81d8d311077b93ebf8f54309548009faf362895c" "065efdd71e6d1502877fd5621b984cded01717930639ded0e569e1724d058af8" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" "84d2f9eeb3f82d619ca4bfffe5f157282f4779732f48a5ac1484d94d5ff5b279" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" default)))
 '(magit-gh-pulls-arguments (quote ("--open-new-in-browser")))
 '(magit-pull-arguments nil)
 '(magit-push-arguments (quote ("--force")))
 '(package-selected-packages
   (quote
    (flx-ido go-projectile meghanada tide xresources-theme html2org swiper ivy go-eldoc hydra git-gutter-fringe git-timemachine pdf-tools yasnippet-snippets rainbow-mode esh-autosuggest ## expand-region mark-multiple popup-kill-ring company-jedi virtualenvwarpper flycheck virtualenvwrapper pytest smart-tab emmet-mode ob-python ob-go ox-gfm ox-asciidoc github-pullrequest github-issues magit-gh-pulls magit-gh-pull org-present ox-reveal anaconda-mode pyenv-mode python-mode yaml-mode protobuf-mode kotlin-mode groovy-mode dockerfile-mode yasnippet projectile dashboard rainbow-delimiters company-go go-mode org2blog org-bullets magit ido-vertical-mode smart-mode-line-powerline-theme darcula-theme sudo-edit linum-relative company which-key evil-leader use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
