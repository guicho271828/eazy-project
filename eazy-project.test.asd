
(defsystem eazy-project.test
  :author "Masataro Asai"
  :license "LLGPL"
  :depends-on (:eazy-project :fiveam)
  :components ((:module "t"
                :components
                ((:file "eazy-project")
                 (:file "create"))))
  :perform (load-op :after (op c)
		    (eval (read-from-string "(fiveam:run! :eazy-project)"))
                    (asdf:clear-system c)))
