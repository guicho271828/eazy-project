
(in-package :eazy-project)

(cl-syntax:use-syntax :annot)


;; main menu

(defmenu (ep-main)
  )


(defmenu (set-local-repo :in ep-main)
  (format *query-io*
          "~&Enter the directory where a new project is created.~% Current:~A~% empty line: cancel"
          *local-repo*)
  (let ((read (read-line *query-io*)))
    (if (plusp (length read))
        (setf *local-repo* (pathname read))
        (format *query-io* "~&Cancelled."))))

(defmenu (initialize-repo :in ep-main)
  )
(defmenu (initialize-local-repo :in ep-main)
  )
(defmenu (initialize-local-repo :in ep-main)
  )



(defmenu (initialize-git :in post-init
                         :title "Initialize git")
  (shell-command "git init")
  (shell-command "git add *"))
