(in-package :eazy-project)

(cl-syntax:use-syntax :annot)

(defun shell-command (command)
  (uiop:run-program `("sh" "-c" ,command) :ignore-error-status t :output :string))

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

@export
(defvar *config-path*
  (asdf:system-relative-pathname
   :eazy-project
   "default-config.lisp"))

@export
(defun save-config (&optional override-default)
  (format t "~%Saving the default config to ~a"
          *config-path*)
  (handler-bind ((error (lambda (c)
                          @ignore c
                          (when (probe-file *config-path*)
                            (delete-file *config-path*)))))
    (with-open-file (s *config-path*
                       :direction :output
                       :if-exists :supersede)
      (let ((*print-readably* t))
        (prin1 (or (and (not override-default) *config*)
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
               s)))))

@export
(defun read-config ()
  (terpri)
  (block nil
    (pprint-logical-block (*standard-output*
                           nil :per-line-prefix ";; ")
      (format *standard-output* "~%Loading the default config from ~a" *config-path*)
      (tagbody
       :start
         (restart-bind
             ((restore-default (lambda ()
                                 (format *standard-output* "~%Writing the default settings")
                                 (save-config t)
                                 (go :start)))
              (backup (lambda ()
                        (let ((old (make-pathname :type "old" :defaults *config-path*)))
                          (format *standard-output* "~%Making a backup of the erroneous file: ~a" old)
                          (shell-command (format nil "mv ~a ~a" *config-path* old)))
                        (go :start))))
           (handler-case
               (with-open-file (s *config-path*
                                  :if-does-not-exist :error)
                 (return-from nil
                   (handler-case
                       (let ((read (read s)))
                         (assert (listp read))
                         read)
                     (error (c)
                       @ignore c
                       (format *standard-output* "~%Syntax error found in ~a" *config-path*)
                       (invoke-restart 'backup)))))
             (file-error (c)
               @ignore c
               (format *standard-output* "~%File not found in ~a" *config-path*)
               (invoke-restart 'restore-default))))))))

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
