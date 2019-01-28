(in-package :eazy-project)

;;; main menu

(defmenu (ep-main)
  (format t "~@[Resetting the current project config~%~]"
          *project-config*)
  (setf *project-config* nil)
  (ask "What to do next?~2%Here are current default configs:
~{~20@<~s~> = ~s~%~}"
       *config*))

;;; global configurations

;; values should be stored through update-config-item,
;; which also handles saving the database.

(defvar *recent-change* nil)
(defmenu (set-global :in ep-main :message "Modify these default values")
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

(macrolet ((set-x (what &optional control)
             `(defmenu (,(intern (symbol-name what) :eazy-project) :in set-global)
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
  (set-x :license "Choose the default license")
  (set-x :email))

(defmenu (git :in set-global :message "Toggle git initialization")
  (toggle-global :git)
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
         (g :depends-on))))
  (up))

(defmenu (add-defsystem-dependency :in set-global)
  (q "Enter a name of a library. The input string is converted to a keyword.
Example:   oSiCaT   -->  finally appears as :OSICAT")
  (print-config-update-direction :defsystem-depends-on)
  (qif (str)
       (update-config-item
        :defsystem-depends-on
        (union
         (list (intern (string-upcase str)
                       (find-package "KEYWORD")))
         (g :defsystem-depends-on))))
  (up))


(defmenu (clear-dependency :in set-global :message "Clear the default dependency")
  (update-config-item :depends-on nil)
  (up))

(defmenu (clear-defsystem-dependency :in set-global :message "Clear the default dependency")
  (update-config-item :defsystem-depends-on nil)
  (up))

(defmenu (testing-library :in set-global :message "Change the default testing library")
  (q "Enter a name of the test library you'd like to use.
The input string is converted to a keyword.
  Example:   oSiCaT   -->  finally appears as :OSICAT")
  (print-config-update-direction :test)
  (qif (str)
       (update-config-item
        :test (intern (string-upcase str)
                      (find-package "KEYWORD"))))
  (up))

(defmenu (readme-extension :in set-global :message "Change the default README format")
  (q "supports 'org' or 'md'")
  (print-config-update-direction :readme-extension)
  (qif (str)
       (ematch str
         ((or "org" "md")
          (update-config-item :readme-extension str))
         (_ (q "'~a' is not a supported README extension, aborting."))))
  (up))
