(in-package :cl-user)
(defpackage eazy-project
  (:use :cl
        :alexandria
        :iterate
        :cl-ppcre
        :cl-emb
        :optima)
  (:export
   #:simulate-menu-selection))

