
(in-package :eazy-project)

(cl-syntax:use-syntax :annot)


(defvar *parent-children-db* (make-hash-table :test 'eq))
(defun menu-children (menu)
  (copy-list (gethash (menu-name menu) *parent-children-db*)))
(defstruct menu
  (name nil
        :type symbol
        :read-only t)
  (parent (error "parent not specified")
          :type symbol
          :read-only t)
  (title ""
         :type (or string function)
         :read-only t)
  (body (error "body not specified")
        :type function
        :read-only t))

(define-namespace menu t)

@export
(defmacro defmenu ((name &key
                         (title (string-capitalize name))
                         (in name parent-provided-p)) &body body)
  (assert (symbolp name))
  `(progn
     ;; invalidation
     (when-let ((old (symbol-menu ',name)))
       (warn "Redefining menu: ~a" ',name)
       (let ((old-parent (menu-parent old)))
         (removef (gethash old-parent *parent-children-db*) ',name)))
     (defun ,name () ,@body)
     (let* ((menuobj
             (make-menu :name ',name
                        :parent ',in
                        :title ,title
                        :body (function ,name))))
       (setf (symbol-menu ',name) menuobj)
       ,(when parent-provided-p
              `(pushnew ',name (gethash ',in *parent-children-db*)))
       ',name)))
