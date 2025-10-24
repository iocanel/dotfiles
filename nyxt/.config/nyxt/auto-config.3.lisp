(define-configuration (input-buffer)
  ((default-modes (pushnew 'nyxt/mode/vi:vi-normal-mode %slot-value%))))

(define-configuration (prompt-buffer)
  ((default-modes (pushnew 'nyxt/mode/vi:vi-insert-mode %slot-value%))))
