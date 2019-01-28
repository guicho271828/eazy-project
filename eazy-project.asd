
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
                ((:file :package)
                 (:file :util)
                 (:file :specials)
                 (:file :defmenu)
                 (:file :ask)
                 (:file :loop)
                 (:file :render)
                 (:file :menu-definitions)
                 (:file :simulate)
                 (:file :global)
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
