
(in-package :cl-user)
(defpackage eazy-project-asd
  (:use :cl :asdf))
(in-package :eazy-project-asd)

(defsystem eazy-project
  :version "0.1"
  :author "Masataro Asai"
  :license "LLGPL"
  :depends-on (:trivial-shell
               :asdf
               :optima
               :cl-emb
               :osicat
               :cl-syntax
               :cl-syntax-annot
               :local-time)
  :components ((:module "src"
                :components
                ((:file :namespace)
                 (:file :package)
                 (:file :specials)
                 (:file :defmenu)
                 (:file :ask)
                 (:file :loop)
                 (:file :menu-definitions)
                 (:module "create"
                          :components
                          ((:file :global)
                           (:file :project-local)
                           (:file :actually-create-project)))
                 (:module "restore"
                          :components
                          ((:file :restore)))
                 (:file :autoload))
                :serial t))
  :description "Generate and Manage a Project"
  :in-order-to ((test-op (load-op eazy-project-test))))
