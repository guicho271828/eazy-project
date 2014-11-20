(in-package :eazy-project)

(cl-syntax:use-syntax :annot)


@export
(define-symbol-macro ! (launch-menu))


;; note that ep-menu should be defined before compiling this file

@export
(defun launch-menu ()
  "launch the menu."
  (restart-case
      (iter
        (with-menus-in (ep-menu)
          (ask "What to do next?")))
    (:quit-session ()
      :report "Quit session."
      :test (lambda (c) (typep c 'ask))
      t)))


