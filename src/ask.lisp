(in-package :eazy-project)

(cl-syntax:use-syntax :annot)

@export
(define-condition ask (simple-error) ()
  (:report "Select from the restart menu below."))
(defun ask (format-control &rest args)
  (error 'ask
         :format-control format-control
         :format-arguments args))
