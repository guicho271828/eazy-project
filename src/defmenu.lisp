
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
  (message ""
         :type (or string function)
         :read-only t)
  (body (error "body not specified")
        :type list
        :read-only t))

(define-namespace menu t)

@export
(defmacro defmenu ((name &key
                         (message (string-capitalize name))
                         (in name parent-provided-p)) &body body)
  (assert (symbolp name))
  `(progn
     ;; invalidation
     (when-let ((old (symbol-menu ',name)))
       (warn "Redefining menu: ~a" ',name)
       (let ((old-parent (menu-parent old)))
         (removef (gethash old-parent *parent-children-db*) ',name)))
     (defun ,name () (invoke-menu (symbol-menu ',name)))
     (let* ((menuobj
             (make-menu :name ',name
                        :parent ',in
                        :message ,message
                        :body ',body)))
       (setf (symbol-menu ',name) menuobj)
       ,(when parent-provided-p
              `(pushnew ',name (gethash ',in *parent-children-db*)))
       ',name)))

@export
(defun invoke-menu (menu)
  (funcall (menu-task (etypecase menu
                        (symbol (symbol-menu menu))
                        (menu menu))))
  ;; (when-let ((r (find-restart 'up)))
  ;;   (invoke-restart r))
  )

(defun menu-task (menu)
  (compile nil `(lambda () ,(menu-task-form menu))))

(defvar *current-menu* nil)
(defun menu-task-form (menu)
  (let ((name (menu-name menu)))
    `(tagbody
      :start
        (restart-case
            (restart-bind (,@(generate-restart-hander-forms
                              name))
              
              (let ((*current-menu* ',name))
                ,@(menu-body menu)))
          (:up ()
            :report ,(format nil "Quit the section ~a." name)
            :test (lambda (c)
                    (declare (ignore c))
                    (and ;; (askp c)
                     (eq *current-menu* ',name)))
            t)
          (:reload-menu ()
            :report ,(format nil "Reload the menu ~a." name)
            :test (lambda (c)
                    (declare (ignore c))
                    (and ;; (askp c)
                     (eq (menu-parent
                          (symbol-menu *current-menu*))
                         ',name)))
            (go :start))))))

@export
(defun up ()
  (invoke-restart (find-restart :up)))

@export
(defun reload ()
  (invoke-restart (find-restart :reload-menu)))


(defun generate-restart-hander-forms (name)
  (iter (for child in (menu-children (symbol-menu name)))
        (collect
            (ematch (symbol-menu child)
              ((menu- name parent (message (and message (type string))))
               `(,name (function ,name)
                       :test-function
                       (lambda (c)
                         (and (askp c)
                              (eq *current-menu* ',parent)))
                       :report-function
                       (lambda (s)
                         (princ ,message s))))
              ((menu- name parent (message (and message (type function))))
               `(,name (function ,name)
                       :test-function
                       (lambda (c)
                         (and (askp c)
                              (eq *current-menu* ',parent)))
                       :report-function
                       (lambda (s)
                         (funcall ,message s))))))))
