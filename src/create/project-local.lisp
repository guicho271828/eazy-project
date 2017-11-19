(in-package :eazy-project)

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
             `(defmenu (,(intern (symbol-name what)) :in create-project)
                ,(if control
                     `(q ,control)
                     `(q "Enter the ~a information." ,what))
                (print-config-update-direction ,what t)
                (qif (str)
                     (update-config-item ,what str t))
                (up))))
  (set-x :name
         "Enter the new project name, this affects the name of the
subfolder, asdf system name and the package name.")
  (set-x :description
         "Enter the short description of this library. Description
information is required for quicklisp submission, and missing this
information annoyes Xach because he has to ask you to add that information
each time.")
  (set-x :homepage
         "Enter the homepage URL of this library.")
  (set-x :bug-tracker
         "Enter URL under which a user can open bugs for this library."))

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
         (l :depends-on))
        t))
  (up))

(defmenu (add-local-defsystem-dependency :in create-project)
  (q "Enter a name of a library. The input string is converted to a keyword.
Example:   cFfI   -->  finally appears as :CFFI")
  (print-config-update-direction :defsystem-depends-on t)
  (qif (str)
       (update-config-item
        :defsystem-depends-on
        (union
         (list (intern (string-upcase str)
                       (find-package "KEYWORD")))
         (l :defsystem-depends-on))
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
  (quit-menu))

(defmenu (source-control :in create-project
                         :message "Provide the source code repository.")
  (q "Enter the the type of your versioning system together with the repository URL.
Example:
  git https://myhost.org/cgit/my-lib.git
  => :source-control (:git \"https://myhost.org/cgit/my-lib.git\")

If you host your library on Github or Gitlab you can use shortcuts for those services.
Use \"github\" or \"gitlab\" as versioning system type and the URL is \"username/repository\".
For both shortcuts the \":bug-tracker\" property will be added as well.
Example:
  github foo/foo
  => :source-control (:git \"https://github.com/foo/foo.git\")
     :bug-tracker \"https://github.com/foo/foo/issues\"

The Gitlab shortcut works analogous. ")
  (print-config-update-direction :source-control t)
  (qif (source-control)
       (destructuring-bind (type repo)
           (rest (split "(.*) (.*)" source-control :with-registers-p t))
         (match type
           ((or "github" "gitlab")
            (update-config-item
             :source-control
             (list :git
                   (format nil "https://~A.com/~A.git" type repo))
             t)
            (update-config-item
             :bug-tracker
             (format nil "https://~A.com/~A/issues" type repo)
             t))
           (otherwise
            (update-config-item
             :source-control
             (list (make-keyword (string-upcase type))
                   repo)
             t)))))
  (up))
