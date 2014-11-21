(in-package :eazy-project)

(cl-syntax:use-syntax :annot)

@export
(define-condition ask (simple-error) ())

(defun ask (&optional
              (format-control
               "Select from the restart menu below.")
            &rest args)
  (error 'ask
         :format-control
         (concatenate 'string 
                      "(You are now in menu ~a.)~%"
                      format-control)
         :format-arguments
         (cons *current-menu* args)))

(defun askp (c)
  (typep c 'ask))
