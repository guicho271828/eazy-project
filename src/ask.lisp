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
                      format-control
                      #-(or swank sbcl)
                      "~2&Available Actions:~%~:{~20@<~a: [~a]~> ~a~%~}")
         :format-arguments
         `(,*current-menu*
           ,@args
           #-(or swank sbcl)
           ,(let ((rs (compute-restarts)))
                 (mapcar (lambda (i r) (list i (restart-name r) r))
                         (iota (length rs)) rs)))))

(defun askp (c)
  (typep c 'ask))
