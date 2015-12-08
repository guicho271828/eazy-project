
(defsystem eazy-project.autoload
  :version "0.1"
  :author "Masataro Asai"
  :license "LLGPL"
  :depends-on (:eazy-project)
  :components ((:module "src"
                :components
                ((:file :autoload))
                :serial t))
  :description "Generate and Manage Projects. This system imports a symbol ! to CL-USER package.")
