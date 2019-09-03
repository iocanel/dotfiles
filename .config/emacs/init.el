(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

; Garbage collector
(setq gc-cons-threshold most-positive-fixnum  gc-cons-percentage 1)
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold 16777216 gc-cons-percentage 0.1)))
(add-hook 'minibuffer-setup-hook (lambda () (setq gc-cons-threshold most-positive-fixnum gc-cons-percentage 1)))
(add-hook 'minibuffer-exit-hook (lambda () (setq gc-cons-threshold 16777216 gc-cons-percentage 0.1)))


 ;; Install straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Use package integration
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq straight-check-for-modifications 'never)

(use-package org :straight t)
(straight-use-package '(org :type built-in))

;; Load the literate configuration
(org-babel-load-file (expand-file-name "~/.config/emacs/config.org"))

;; Load configuration
;; (load-file (expand-file-name "~/.config/emacs/modules/core.el"))
;; (load-file (expand-file-name "~/.config/emacs/modules/evil.el"))
;; (load-file (expand-file-name "~/.config/emacs/modules/editor.el"))
;; (load-file (expand-file-name "~/.config/emacs/modules/ui.el"))
;; (load-file (expand-file-name "~/.config/emacs/modules/term.el"))
;; (load-file (expand-file-name "~/.config/emacs/modules/vcs.el"))
;; (load-file (expand-file-name "~/.config/emacs/modules/lang/java.el"))
;; (load-file (expand-file-name "~/.config/emacs/modules/lang/go.el"))

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
 '(company-backends
   (quote
    (company-tide company-lsp
                      (company-bbdb :with company-yasnippet)
                      (company-semantic :with company-yasnippet)
                      (company-clang :with company-yasnippet)
                      (company-xcode :with company-yasnippet)
                      (company-cmake :with company-yasnippet)
                      (company-capf :with company-yasnippet)
                      (company-files :with company-yasnippet)
                      (company-dabbrev-code company-gtags company-etags company-keywords :with company-yasnippet)
                      (company-oddmuse :with company-yasnippet))))
 '(company-dabbrev-code-modes
   (quote
    (batch-file-mode csharp-mode css-mode erlang-mode haskell-mode jde-mode lua-mode python-mode)))
 '(company-dabbrev-downcase nil)
 '(compilation-error-regexp-alist (quote (maven)))
 '(compilation-read-command nil)
 '(custom-safe-themes
   (quote
    ("d1b4990bd599f5e2186c3f75769a2c5334063e9e541e37514942c27975700370" "6b289bab28a7e511f9c54496be647dc60f5bd8f9917c9495978762b99d8c96a0" "d2e9c7e31e574bf38f4b0fb927aaff20c1e5f92f72001102758005e53d77b8c9" "a3fa4abaf08cc169b61dea8f6df1bbe4123ec1d2afeb01c17e11fdc31fc66379" "93a0885d5f46d2aeac12bf6be1754faa7d5e28b27926b8aa812840fe7d0b7983" "1c082c9b84449e54af757bcae23617d11f563fc9f33a832a8a2813c4d7dfb652" "7e78a1030293619094ea6ae80a7579a562068087080e01c2b8b503b27900165c" "75d3dde259ce79660bac8e9e237b55674b910b470f313cdf4b019230d01a982a" "4697a2d4afca3f5ed4fdf5f715e36a6cac5c6154e105f3596b44a4874ae52c45" "6b2636879127bf6124ce541b1b2824800afc49c6ccd65439d6eb987dbf200c36" "8aca557e9a17174d8f847fb02870cb2bb67f3b6e808e46c0e54a44e3e18e1020" "bf390ecb203806cbe351b966a88fc3036f3ff68cd2547db6ee3676e87327b311" "333ba26ea27e9fd1093ca755fa838d7774a88fe073980408134b9f8d5958c1f2" "e0c66085db350558f90f676e5a51c825cb1e0622020eeda6c573b07cb8d44be5" default)))
 '(demo-it--insert-text-speed :faster)
 '(doom-modeline-mode t)
 '(flycheck-display-errors-function (quote flycheck-pos-tip-error-messages))
 '(flycheck-indication-mode (quote right-fringe))
 '(global-flycheck-mode t)
 '(idee-eshell-demo-it-enabled t)
 '(idee-eshell-demo-it-speed :faster)
 '(idee-meghanada-completion-enabled t)
 '(idee-meghanada-enabled nil)
 '(idee-quarkus-remote-dev-url "http://hello-world-iocanel.195.201.87.126.nip.io")
 '(idee-quarkus-version "0.16.1")
 '(meghanada-cache-in-project t)
 '(swiper-action-recenter t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(dap-ui-pending-breakpoint-face ((t (:foreground "white"))))
 '(lsp-intellij-face-code-lens-run ((t (:background "#262626"))))
 '(magit-header-line ((t (:box nil :weight bold))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "#e78779"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "#a9b6c1"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "#528369"))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "#c57632"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "#3e86a0"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "#e78779"))))
 '(rainbow-delimiters-depth-7-face ((t (:foreground "#a9b6c1"))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "#528369"))))
 '(rainbow-delimiters-depth-9-face ((t (:foreground "#c57632"))))
 '(rainbow-delimiters-unmatched-face ((t (:background "red")))))
(put 'dired-find-alternate-file 'disabled nil)
(put 'erase-buffer 'disabled nil)
(put 'narrow-to-region 'disabled nil)
