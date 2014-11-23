


(defsystem eazy-project.watch
  :version "0.1"
  :author "Masataro Asai"
  :license "LLGPL"
  :depends-on (:eazy-project
               :bordeaux-threads)
  :components ((:module "src"
                :components
                ((:module "restore"
                          :components
                          ((:file :watch))))
                :serial t))
  :description "Watch the session")
