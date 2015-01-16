(in-package :eazy-project)

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
