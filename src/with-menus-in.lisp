
(in-package :eazy-project)

(cl-syntax:use-syntax :annot)

@export
(defmacro with-menus-in ((name) &body body)
  (assert (symbolp name))
  `(restart-bind ,(generate-restart-hander-forms name)
     ,@body))


(defun generate-restart-hander-forms (name)
  (iter (for child in
             (handler-case
                 (menu-children (symbol-menu name))
               (error (c)
                 (declare (ignore c))
                 (format t "symbol ~a is not yet initialized to have a menu, ignoring." name))))
        (collect
            (ematch (symbol-menu child)
              ((menu- name (title (and title (type string))) body)
               `(,name ,body
                       :report-function (lambda (s) (princ ,title s))))
              ((menu- name (title (and title (type function))) body)
               `(,name ,body :report-function ,title))))))

