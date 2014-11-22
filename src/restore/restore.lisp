
(in-package :eazy-project)


(defmenu (session
          :in ep-main
          :message "Save/Restore the currently loaded libraries")
  (ask "What to do next?"))

(defmenu (restore
          :in ep-main
          :message "Restore the past loaded session")
  (format t "~&[Restoring the session....]~%")
  (mapc #'asdf:load-system
        (remove "eazy-project" (g :session.systems)
                :test #'search))
  (setf *package* (find-package (g :session.package)))
  (format t "~&Done! Happy Hacking!~2%")
  (quit-menu))

(defmenu (save :in session
               :message "Save the current loaded session")
  (save-session))

(defun save-session ()
  (if (and (string= (package-name *package*)
                    (g :session.package))
           (set-equal (asdf:already-loaded-systems)
                      (g :session.systems)
                      :test #'string=))
      (progn
        (format t "~& [Session Unchanged! Doubling the watch time...]~%")
        nil)
      (progn
        (update-config-item :session.package (package-name *package*))
        (update-config-item :session.systems (asdf:already-loaded-systems))
        (format t "~& [Session Saved!]")
        t)))

(defmenu (add-default-system :in session)
  (q "Enter a name of a library. The input string is converted to a keyword.
Example:   oSiCaT   -->  finally appears as :OSICAT")
  (print-config-update-direction :session.systems)
  (qif (str)
       (update-config-item
        :session.systems
        (union
         (list (intern (string-upcase str)
                       (find-package "KEYWORD")))
         (g :session.systems))))
  (up))

(defvar *main-thread*)
(defmenu (toggle-watch
          :in session
          :message "Watch and automatically save the session")
  (asdf:load-system :eazy-project.watch)
  (toggle-global :session.watch)
  (update-config-item :session.watch.min
                      (or (g :session.watch.min) 30))
  (update-config-item :session.watch.max
                      (or (g :session.watch.max) 180))
  (try-initiate-watch)
  (quit-menu))

(defun try-initiate-watch ()
  (when (g :session.watch)
    (enable-watch)))

(try-initiate-watch)
