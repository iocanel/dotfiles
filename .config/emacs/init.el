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

;; Load quickmarks
(load-file (expand-file-name "~/.config/emacs/quickmarks.el"))
;;
;; Generated Stuff
;;

(provide 'init)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["black" "red3" "#528369" "#c57632" "#2a86a9" "#9876aa" "blue" "gray90"])
 '(company-dabbrev-code-modes
   (quote
    (batch-file-mode csharp-mode css-mode erlang-mode haskell-mode jde-mode lua-mode python-mode)))
 '(company-dabbrev-downcase nil)
 '(flycheck-display-errors-function (quote flycheck-pos-tip-error-messages))
 '(flycheck-indication-mode (quote right-fringe))
 '(global-flycheck-mode t)
 '(idee-meghanada-completion-enabled t)
 '(idee-meghanada-enabled nil)
 '(meghanada-cache-in-project t)
 '(package-selected-packages
   (quote
    (el-get org-contrib-plus nlinum-relative nilum-relative shackle magithub org-tempo anki-mode anki-editor lsp-java moom org-tree-slide demo-it beacon wsd-mode hide-mode-line org-present eyebrowse flx counsel highlight-parentheses neotree git-gutter-fringe+ minimap rainbow-mode evil-smartparens smartparens ivy-hydra ob-sml git-timemachine camcorder meghanada ag bui tree-mode gist treemacs-evil org-gcal lsp-intellij yasnippet-snippets yaml-mode winum which-key visual-fill-column virtualenvwrapper use-package tss tide sx swiper sudo-edit spaceline smex smart-tab realgud rainbow-delimiters python-mode pytest pyenv-mode protobuf-mode popup-kill-ring paredit ox-reveal ox-gfm ox-asciidoc ov org2blog org-evil org-bullets ob-typescript ob-go ng2-mode multi-term mu4e-alert mark-multiple linum-relative latex-preview-pane kubernetes-tramp kubernetes-evil kotlin-mode js2-mode ido-vertical-mode http-post-simple groovy-mode google-c-style go-snippets go-imports github-pullrequest github-issues git-gutter-fringe frame-local flycheck-pos-tip flycheck-clojure flx-ido expand-region eww-lnum evil-mu4e evil-magit evil-leader esh-autosuggest emmet-mode eide editorconfig dockerfile-mode docker dashboard company-jedi company-go company-anaconda auth-source-pass auctex ace-link))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(lsp-intellij-face-code-lens-run ((t (:background "#262626")))))
