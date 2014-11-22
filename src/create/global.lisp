(in-package :eazy-project)

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

