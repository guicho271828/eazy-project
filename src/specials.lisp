(in-package :eazy-project)

(cl-syntax:use-syntax :annot)

@export
(defvar *default-skeleton-directory*
  #.(asdf:system-relative-pathname
     :eazy-project
     #p"skeletons/default"))

@export
(defvar *skeleton-directory*
  *default-skeleton-directory*)

@export
(defvar *default-dependency* nil)

(defun ok (str)
  (plusp (length str)))


@export
(defvar *default-author*
    (find-if #'ok
             (mapcar (curry #'remove #\Newline)
                     (list (shell-command "git config --global --get user.name")
                           (shell-command "whoami")))))

@export
(defvar *default-email*
    (find-if #'ok
             (mapcar (curry #'remove #\Newline)
                     (list (shell-command "git config --global --get user.email")
                           (shell-command "echo $(whoami)@$(hostname)")))))



