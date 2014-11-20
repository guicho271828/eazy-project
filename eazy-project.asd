
(in-package :cl-user)
(defpackage eazy-project-asd
  (:use :cl :asdf))
(in-package :eazy-project-asd)

(defsystem eazy-project
  :version "0.1"
  :author "Masataro Asai"
  :license "LLGPL"
  :depends-on (:trivial-shell
               :optima
               :cl-emb
               :osicat
               :cl-ppcre
               :cl-syntax
               :cl-syntax-annot
               :local-time)
  :components ((:module "src"
                :components
                ((:file :package)
                 (:file :specials))
                :serial t))
  :description "Generate and Manage a Project"
  :in-order-to ((test-op (load-op eazy-project-test))))
