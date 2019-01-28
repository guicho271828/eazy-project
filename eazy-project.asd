
(defsystem eazy-project
  :version "0.1"
  :author "Masataro Asai"
  :mailto "guicho2.71828@gmail.com"
  :license "LLGPL"
  :depends-on (:cl-ppcre
               :trivia
               :cl-emb
               :cl-syntax
               :cl-syntax-annot
               :local-time
               :iterate
               :introspect-environment
               :bordeaux-threads
               :lisp-namespace)
  :serial t
  :components ((:module "src"
                :components
                ((:file :0package)
                 (:file :1specials)
                 (:file :1ask)
                 (:file :2defmenu)
                 (:file :2menu-definition-tools)
                 (:file :3global)
                 (:file :4loop)
                 (:module "create"
                          :components
                          ((:file :project-local)
                           (:file :actually-create-project)))
                 (:module "restore"
                          :components
                          ((:file :restore)
                           (:file :watch))))
                :serial t))
  :description "Generate and Manage a Project"
  :in-order-to ((test-op (load-op eazy-project.test))))
