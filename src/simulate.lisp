(in-package :eazy-project)

(cl-syntax:use-syntax :annot)

(defvar *data* nil)
(defun wrap (fn &optional (*data* *data*))
  (handler-bind
      ((ask (lambda (c)
              (declare (ignorable c))
              (when *data*
                ;; ^^^^^ stop trying to call the restarts when the submenu selection commands are exhausted.
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
                    (wrap (lambda () (apply #'invoke-restart r query)))))))))
    (funcall fn)))

(defun simulate-menu-selection (list)
  "Simulate launching a menu and selecting each submenu command.
LIST is a list of menu selections.
a menu-selection is a list of (RESTART-NAME . ARGS) .
ARGS are passed to the restart through, basically,
 (apply #'invoke-restart (find-restart RESTART-NAME) ARGS) .

This API is not carefully considered and not for public usage. "
  (wrap (lambda () (launch-menu)) list))

@export
(define-symbol-macro !!
    (simulate-menu-selection
     '((restore))))
