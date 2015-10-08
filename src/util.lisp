(in-package :eazy-project)

(defun shell-command (command)
  (uiop:run-program `("sh" "-c" ,command) :ignore-error-status t :output :string))

