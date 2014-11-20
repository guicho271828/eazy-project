
(in-package :eazy-project)

(cl-syntax:use-syntax :annot)

@export
(defmacro with-menus-in ((main-menu-name) &body body)
  (assert (symbolp main-menu-name))
  ;(register-main-menu main-menu-name)
  `(progn
     (defmenu (,main-menu-name) ,@body)
     (,main-menu-name)))

;; ;; test


;; (defparameter *thing* :a)
;; (defmacro expand () `(progn ,*thing*))
;; (defun test1 ()
;;   (expand))
;; (print (eq :a (test1)))
;; (defparameter *thing* :b)
;; (compile 'test1 (function-lambda-expression #'test1))
;; (print (eq :a (test1)))
