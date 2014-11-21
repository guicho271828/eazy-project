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
    (:quit-session ()
      :report "Quit this session."
      )))


@export
(defun quit-session ()
  (invoke-restart (find-restart :quit-session)))

