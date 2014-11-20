
(in-package :eazy-project)

(cl-syntax:use-syntax :annot)


;; main menu

(defmenu (ep-main)
  (iter (ask "What to do next?")))

(defmacro qif ((var) then &optional (else '(q "~%Cancelled.~%")))
  `(let ((,var (read-line *query-io*)))
     (if (plusp (length ,var))
         ,then
         ,else)))
(defun q (format-control &rest format-arguments)
  (terpri *query-io*)
  (apply #'format *query-io* format-control
         format-arguments))

;; submenus

(defmenu (set-local-repo
          :in ep-main
          :message
          "Enter the default directory where a new project is created.")
  (q "Enter the default directory where a new project is created.
      Current: ~A
      Empty Line: cancel~%" *local-repo*)
  (qif (str)
       (setf *local-repo* str))
  (up))

(defvar *options*)
(defmenu (create-project :in ep-main
                         :message "Create a new project.")
  (let ((*options* *default-options*))
    (ask "Select and enter the information, then select 'CREATE'.
Current configuration:
~{~20@<~a~> = ~a~%~}" *options*)))

(macrolet ((set-x (what)
             `(defmenu (,(symbolicate 'set- what) :in create-project)
                (q "Enter the ~a of the project. Current: ~A ~
                    Empty Line: cancel~%"
                   ,what
                   (getf *options* ,what ""))
                (qif (str) (setf (getf *options* ,what) str))
                (up))))
  (set-x :name)
  (set-x :author)
  (set-x :email))

(defmenu (add-dependency :in create-project)
  (q "Enter a name. Case is uppercaase-converted.
      Example:   oSiCaT   -->  finally appears as :OSICAT
      Empty Line: cancel~%"
     (getf *options* :name ""))
  (qif (str)
       (pushnew (intern str (find-package "KEYWORD"))
                (getf *options* :dependency)))
  (up))


(defmenu (select-test-library :in create-project)
  (ask "Select the library from below.
        If you are ok with the current one, then go back.
        Current: ~a" (getf *options* :test)))

(macrolet ((testlib (what)
             `(defmenu (,what :in select-test-library)
                (setf (getf *options* :test) ,what)
                (up))))
  (testlib :cl-test-more)
  (testlib :5am)
  (testlib :eos))

(defmenu (git :in create-project :message "Initialize git")
  (q "Enabling git...")
  (setf (getf *options* :git) t))


