(in-package :eazy-project)

(define-namespace processor)

(defvar *done* nil)

(defun actually-create-project ()
  (let ((*done* nil))
    (iter (for failure = 
               (iter
                 (for (key value) in-hashtable *processor-table*)
                 (count (not (funcall value)))))
          (for prev previous failure)
          (until (zerop failure))
          (unless (first-time-p)
            (when (= failure prev)
              (error "~&Dependency not satisfied! This is a shame, consult to a developper"))))

    ;; (format t "~2&Processing templates.
;; Global Parameters:
;; ~{~20@<~s~> = ~s~%~}" *config*)

    (format t "~2&Processing templates.
Actual Parameters:
~{~20@<~s~> = ~s~%~}" *project-config*)

    (let ((*default-pathname-defaults*
           (pathname-as-directory 
            (merge-pathnames
             (l :name)
             (l :local-repository)))))
      ;; creation
      (unwind-protect-case ()  
          (let ((*print-case* :downcase))
            (walk-directory 
             (l :skeleton-directory)
             #'process-file
             :test #'not-includefile-p))
        (:abort (shell-command
                 (format nil "rm -rf ~a"
                         *default-pathname-defaults*))))
      ;; git
      (when (l :git)
        (princ (shell-command
                (format nil "cd ~a; git init; git add *"
                        *default-pathname-defaults*))))
      ;; autoload asd
      (load (merge-pathnames
             (format nil "~a.asd" (l :name))))
      (asdf:load-system (l :name)))))

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
              (l :skeleton-directory))))
           ;; this should be x/y.lisp
           ;; then merge to the target dirname
           ;; e.g. ~/myrepos/ + x/y.lisp
           (final-pathname
            (merge-pathnames 
             relative-from-skeleton
             (l :local-repository))))
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
      (symbol-macrolet ((,global (g ,key))
                        (,local (l ,key)))
        (declare (ignorable ,global ,local))
        ,@body))))

(defun add-processor (key depends-on fn)
  (setf (symbol-processor key)
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
           (setf (l key)
                 (or (l key)
                     (g key)))
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
                  (l :test))))

(defprocessor (:test-name g l (:name :test-subname :delimiter))
  (setf l (format nil "~a~a~a"
                  (l :name)
                  (l :delimiter)
                  (l :test-subname))))

(defprocessor (:readme-filename g l (:readme-extension))
  (setf l (format nil "README.~a"
                  (l :readme-extension))))



