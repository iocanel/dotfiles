(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dahboard-items `((recents . 10)))
  (setq dahboard-banner-logo-title "Never Settle"))

(define-key isearch-mode-map [escape] 'isearch-abort)
(define-key isearch-mode-map "\e" 'isearch-abort)
(global-set-key [escape] 'keyboard-escape-quit)

(use-package evil-leader
  :ensure t
  :config
  (global-evil-leader-mode))

(use-package evil
  :ensure t
  :init
(evil-mode 1))

(use-package which-key
  :ensure t
  :init
  (which-key-mode))

(global-set-key (kbd "C-x C-b") 'ibuffer)

(use-package smart-tab
  :ensure t
  :init
  (progn
    (setq hippie-expand-try-functions-list '(yas-hippie-try-expand
					     try-complete-file-name-partially
					     try-expand-dabbrev-visible
					     try-expand-dabbrev
					     try-expand-dabbrev-all-buffers
					     try-complete-lisp-symbol-partially
					     try-complete-lisp-symbol))
    (setq smart-tab-using-hippie-expand t)
    (setq smart-tab-disabled-major-modes '(org-mode term-mode eshell-mode inferior-python-mode))
    (global-smart-tab-mode 1)))

(use-package company
  :ensure t
  :init
 (add-hook 'after-init-hook 'global-company-mode))

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(use-package linum-relative
	 :ensure t
	 :init
	 (setq linum-relative-current-symbol ""))

;; We don't want this on non programming modes
(add-hook 'org-mode-hook (lambda () (linum-relative-mode)))

(use-package sudo-edit
  :ensure t
  :bind ("s-e" . sudo-edit))

(use-package rainbow-delimiters
  :ensure t
  :init
  (rainbow-delimiters-mode 1))

;;(use-package darcula-theme
;;  :ensure t
;;  :config)
(load "~/.config/emacs/darcula-theme.el")

(set-foreground-color "#a9b7c1")
(set-background-color "#262626")

;; Powerline
;;
;;(use-package powerline
;;  :ensure t)

;;(require 'powerline)
;;(powerline-center-theme)
(setq powerline-default-separator    'arrow)

;; Smartline
;;
(use-package smart-mode-line-powerline-theme
   :ensure t
   :after powerline
   :after smart-mode-line
   :init
   (sml/setup)
   (sml/apply-theme 'dark))

;; Spaceline
;;
;;(use-package spaceline
;; :ensure t
;;	 :config
;;	 (require 'spaceline-config)
;;	 (setq powerline-default-separator (quote arrow))
;;	 (spaceline-spacemacs-theme))

(set-face-attribute 'mode-line nil
                    :foreground "#262626"
                    :background "#555555"
                    :box nil)
(set-face-attribute 'mode-line-buffer-id nil
                    :foreground "#262626"
                    :background "#c57632"
                    :box nil)

(setq powerline-arrow-shape 'wave)

(setq ido-enable-flex-matching nil)
(setq ido-create-new-buffer 'always)
(setq ido-everywhere t)
(ido-mode 1)

(use-package ido-vertical-mode
  :ensure t
  :init
  (ido-vertical-mode 1))

(setq ido-use-faces t)
(set-face-attribute 'ido-vertical-first-match-face nil
                    :foreground "#ff0000")
(set-face-attribute 'ido-vertical-only-match-face nil
                    :foreground "#ff0000")
(set-face-attribute 'ido-vertical-match-face nil
                    :foreground "#a0b7c1")

(setq ido-vertical-define-keys 'C-n-C-p-up-down-left-right)

(setq ido-show-dot-for-dired t)

(require 'bookmark)
(require 'ido)

(defun ido-bookmark-jump ()
  "Uses ido to search for the bookmark"
  (interactive)
  (bookmark-jump
   (bookmark-get-bookmark
    (ido-completing-read "find bookmark: " (bookmark-all-names)))))

(provide 'ido-bookmark-jump)

(global-set-key (kbd "C-x r b") 'ido-bookmark-jump)

(defvar my-term-shell "/bin/zsh")
(defadvice ansi-term (before force-zsh)
  (interactive (list my-term-shell)))
(ad-activate 'ansi-term)

(global-set-key (kbd "<S-'>") 'ansi-term)

(use-package magit
  :ensure t)

;; Pull request integration
(use-package magit-gh-pulls
  :ensure t)

(use-package github-pullrequest :ensure t)

(use-package github-issues :ensure t)

(use-package projectile
  :ensure t)

(use-package yasnippet
  :ensure t
  :init
  (yas-global-mode)
  :config
  (yas-reload-all))

(setq yas-snippet-dirs (append yas-snippet-dirs
			       '("~/.config/yasnippets")))

(use-package org-evil :ensure t)

(setq org-src-window-setup 'current-window)

(setq org-src-tab-acts-natively t)

(use-package ob-go :ensure t)
(use-package ob-typescript :ensure t)

(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode))))

;; Seems missing at the moment
;; (use-package org-present :ensure t)

(use-package ox-reveal :ensure t)

(use-package org2blog :ensure t)

(let (blog-password)
  (setq blog-password (replace-regexp-in-string "\n\\'" ""  (shell-command-to-string "pass show iocanel.com/iocanel@gmail.com")))
  (setq org2blog/wp-blog-alist
        `(("iocanel.com"
           :url "https://iocanel.com/xmlrpc.php"
           :username "iocanel@gmail.com"
          :password ,blog-password))))

