
(in-package :eazy-project)

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
    (block nil
      (tagbody
       :start
         (let ((*read-eval* nil))
           (match (read *debug-io*)
             ((and i (>= 0) (< (length rs)))
              (invoke-restart (elt rs i)))
             (it
              (format *debug-io* "~& Invalid input: ~s~&" it)
              (go :start))))))))

#+(or)
(handler-bind ((ask #'render-menu))
  (restart-case
      (ask "hahaha")
    (quit-menu ()
      )))

#+(or)
(restart-case
    (handler-bind ((ask #'render-menu))
      (ask "hahaha"))
  (quit-menu ()))
