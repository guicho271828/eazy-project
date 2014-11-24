(in-package :eazy-project)

(cl-syntax:use-syntax :annot)

(defvar *skeleton-directory*
  #.(asdf:system-relative-pathname
     :eazy-project
     #p"skeleton"))

(defun ok (str)
  (plusp (length str)))

(defvar *author*
    (find-if #'ok
             (mapcar (curry #'remove #\Newline)
                     (list (shell-command "git config --global --get user.name")
                           (shell-command "whoami")))))

(defvar *email*
    (find-if #'ok
             (mapcar (curry #'remove #\Newline)
                     (list (shell-command "git config --global --get user.email")
                           (shell-command "echo $(whoami)@$(hostname)")))))

(defvar *local-repository*
  (or
   (ignore-errors 
     (first (eval (read-from-string
                   "ql:*local-project-directories*"))))
   *default-pathname-defaults*))

(defvar *config-path*
  (asdf:system-relative-pathname
   :eazy-project
   "default-config.lisp"))

@export
(defun save-config ()
  (format t "~& [Saving the default config to ~a]~%"
          *config-path*)
  (handler-bind ((error (lambda (c)
                          @ignore c
                          (when (probe-file *config-path*)
                            (delete-file *config-path*)))))
    (with-open-file (s *config-path*
                       :direction :output
                       :if-exists :supersede)

      (prin1 (or *config*
                 (list :local-repository *local-repository*
                       :skeleton-directory *skeleton-directory*
                       :author *author*
                       :email *email*
                       :git t
                       :readme-extension "md"
                       :source-dir "src"
                       :test-dir "t"
                       :test-subname "test"
                       :delimiter "."
                       :license "LLGPL"
                       :test :fiveam
                       :depends-on '(:alexandria :iterate)
                       :session.watch.max 300
                       :session.watch.min 30))
             s))))

@export
(defun read-config ()
  (block nil
    (tagbody
     :start
       (format t "~& [loading the default config from ~a]~%"
               *config-path*)
       (handler-case
           (with-open-file (s *config-path*
                              :if-does-not-exist :error)
             (return-from nil
               (handler-case
                   (read s)
                 (error (c)
                   @ignore c
                   (format *error-output* "~&Syntax error found in ~a, replacing with the default settings"
                           *config-path*)
                   (let ((old (make-pathname :type "old" :defaults *config-path*)))
                     (format *error-output* "~&Erroneous file is moved to ~a"
                             old)
                     (shell-command (format nil "mv ~a ~a" *config-path* old)))
                   (go :start)))))
         (file-error (c)
           @ignore c
           (format *error-output* "~&File not found in ~a, writing the default settings"
                   *config-path*)
           (save-config)
           ;; retry
           (go :start))))))

@export
(defun clear-config ()
  (ignore-errors
    (delete-file *config-path*))
  (load-config))

@export
(defvar *config* nil)

@export
(defun load-config ()
  (setf *config* (read-config)))

(load-config)
