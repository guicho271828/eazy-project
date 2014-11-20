(in-package :eazy-project)

(cl-syntax:use-syntax :annot)


@export
(define-symbol-macro ! (launch-menu))


;; note that ep-menu should be defined before compiling this file



@export
(defun launch-menu ()
  "launch the menu."
  (restart-case
      (invoke-menu 'ep-main)
    (:reload-menu ()
      :report "Reload the menu (for development)"
      :test (lambda (c) (typep c 'ask))
      t)))

