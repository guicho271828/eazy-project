
(defsystem eazy-project
  :version "0.1"
  :author "Masataro Asai"
  :license "LLGPL"
  :depends-on (:eazy-project.impl)
  :components ((:module "src"
                :components
                ((:file :autoload))
                :serial t))
  :description "Generate and Manage Projects. This system automatically
  loads and initiate (launch-menu).")
