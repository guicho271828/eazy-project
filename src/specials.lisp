(in-package :eazy-project)

(cl-syntax:use-syntax :annot)

(defvar *skeleton-directory*
  #.(asdf:system-relative-pathname
     :eazy-project
     #p"skeletons/default"))

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
  (format t "~&Saving the default config to ~a~%"
          *config-path*)
  (with-open-file (s *config-path*
                     :direction :output
                     :if-exists :supersede)

    (prin1 (list :local-repository *local-repository*
                 :skeleton-directory *skeleton-directory*
                 :author *author*
                 :email *email*
                 :git t
                 :test :fiveam
                 :depends-on '(:alexandria :optima
                               :iterate))
           s)))

@export
(defun read-config ()
  (block nil
    (tagbody
     :start
       (format t "~&loading the default config from ~a~%"
               *config-path*)
       (handler-case
           (with-open-file (s *config-path*
                              :if-does-not-exist :error)
             (return-from nil (read s)))
         (file-error (c)
           @ignore c
           (save-config)
           ;; retry
           (go :start))))))

@export
(defun clear-config ()
  (ignore-errors
    (delete-file *config-path*))
  (load-config))

@export
(defvar *config*)

@export
(defun load-config ()
  (setf *config* (read-config)))

(load-config)
