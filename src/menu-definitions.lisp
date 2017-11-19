
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
  "Read a line from *query-io*, bind it to var, then if it is a non-empty string run `then'.
Else, run `else'."
  `(let ((,var (or (pop *menu-arguments*) ;; when called programatically
                   (read-line *query-io*))))
     (if (plusp (length ,var))
         ,then
         ,else)))
(defun q (format-control &rest format-arguments)
  "Shortcut for (format *query-io* format-control format-arguments...) .
Newline is always inserted in the beginning."
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


(defun update-config-item (what new &optional local (how #'equalp))
  (unless (funcall how new (if local (l what) (g what)))
    (setf *recent-change* what)
    (q "Updated the information of ~a: ~2%~a ~%-> ~a~2%~
        Select other options again in the debugger menu. Thank you.~%"
       what (if local (l what) (g what)) new)
    (if local
        (setf (l what) new)
        (setf (g what) new))
    (unless local
      (save-config))))

(defun print-config-update-direction (what &optional local)
  "Print the current value, then print the direction for how to enter/cancel the input."
  (q "~%~20@<Current:~> ~A~%~20@<Empty Line:~> cancel~%> "
     (getf (if local *project-config* *config*) what "")))
