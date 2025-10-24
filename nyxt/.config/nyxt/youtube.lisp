(in-package #:nyxt-user)

(defvar youtube-download-base-path "/home/iocanel/Downloads/Youtube/" "The base path to download videos from youtube.")

(define-command youtube-download-audio ()
  "Download audio locally and notify when done."
  (let* ((current-url (render-url (url (current-buffer)))) 
         (download-command (list "yt-dlp" "--audio-format" "mp3" "--audio-quality" "0" 
                                 "-P" youtube-download-base-path current-url)))
    (uiop:run-program (list "notify-send" "-a" "Nyxt" "Downaloding audio" current-url))
    (multiple-value-bind (status _output _error) (uiop:run-program download-command :output t :error-output t)
      (if (zerop status)
          (uiop:run-program (list "notify-send" "-a" "Nyxt" "Download completed!" (format nil "Audio download was successful: ~a" current-url)))
        (uiop:run-program (list "notify-send" "-a" "Nyxt" "Download failed!" 
                                (format nil "An error occurred during the audio download: ~a" current-url)))))))

(define-command youtube-download-video ()
  "Download video locally and notify when done."
  (let* ((current-url (render-url (url (current-buffer)))) 
         (download-command (list "yt-dlp" "-P" youtube-download-base-path current-url)))
    (uiop:run-program (list "notify-send" "-a" "Nyxt" "Downaloding audio" current-url))
    (multiple-value-bind (status _output _error) (uiop:run-program download-command :output t :error-output t)
      (if (zerop status)
          (uiop:run-program (list "notify-send" "-a" "Nyxt" "Download completed!" 
                                  (format nil "Video download was successful: ~a" current-url)))
        (uiop:run-program (list "notify-send" "-a" "Nyxt" "Download failed!" 
                                (format nil "An error occurred during the video download: ~a" current-url)))))))

(defvar youtube-keymap (make-keymap "youtube-keymap") "Keymap for `youtube-mode`.")

;;(define-bookmarklet-command youtube-play-toggle
;;    "Play/Pause youtube videos."
;;  "document.getElementsByClassName('ytp-play-button')[0].click();")

;;(define-key youtube-keymap "C-x p" 'youtube-play-toggle)
(define-key youtube-keymap "d a" 'youtube-download-audio)
(define-key youtube-keymap "d v" 'youtube-download-video)

(define-mode youtube-mode ()
  "Dummy mode for the custom key bindings in youtube-keymap."
  ((keyscheme-map
    (nkeymaps/core:make-keyscheme-map nyxt/keyscheme:cua youtube-keymap
                                      nyxt/keyscheme:emacs youtube-keymap
                                      nyxt/keyscheme:vi-normal
                                      youtube-keymap))))