(define-obsolete-function-alias 'org-define-error 'define-error)

(use-package ox-asciidoc :ensure t)

(use-package ox-gfm :ensure t)

(use-package ng2-mode :ensure t)

(use-package go-mode
         :ensure t)
(require 'go-mode)
(add-hook 'before-save-hook 'gofmt-before-save)

(use-package company-go
  :ensure t
  :init
  (add-hook 'go-mode-hook (lambda ()
                          (set (make-local-variable 'company-backends) '(company-go))
                          (company-mode))))

(setq company-tooltip-limit 20)                      ; bigger popup window
(setq company-idle-delay .3)                         ; decrease delay before autocompletion popup shows
(setq company-echo-delay 0)                          ; remove annoying blinking
(setq company-begin-commands '(self-insert-command)) ; start autocompletion only after typing

(use-package emmet-mode :ensure t)
 (defun add-emmet-expand-to-smart-tab-completions ()
  ;; Add an entry for current major mode in
  ;; `smart-tab-completion-functions-alist' to use
  ;; `emmet-expand-line'.
  (add-to-list 'smart-tab-completion-functions-alist
	       (cons major-mode #'emmet-expand-line)))   

(add-hook 'html-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'html-mode-hook 'emmet-preview-mode) ;; Auto-start on any markup modes
;;(add-hook 'html-mode-hook 'add-emmet-expand-to-smart-tab-completions)
(add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation.
(add-hook 'css-mode-hook 'emmet-preview-mode) ;; Auto-start on any markup modes
;;(add-hook 'css-mode-hook 'add-emmet-expand-to-smart-tab-completions)

(use-package groovy-mode :ensure t)

(use-package kotlin-mode :ensure t)

(use-package protobuf-mode :ensure t)

(use-package typescript-mode :ensure t)

(use-package json-mode :ensure t)
(use-package json-reformat :ensure t)

(use-package yaml-mode :ensure t)

(use-package docker :ensure t)
(use-package docker-tramp :ensure t)
(use-package dockerfile-mode :ensure t)

(use-package kubernetes :ensure t)
(use-package kubernetes-evil :ensure t)
(use-package kubernetes-tramp :ensure t)

(use-package python-mode :ensure t)
(use-package pyenv-mode :ensure t)
(use-package anaconda-mode :ensure t)
(use-package company-anaconda :ensure t)
