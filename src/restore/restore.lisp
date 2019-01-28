
(in-package :eazy-project)


(defmenu (session :in ep-main :message "Save/Restore the currently loaded libraries")
  (ask "What to do next?"))

(defmenu (restore :in ep-main :message "Restore the past loaded session")
  (format t "~&[Restoring the session....]~%")
  (try-initiate-watch)
  (mapc #'asdf:load-system (g :session.systems))
  (if (g :session.package)
      (progn
        (setf *future-package* (find-package (g :session.package)))
        (format t "~&[Done.]~2%"))
      (format t "~&[No saved session found. To save a session, go EP-MENU > SESSION > SAVE]~2%"))
  (quit-menu))

(defmenu (save :in session :message "Save the current loaded session")
  (save-session)
  (quit-menu))

(defun save-session ()
  (if (and (string= (package-name *package*)
                    (g :session.package))
           (set-equal (implementation-independent-systems)
                      (g :session.systems)
                      :test #'string=))
      (progn
        (format t "~& [Session Unchanged! Doubling the watch interval to avoid clutter (max ~a)]~%"
                (g :session.watch.max))
        nil)
      (progn
        (update-config-item :session.package (package-name *package*))
        (update-config-item :session.systems (asdf:already-loaded-systems))
        (format t "~& [Session Saved! Resetting the watch interval to ~a]~%"
                (g :session.watch.min))
        t)))

(defun implementation-independent-systems ()
  (remove-if (lambda (str)
               (typep (asdf:find-system str) 'asdf:require-system))
             (asdf:already-loaded-systems)))

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

(defmenu (reset-default-system :in session)
  (print-config-update-direction :session.systems)
  (qif (str)
       (update-config-item :session.systems nil))
  (up))

(defvar *main-thread*)
(defmenu (toggle-watch :in session :message "Watch and automatically save the session")
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

