(in-package :eazy-project)

(defvar *processors* (make-hash-table))
(defvar *done* nil)
;; (defvar *final-config-vars nil)
(defun actually-create-project ()
  (let ((*done* nil))
    (iter (until
           (iter
             (for (key value) in-hashtable *processors*)
             (always (funcall value)))))


    (format t "~2&Processing templates.
Global Parameters:
~{~20@<~s~> = ~s~%~}" *config*)

    (format t "~2&Processing templates.
Actual Parameters:
~{~20@<~s~> = ~s~%~}" *project-config*)
    (let ((*print-case* :downcase))
      (walk-directory 
       (getf *project-config* :skeleton-directory)
       #'process-file
       :test #'not-includefile-p))

    ;; misc

    (when (getf *project-config* :git)
      (let ((*default-pathname-defaults*
             (merge-pathnames
              (getf *project-config* :name)
              (getf *project-config* :local-repository))))
        (princ (shell-command
                (format nil "cd ~a; git init; git add *"
                        *default-pathname-defaults*)))))))

(defun not-includefile-p (path)
  (declare (ignore path))
  (not (string=
        "includes"
        (pathname-name
         (pathname-as-file 
          (pathname-directory-pathname
           *default-pathname-defaults*))))))

(defun process-file (file)
  (let* ((tpl-path (merge-pathnames file))
         (tpl-name (namestring tpl-path)))
    ;; might be confusing, but cl-emb treat pathnames and strings
    ;; differently
    (register-emb tpl-name tpl-name)
    (let* ((processed-filename
            (execute-emb ; convert the filename
             tpl-name :env *project-config*))
           ;; e.g. /tmp/skeleton/<% @var x %>/<% @var y %>.lisp
           ;; -> . /tmp/skeleton/x/y.lisp
           ;; next, get the relative pathname
           (relative-from-skeleton
            (enough-namestring
             processed-filename
             (pathname-as-directory 
              (getf *project-config* :skeleton-directory))))
           ;; this should be x/y.lisp
           ;; then merge to the target dirname
           ;; e.g. ~/myrepos/ + x/y.lisp
           (final-pathname
            (merge-pathnames 
             relative-from-skeleton
             (getf *project-config* :local-repository))))
      (ensure-directories-exist final-pathname :verbose t)
      ;; now convert the contents
      (let ((str (execute-emb tpl-path :env *project-config*)))
        (with-open-file (s final-pathname
                           :direction :output
                           :if-exists :supersede
                           :if-does-not-exist :create)
          (princ str s))))))



(defmacro defprocessor ((key &optional
                             (global (gensym "G"))
                             (local (gensym "L"))
                             depends-on)
                        &body body)
  (assert (listp depends-on))
  `(add-processor
    ,key
    ',depends-on
    (lambda ()
      (symbol-macrolet ((,global (getf *config* ,key))
                        (,local (getf *project-config* ,key)))
        (declare (ignorable ,global ,local))
        ,@body))))

(defun add-processor (key depends-on fn)
  (setf (gethash key *processors*)
        (lambda ()
          (if (done key)
              t
              (when (progn
                      (format t "~&Checking dependency of ~a: ~a"
                              key depends-on)
                      (every #'done depends-on))
                (format t "~&Running processor ~a" key)
                (funcall fn)
                (push key *done*)
                t)))))

(defun done (key)
  (find key *done*))

;; local information supersedes the global settings by default.

(iter (for (key value . rest) on *config* by #'cddr)
      (let ((key key))
        (add-processor
         key nil
         (lambda ()
           (format t "~%   Superseding the global settings...")
           (setf (getf *project-config* key)
                 (or (getf *project-config* key)
                     (getf *config* key)))
           (print *project-config*)))))

;; however, few are not...

;; required field
(defprocessor (:name g l)
  (handler-case
      (assert l nil "the project name is not provided!")
    (error (c)
      (declare (ignore c))
      (:name))))

;; appended to global settings
(defprocessor (:depends-on g l) (setf l (union l g)))

;; depends on above fields

(defprocessor (:test-template g l (:test))
  (setf l (format nil "~(~a~).lisp"     ; includes/fiveam.lisp
                  (getf *project-config* :test))))

(defprocessor (:test-name g l (:name :test-subname :delimiter))
  (setf l (format nil "~a~a~a"
                  (getf *project-config* :name)
                  (getf *project-config* :delimiter)
                  (getf *project-config* :test-subname))))

(defprocessor (:readme-filename g l (:readme-extension))
  (setf l (format nil "README.~a"
                  (getf *project-config* :readme-extension))))



