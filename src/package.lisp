(in-package :cl-user)
(defpackage eazy-project
  (:use :cl
        :alexandria
        :osicat
        :iterate
        :trivial-shell
        :cl-ppcre
        :cl-emb
        :optima)
  (:export
   #:simulate-menu-selection))

