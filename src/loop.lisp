(in-package :eazy-project)

(cl-syntax:use-syntax :annot)


@export
(define-symbol-macro ! (launch-menu))


;; note that ep-menu should be defined before compiling this file



@export
(defun launch-menu ()
  "launch the menu."
  (invoke-menu 'ep-main))

