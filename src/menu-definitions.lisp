
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

;;; submenus

;;;; global configurations

(defvar *recent-change* nil)
(defmenu (set-global
          :in ep-main
          :message "Modify these default values")
  (let ((lextmp *recent-change*))
    (setf *recent-change* nil)
    (ask "~@[*** ~a Configuration Updated!! ***~%~]
Select and enter the information.
When you are done, you can go up by selecting 'UP'.
Current configuration:
~{~20@<~s~> = ~s~%~}"
         lextmp
         *config*)
    ))

(defun update-config-item (what new &optional local)
  (progn
    (setf *recent-change* what)
    (q "Updated the information: ~2%~a ~%-> ~a~2%~
        Select other options again in the debugger menu. Thank you.~2%"
       (getf (if local *project-config* *config*) what) new)
    (if local
        (if *project-config*
            (setf (getf *project-config* what) new)
            (setf *project-config* (list what new)))
        (setf (getf *config* what) new))
    (unless local
      (save-config))))
(defun print-config-update-direction (what &optional local)
  (q "~%~20@<Current:~> ~A~%~20@<Empty Line:~> cancel~%> "
     (getf (if local *project-config* *config*) what "")))


(macrolet ((set-x (what &optional control)
             `(defmenu (,what :in set-global)
                ,(if control
                     `(q ,control)
                     `(q "Enter the ~a information." ,what))
                (print-config-update-direction ,what)
                (qif (str)
                     (update-config-item ,what str))
                (up))))
  (set-x :local-repository
         "Enter the location for a new project subdirectory.")
  (set-x :author)
  (set-x :email))

(defmenu (git :in set-global :message "Toggle git initialization")
  (q "~:[En~;Dis~]abling git..." (getf *config* :git))
  (setf (getf *config* :git)
        (not (getf *config* :git)))
  (up))


  (set-x :test
         )
(defmenu (add-dependency :in set-global)
  (q "Enter a name of a library. The input string is converted to a keyword.
Example:   oSiCaT   -->  finally appears as :OSICAT")
  (print-config-update-direction :depends-on)
  (qif (str)
       (update-config-item
        :depends-on
        (union
         (list (intern (string-upcase str)
                       (find-package "KEYWORD")))
         (getf *config* :depends-on))))
  (up))

(defmenu (test :in set-global)
  (q "Enter a name of the test library you'd like to use.
The input string is converted to a keyword.
  Example:   oSiCaT   -->  finally appears as :OSICAT")
  (print-config-update-direction :depends-on)
  (qif (str)
       (update-config-item
        :test (intern (string-upcase str)
                      (find-package "KEYWORD"))))
  (up))

;;;; project-local information

(defmenu (create-project :in ep-main
                         :message "Create a new project.")
  (ask "Select and enter the information, then select 'CREATE'.
Current global configuration:
~{~20@<~s~> = ~s~%~}
Current local configuration:
~:[(no configuration specified)~;~{~20@<~s~> = ~s~%~}~]~2%"
       *config* *project-config* *project-config*))

(macrolet ((set-x (what &optional control)
             `(defmenu (,what :in create-project)
                ,(if control
                     `(q ,control)
                     `(q "Enter the ~a information." ,what))
                (print-config-update-direction ,what t)
                (qif (str)
                     (update-config-item ,what str t))
                (up))))
  (set-x :name
         "Enter the new project name, this affects the name of the
subfolder, asdf system name and the package name."))

(defmenu (add-local-dependency :in create-project)
  (q "Enter a name of a library. The input string is converted to a keyword.
Example:   oSiCaT   -->  finally appears as :OSICAT")
  (print-config-update-direction :depends-on t)
  (qif (str)
       (update-config-item
        :depends-on
        (union
         (list (intern (string-upcase str)
                       (find-package "KEYWORD")))
         (getf *project-config* :depends-on))
        t))
  (up))

(defmenu (reset-local-config
          :in create-project
          :message "Reset the current local config")
  (q "Enter the name of a field. The input string is converted to a keyword.
Example:   oSiCaT   -->  finally appears as :OSICAT")
  (print-config-update-direction :depends-on t)
  (qif (str)
       (update-config-item
        (intern (string-upcase str)
                (find-package "KEYWORD"))
        nil t))
  (up))

(defmenu (create :in create-project)
  (actually-create-project)
  (quit-session))

