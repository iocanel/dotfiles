(setq theme:font-family "JetBrains Mono Nerd Font Bold")
(setq theme:monospace-font-family "JetBrains Mono Nerd Font Bold")


(define-command my-toggle-status-buffer (w)
  "Toggle the status buffer."
  (echo "Hook running.")
  (toggle-status-buffer w)
  (echo "Status buffer toggled."))


;;(define-configuration browser
;;    ((window-make-hook (hooks:add-hook %slot-value% 'my-toggle-status-buffer))))
    
(define-configuration browser
  ((theme
    (make-instance 'theme:theme
                 :font-family "JetBrains Mono Nerd Font Bold"
                 :dark-p t
                 :background-color- "#313244" ; surface0
                 :background-color "#1e1e2e"  ; base
                 :background-color+ "#181825" ; mantle
                 :on-background-color "#cdd6f4" ; text

                 :primary-color- "#89B4FA"
                 :primary-color "#F5A97F"
                 :primary-color+ "#74C7EC"
                 :on-primary-color "#1E1E2E"

                 :secondary-color- "#45475A"
                 :secondary-color "#585B70"
                 :secondary-color+ "#6C7086"
                 :on-secondary-color "#D9E0EE"

                 :action-color "#313244"
                 :action-color+ "#6C7086"
                 :on-action-color "#F5A97F"

                 :success-color- "#A6E3A1"
                 :success-color "#B8CC8A"
                 :success-color+ "#9ECE6A"
                 :on-success-color "#1E1E2E"

                 :highlight-color- "#C9CBFF"
                 :highlight-color "#CDD6F4"
                 :highlight-color+ "#DDB6F2"
                 :on-highlight-color "#1E1E2E"

                 :warning-color- "#F9E2AF"
                 :warning-color "#F5A97F"
                 :on-warning-color "#1E1E2E"

                 :codeblock-color- "#CBA6F7"
                 :codeblock-color "#181825"
                 :codeblock-color+ "#F5E0DC"
                 :on-codeblock-color "#D9E0EE"))))


(define-configuration prompt-buffer
  ((style
    (theme:themed-css (theme *browser*)
  `(:font-face :font-family "JetBrains Mono Nerd Font Bold" :src ,(format nil "url('nyxt-resource:~a')" "JetBrainsMonoNerdFont-Bold.ttf") "format('ttf')")
  `(* :font-size "24px" :line-height "24px") 
  `(body :font-family ,theme:font-family :font-style "bold" :border-right "2px solid" :border-color ,theme:action :overflow "hidden" :margin "0" :padding "0")
  `("#prompt-area" :background-color ,theme:secondary :color ,theme:on-secondary :border-top "2px solid" :border-bottom "2px solid" :border-color ,theme:secondary :display "grid" :grid-template-columns "auto auto 1fr auto auto" :width "100%")
  `("#prompt" :background-color ,theme:secondary :color ,theme:on-secondary :padding-left "10px" :padding-right "8px" :line-height "28px")
  `("#prompt-input" :margin-right "-10px" :line-height "28px")
  `("#prompt-extra" :font-family ,theme:monospace-font-family :z-index "1" :min-width "12px" :padding-right 14px !important :background-color ,theme:secondary :color ,theme:on-primary :line-height "px" :padding-right "7px")
  `("#prompt-modes" :background-color ,theme:secondary :padding-left "10px !important" :padding-right "14px !important" :line-height "28px" :padding-left "3px" :padding-right "3px")
  `("#close-button" :text-align "right" :background-color ,theme:success :min-width "24px" :line-height "28px" :font-weight "bold" :font-size "20px")
  `(".arrow-right" :clip-path "polygon(0 0, calc(100% - 10px) 0, 100% calc(50% - 1px), 100% 50%, 100% calc(50% + 1px), calc(100% - 10px) 100%, 0 100%)" :margin-right "-10px")
  `(".arrow-left" :clip-path "polygon(10px 0, 100% 0, 100% 100%, 10px 100%, 0px calc(50% + 1px), 0% 50%, 0px calc(50% - 1px))" :margin-left "-10px")
  `(button :background "transparent" :color "inherit" :text-decoration "none" :border "none" :padding 0 :font "inherit" :outline "inherit")
  `(.button.action :background-color ,theme:action :color ,theme:on-action)
  `((:and .button :hover) :cursor "pointer" :color ,theme:action)
  `(".button:hover svg path" :stroke ,theme:action-)
  `((:and .button (:or :visited :active)) :color ,theme:background)
  `(input :font-family ,theme:monospace-font-family)
  `("#input" :height "28px" :margin-top "0" :margin-bottom "0" :padding-left "16px !important" :background-color ,theme:background :color ,theme:on-background :opacity 0.9 :border 2px solid ,theme:secondary :outline "none" :padding "3px" :width "100%" :autofocus "true")
  `("#input:focus" :border-color ,(cl-colors2:print-hex theme:action- :alpha 0.4)) `(".source" :margin-left "10px" :margin-top "15px")
  `(".source-name" :padding-left "4px" :background-color ,theme:secondary :color ,theme:on-secondary :display "flex" :justify-content "space-between" :align-items "stretch" :border-radius "2px")
  '(".source-name > div" :line-height "22px")
  `(".source-name > div > button" :padding "5px 5px 5px 0px" :min-height "100%")
  `("#next-source > svg, #previous-source > svg" :margin-bottom "2px" :height "5px")
  '("#previous-source" :padding 0)
  '("#next-source" :padding 0)
  `("#suggestions" :background-color ,theme:background :color ,theme:on-background :overflow-y "hidden" :overflow-x "hidden" :height "100%" :margin-right "3px")
  `(".suggestion-and-mark-count" :font-family ,theme:monospace-font-family)
  `(".source-content" :box-sizing "border-box" :padding-left "16px" :margin-left "2px" :width "100%" :table-layout "fixed" 
    (td :color ,theme:on-background :border-radius "2px" :white-space "nowrap" :height "20px" :padding-left "4px" :overflow "auto")
    ("tr:not(:first-child)" :font-family ,theme:monospace-font-family)
    ("tr:hover" :background-color ,theme:action- :color ,theme:on-action :cursor "pointer")
    (th :visibility "hidden" :line-height "0%" :background-color ,theme:secondary :color ,theme:on-primary :font-weight "normal" :padding-left "4px" :border-radius "2px" :text-align "left") ("td::-webkit-scrollbar" :display "none"))
  `("#selection" :background-color ,theme:action :color ,theme:on-action)
  `(.marked :background-color ,theme:secondary :color ,theme:on-secondary :font-weight "bold")
  `(.selected :background-color ,theme:primary :color ,theme:on-primary)))))

(define-configuration status-buffer
  ((style
     (theme:themed-css (theme *browser*)
       `(:font-face :font-family "JetBrains Mono Nerd Font Bold" :src ,(format nil "url('nyxt-resource:~a')" "JetBrainsMonoNerdFont-Bold.ttf") "format('ttf')")
       `(body :font-family ,theme:font-family :line-height "100vh" :font-size "24px" :padding 0 :margin 0)
       `(.loader :border-width "2px" :border-style "solid" :border-color "transparent" :border-top-color ,theme:action :border-left-color ,theme:action :border-radius "50%" :display "inline-block" :width "7px" :height "7px" :animation "spin 1s linear infinite")
       `("@keyframes spin" ("0%" :transform "rotate(0deg)") ("100%" :transform "rotate(360deg)")) `(".arrow-right" :clip-path "polygon(0 0, calc(100% - 7px) 0, 100% calc(50% - 1px), 100% 50%, 100% calc(50% + 1px), calc(100% - 7px) 100%, 0 100%)" :margin-right "-7px")
       `(".arrow-left" :clip-path "polygon(7px 0, 100% 0, 100% 100%, 7px 100%, 0px calc(50% + 1px), 0% 50%, 0px calc(50% - 1px))" :margin-left "-7px") `("#container" :display "flex" :justify-content "space-between" :overflow-y "hidden")
       `("#controls" :background-color ,theme:secondary :color ,theme:on-secondary :overflow "hidden" :white-space "nowrap" :z-index "3" :flex-basis "78px" :display "flex") `("#controls > button" :margin-right "-3px" :max-width "20px" :height "100%" :aspect-ratio "1/1")
       `("#url" :background-color ,theme:primary :color ,theme:on-primary :font-size "60vh" :min-width "100px" :text-overflow "ellipsis" :overflow-x "hidden" :white-space "nowrap" :padding-right "7px" :padding-left "15px" :z-index "2" :flex-grow "3" :flex-shrink "2" :flex-basis "144px")
       `("#url button" :text-align "left" :width "100%") `("#tabs" :background-color ,theme:secondary :color ,theme:on-secondary :line-height "95vh" :font-size "60vh" :min-width "100px" :white-space "nowrap" :overflow-x "scroll" :text-align "left" :padding-left "3px" :padding-right "20px" :z-index "1" :flex-grow "10" :flex-shrink "4" :flex-basis "144px")
       `("#tabs::-webkit-scrollbar" :display "none")
       `(".tab" :background-color ,theme:background- :color ,theme:on-background :display "inline-block" :margin-top "1px" :padding-left "18px" :padding-right "18px" :margin-right "-1px" :margin-left "-4px" :text-decoration "transparent" :border "transparent" :border-radius "1px" :font "inherit" :outline "inherit" :clip-path "polygon(calc(100% - 7px) 0, 100% calc(50% - 1px), 100% 50%, 100% calc(50% + 1px), calc(100% - 7px) 100%, 0% 100%, 7px calc(50% + 1px), 7px 50%, 7px calc(50% - 1px),  0% 0%)")
       `("#modes" :background-color ,theme:primary :color ,theme:on-primary :font-size "60vh" :text-align "right" :padding-left "7px" :padding-right "5px" :overflow-x "scroll" :white-space "nowrap" :z-index "2")
       `("#modes::-webkit-scrollbar" :display "none")
       `(button :background "transparent" :color "inherit" :text-decoration "transparent" :border "transparent" :border-radius "0.2em" :padding 0 :font "inherit" :outline "inherit")
       `((:and (:or .button .tab "#url") :hover) :cursor "pointer" :background-color ,theme:action :color ,theme:on-action)
       `((:and (:or .button .tab) :active) :background-color ,theme:action- :color ,theme:on-action)
       `(.selected-tab :background-color ,theme:background+ :color ,theme:on-background)))))
