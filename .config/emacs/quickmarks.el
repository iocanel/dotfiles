;;; quickmarks.el --- Quickmarks



;; Author: Ioannis Canellos

;; Version: 0.0.1

;; Package-Requires: ((emacs "25.1"))

;;; Commentary:

;;; Code:

(defvar quickmarks-alist '() "A list of labeled links for quick access")
(setq quickmarks-alist '(
                         ;; emacs
                         (markdown . https://en.wikipedia.org/wiki/Markdown)
                         (org-mode . https://orgmode.org)
                         (emacs . http://emacs.org)
                         (spacemacs . http://spacemacs.org)
                         (yasnippets . https://github.com/joaotavora/yasnippet)
                         ;; linux
                         (dotfiles . https://github.com/iocanel/dotfiles)
                         (i3 . https://i3wm.org)
                         (mutt . http://www.mutt.org)
                         (weechat . https://weechat.org)
                         (qutebrowser . https://qutebrowser.org)
                         (ranger . https://github.com/ranger/ranger)
                         ;; work
                         (docker . https://docker.io)
                         (fabric8 . https://fabric8.io)
                         (kubernetes . https://kubernetes.io)
                         (openshift . https://openshift.com)
                         (snowdrop . https://snowdrop.me)
                         (spring . https://spring.io)
                         (spring cloud . https://cloud.spring.io)
                         (spring boot . https://spring.io/projects/spring-boot)
                         (spring cloud connectors . https://cloud.spring.io/spring-cloud-connectors)
                         (jenkins . https://jenkins.io)
                         )
      )

(defun quickmarks-get (k)
  "Get the value of the quickmark with the key K."
  (alist-get (intern k) quickmarks-alist)
  )

(provide 'quickmarks)
;;; quickmarks.el ends here
