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
@export
(defvar *default-author* nil)
@export
(defvar *default-email* nil)



