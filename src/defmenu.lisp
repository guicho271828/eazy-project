
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

(lispn:define-namespace menu t)

@export
(defvar *menu-arguments* nil
  "Holds the arguments to the restarts, when the menu is launched
  programatically. These arguments are considered by `qif'.")

@export
(defmacro defmenu ((name &key
                         (message (string-capitalize name))
                         (in name parent-provided-p)) &body body)
  (assert (symbolp name))
  (let ((fname (symbolicate '% name)))
    `(block defmenu
       ;; invalidation
       (when (menu-boundp ',name)
         (let ((old (symbol-menu ',name)))
           (warn "Redefining menu: ~a" ',name)
           (let ((old-parent (menu-parent old)))
             (removef (gethash old-parent *parent-children-db*) ',name))))
       (defun ,fname (&rest *menu-arguments*)
         (invoke-menu (symbol-menu ',name)))
       (let* ((menuobj
               (make-menu :name ',name
                          :parent ',in
                          :message ,message
                          :body ',body)))
         (setf (symbol-menu ',name) menuobj)
         ,(when parent-provided-p
            `(pushnew ',name (gethash ',in *parent-children-db*)))
         ',name))))

(defvar *future-package* nil
  "FIXME: A hack to set the correct package with restore-session.
With let and special bindings, it is unwound every time quitting the menu.")

@export
(defun invoke-menu (menu)
  (setf *future-package* *package*)
  (funcall (menu-task (etypecase menu
                        (symbol (symbol-menu menu))
                        (menu menu))))

  ;; (when-let ((r (find-restart 'up)))
  ;;   (invoke-restart r))
  )

(defun menu-task (menu)
  (compile nil `(lambda () ,(menu-task-form menu))))

@export
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
            :report ,(format nil "Back to the section ~a." name)
            :test (lambda (c)
                    (declare (ignore c))
                    (and ;; (askp c)
                     (eq (menu-parent
                              (symbol-menu *current-menu*))
                             ',name)))
            (go :start))))))

@export
(defun up ()
  "go up the menu"
  (invoke-restart (find-restart :up)))

(defun generate-restart-hander-forms (name)
  (iter (for child in (menu-children (symbol-menu name)))
        (collect
            (ematch (symbol-menu child)
              ((menu name parent (message (and message (type string))))
               (let ((fname (symbolicate '% name)))
                 `(,name (function ,fname)
                         :test-function
                         (lambda (c)
                           (and (askp c)
                                (eq *current-menu* ',parent)))
                         :report-function
                         (lambda (s)
                           (princ ,message s)))))
              ((menu name parent (message (and message (type function))))
               (let ((fname (symbolicate '% name)))
                 `(,name (function ,fname)
                         :test-function
                         (lambda (c)
                           (and (askp c)
                                (eq *current-menu* ',parent)))
                         :report-function
                         (lambda (s)
                           (funcall ,message s)))))))))
