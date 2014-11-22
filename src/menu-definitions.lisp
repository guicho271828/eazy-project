
(in-package :eazy-project)

(cl-syntax:use-syntax :annot)

(defvar *project-config* nil
  "stores project-local information.")

;;; main menu

(defmenu (ep-main)
  (format t "~@[Resetting the current project config~%~]"
          *project-config*)
  (setf *project-config* nil)
  (ask "What to do next?~2%Here are current default configs:
~{~20@<~s~> = ~s~%~}"
       *config*))

;;; utilities

(defmacro qif ((var) then &optional (else '(q "~%Cancelled.~%")))
  "Read a line from *query-io*, bind it to var, then if it is non-empty string run `then'.
else, run `else'."
  `(let ((,var (read-line *query-io*)))
     (if (plusp (length ,var))
         ,then
         ,else)))
(defun q (format-control &rest format-arguments)
  (terpri *query-io*)
  (apply #'format *query-io* format-control
         format-arguments))

(defmacro g (key)
  "get/set the global configuration data"
  `(getf *config* ,key))
(defmacro l (key)
  "get/set the project local configuration data"
  `(getf *project-config* ,key))


(defun toggle-global (key)
  "Toggle a global config (T <-> NIL)"
  (q "~:[En~;Dis~]abling ~a..." (g key) key)
  (setf (g key) (not (g key))))

