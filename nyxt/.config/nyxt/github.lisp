(in-package #:nyxt-user)

(defvar github-fork-org "iocanel" "The repository to use for forks")
(defvar github-checkout-base-path "/home/iocanel/workspace/src/github.com/" "The base path to checkout projects from github.")

(defun github-current-user ()
  "Get the curently logged in user."
  (let ((page-source (if (web-buffer-p (current-buffer))
                         (plump:serialize (document-model (current-buffer)) nil)
                         (ffi-buffer-get-document (current-buffer)))))
    (ppcre:register-groups-bind (user) (".*<meta name=\"user-login\" content=\"([a-zA-Z0-9_.-]+)\">.*" page-source) user)))

(define-command github-issues-new ()
  "Show all issues assigned to me."
  (let ((current-url (render-url (url (current-buffer)))))
    (ppcre:register-groups-bind (org repo) ("https://github.com/([a-zA-Z0-9_.-]+)/([a-zA-Z0-9_.-]+).*" current-url)
                                (buffer-load (concatenate 'string "https://github.com/" org "/" repo "/issues/new/")))))

(define-command github-issues-assigned ()
  "Show all issues assigned to me."
  (let ((current-url (render-url (url (current-buffer)))))
    (ppcre:register-groups-bind (org repo) ("https://github.com/([a-zA-Z0-9_.-]+)/([a-zA-Z0-9_.-]+).*" current-url)
                                (buffer-load (concatenate 'string "https://github.com/" org "/" repo "/issues/assigned/" (github-current-user))))))
                                
(define-command github-pulls-authored ()
  "Show all issues assigned to me."
  (let ((current-url (render-url (url (current-buffer)))))
    (ppcre:register-groups-bind (org repo) ("https://github.com/([a-zA-Z0-9_.-]+)/([a-zA-Z0-9_.-]+).*" current-url)
                                (buffer-load (concatenate 'string "https://github.com/" org "/" repo "/pulls/" (github-current-user))))))

(define-command github-open-in-gitpod ()
  "Open the target project in gitpod."
 (let ((current-url (render-url (url (current-buffer)))))
    (ppcre:register-groups-bind (org repo) ("https://github.com/([a-zA-Z0-9_.-]+)/([a-zA-Z0-9_.-]+).*" current-url)
                                (buffer-load (concatenate 'string
                                                          "https://gitpod.io/#ORG=" org ",PROJECT=" repo ",PROFILE=doom/https://github.com/emacs-lsp/lsp-gitpod")))))

(define-command github-goto-fork ()
  "Go to my fork repository."
  (let ((current-url (render-url (url (current-buffer))))
        (f (or github-fork-org (github-current-user))))
    (ppcre:register-groups-bind (org repo) ("https://github.com/([a-zA-Z0-9_.-]+)/([a-zA-Z0-9_.-]+).*" current-url)
                                (buffer-load (concatenate 'string "https://github.com/" f "/" repo)))))

    
(define-command github-checkout-project ()
  "Checkout project locally."
  (let ((current-url (render-url (url (current-buffer)))))
    (ppcre:register-groups-bind (org repo) ("https://github.com/([a-zA-Z0-9_.-]+)/([a-zA-Z0-9_.-]+).*" current-url)
                                (let* ((org-path (concatenate 'string github-checkout-base-path  org))
                                      (repo-path (concatenate 'string org-path "/" repo))
                                      (clone-url (concatenate 'string "git@github.com:" org "/" repo ".git"))
                                      (mkdir-command (list "mkdir" "-p" org-path))
                                      (clone-command (list "git" "clone" clone-url repo-path)))
                                  (log:info clone-url repo-path)
                                  (uiop:run-program mkdir-command)
                                  (multiple-value-bind (output error-output exit-code) (uiop:run-program clone-command :force-shell t :ignore-error-status t :output :string :error-output :string)
                                    (if (= 0 exit-code)
                                        (log:info output)
                                        (log:error error-output)))))))

(defvar github-keymap (make-keymap "github-keymap") "Keymap for `github-mode`.")
(define-key github-keymap "C-x i n" 'github-issues-new)
(define-key github-keymap "C-x i a" 'github-issues-assigned)
(define-key github-keymap "C-x p a" 'github-pulls-authored)
(define-key github-keymap "C-x c p" 'github-checkout-project)
(define-key github-keymap "C-x o g" 'github-open-in-gitpod)
(define-key github-keymap "C-x g f" 'github-goto-fork)

(define-mode github-mode ()
  "Dummy mode for the custom key bindings in github-keymap."
  ((keyscheme-map
    (nkeymaps/core:make-keyscheme-map nyxt/keyscheme:cua github-keymap
                                      nyxt/keyscheme:emacs github-keymap
                                      nyxt/keyscheme:vi-normal
                                      github-keymap))))
