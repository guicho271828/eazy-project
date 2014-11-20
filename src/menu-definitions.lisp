
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
       (setf *local-repo* (pathname str))))

(defvar *options*)
(defmenu (create-project :in ep-main
                         :message "Create a new project.")
  (let ((*options* nil))
    (ask "Select and enter the information, then select 'CREATE'.")))

(defmenu (set-name :in create-project)
  (q "Enter the name. Current: ~A
      Empty Line: cancel~%"
     (getf *options* :name ""))
  (qif (str)
       (setf (getf *options* :name) str))
  (up))

(defmenu (initialize-local-repo :in ep-main)
  )



(defmenu (initialize-git :in post-init
                         :message "Initialize git")
  (shell-command "git init")
  (shell-command "git add *"))
