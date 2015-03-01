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

(defun do-with-ensure-files-missing (files fn)
  (map nil #'ensure-file-missing files)
  (unwind-protect
      (funcall fn)
    (map nil #'ensure-file-missing files)))

(defmacro with-ensure-files-missing (files &body body)
  `(do-with-ensure-files-missing
       (list ,@files)
     (lambda () ,@body)))

(test create
  (let ((*config* (copy-seq *config*)))
    (setf (getf *config* :LOCAL-REPOSITORY) *projects*)
    (setf (getf *config* :depends-on) nil)
    (with-ensure-files-missing (*projects*)
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
      (is (member "test.test" (asdf:already-loaded-systems) :test #'string=)))))

(test initial
  (let ((*config-path* (merge-pathnames "test-config.lisp" *projects*))
        (*config* nil))
    (ensure-directories-exist *config-path*)
    (with-ensure-files-missing (*config-path*)
      (finishes (load-config))
      (is (probe-file *config-path*))
      (is-true *config*))))

(test wrong-config
  (let ((*config-path* (merge-pathnames "test-config.lisp" *projects*))
        (*config* nil))
    (ensure-directories-exist *config-path*)
    (with-ensure-files-missing (*config-path*)
      (with-open-file (*standard-output* *config-path*
                                         :direction :output
                                         :if-does-not-exist :create)
        (write "random 'C har #\a c ter) s"))
      (finishes (load-config))
      (is (probe-file *config-path*))
      (is (probe-file (make-pathname :type "old" :defaults *config-path*)))
      (is-true *config*))))

;; slime-enable-evaluate-in-emacs
;; (swank:eval-in-emacs '(format "a") t)



     
