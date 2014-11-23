(in-package :eazy-project.test)
(in-suite :eazy-project)


(defvar *data* nil)
(defun wrap (fn &optional (*data* *data*))
  (handler-bind
      ((ask (lambda (c)
              (declare (ignorable c))
              (destructuring-bind (menu-name . query) (pop *data*)
                (format t "~&Current Menu: ~a" *current-menu*)
                (format t "~&Simulating menu op: ~a" menu-name)
                (format t "~&Available restarts: ~&~:{~30@<~s~> = ~s~%~}"
                        (mapcar (lambda (r)
                                  (list (restart-name r) r))
                                (compute-restarts c)))
                (let ((r (find-restart menu-name c)))
                  (assert r)
                  (format t "~&Invoking restart: ~a" r)
                  (wrap (lambda () (apply #'invoke-restart r query))))))))
    (funcall fn)))




(defun simulate-menu-selection (alist)
  (wrap (lambda () (launch-menu)) alist))

(defvar *projects*
  (asdf:system-relative-pathname
   :eazy-project.test
   "t/test-projects/"))

(test create
  (let ((*config* (copy-seq *config*)))
    (setf (getf *config* :LOCAL-REPOSITORY) *projects*)
    (setf (getf *config* :depends-on) nil)
    (shell-command (format nil "rm -rf ~a" *projects*))
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
    (shell-command (format nil "rm -rf ~a" *projects*))))



     
