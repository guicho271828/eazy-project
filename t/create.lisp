(in-package :eazy-project.test)
(in-suite :eazy-project)

(defvar *projects*
  (asdf:system-relative-pathname
   :eazy-project.test
   "t/test-projects/"))

(defun ensure-file-missing (path)
  (when (probe-file path)
    (format t "rm -rf ~a" path)
    (shell-command (format nil "rm -rf ~a" path))))

(test create
  (let ((*config* (copy-seq *config*)))
    (setf (getf *config* :LOCAL-REPOSITORY) *projects*)
    (setf (getf *config* :depends-on) nil)
    (ensure-file-missing *projects*)
    (finishes
      (simulate-menu-selection
       `((eazy-project::create-project)
         (:name "test")
         (eazy-project::create))))
    (is (probe-file (merge-pathnames "test/test.asd" *projects*)))
    (is (member "test" (asdf:already-loaded-systems) :test #'string=))
    (finishes
      (load
       (merge-pathnames "test/test.test.asd" *projects*)))
    (is-true
     (asdf:load-system :test.test))
    (is (member "test.test" (asdf:already-loaded-systems) :test #'string=))
    (ensure-file-missing *projects*)))

(test initial
  (let ((*config-path* (merge-pathnames "test-config.lisp" *projects*))
        (*config* nil))
    (ensure-directories-exist *config-path*)
    (ensure-file-missing *config-path*)

    (finishes (load-config))
    (is (probe-file *config-path*))
    (is-true *config*)

    (ensure-file-missing *config-path*)))

(test wrong-config
  (let ((*config-path* (merge-pathnames "test-config.lisp" *projects*))
        (*config* nil))
    (ensure-directories-exist *config-path*)
    (ensure-file-missing *config-path*)

    (with-open-file (*standard-output* *config-path*
                     :direction :output
                     :if-does-not-exist :create)
      (write "random 'C har #\a c ter) s"))
    (finishes (load-config))
    (is (probe-file *config-path*))
    (is (probe-file (make-pathname :type "old" :defaults *config-path*)))
    (is-true *config*)

    (ensure-file-missing *projects*)))

;; slime-enable-evaluate-in-emacs
;; (swank:eval-in-emacs '(format "a") t)



     
