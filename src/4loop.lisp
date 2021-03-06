(in-package :eazy-project)

(cl-syntax:use-syntax :annot)

@export
(defun launch-menu ()
  "launch the menu."
  (unwind-protect
       (restart-case
           (invoke-menu 'ep-main)
         (quit-menu ()
           :report "Quit this eazy-project menu."))
    (setf *package* *future-package*)))

@export
(defun quit-menu ()
  (invoke-restart (find-restart 'quit-menu)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; interactively

@export
(define-symbol-macro ! (launch-menu-interactively))

@export
(defun launch-menu-interactively ()
  "launch the menu."
  (wrap-interactively #'launch-menu))

(defun wrap-interactively (fn)
  (handler-bind ((ask #'render-menu))
    (funcall fn)))

(defun render-menu (c)
  (let ((rs (remove-if-not
             (lambda (r)
               (eq (symbol-package (restart-name r))
                   (find-package :eazy-project)))
             (compute-restarts c))))
    (iter (for r in rs)
          (for i from 0)
          (format *debug-io*
                  "~& Enter ~3,,,@a to: [~v,,,a] ~a~%"
                  i
                  (reduce #'max (mapcar (compose #'princ-to-string #'restart-name) rs) :key #'length)
                  (restart-name r)
                  r))
    (ematch c
      ((simple-condition :format-control format-control :format-arguments format-arguments)
       (apply #'format *debug-io* format-control format-arguments)))
    (block nil
      (tagbody
       :start
         (let ((*read-eval* nil))
           (match (read *debug-io*)
             ((and i (>= 0) (< (length rs)))
              (wrap-interactively (lambda () (invoke-restart (elt rs i)))))
             (it
              (format *debug-io* "~& Invalid input: ~s~&" it)
              (go :start))))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; programatically

@export
(define-symbol-macro !!
    (simulate-menu-selection
     '((restore))))

@export
(defun simulate-menu-selection (list)
  "Simulate launching a menu and selecting each submenu command.
LIST is a list of menu selections.
a menu-selection is a list of (RESTART-NAME . ARGS) .
ARGS are passed to the restart through, basically,
 (apply #'invoke-restart (find-restart RESTART-NAME) ARGS) .

This API is not carefully considered and not for public usage. "
  (wrap-programatically #'launch-menu list))

(defvar *data* nil)

(defun wrap-programatically (fn *data*)
  (handler-bind ((ask #'process-data))
    (funcall fn)))

(defun process-data (c)
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
        (wrap-programatically (lambda () (apply #'invoke-restart r query)) *data*)))))






