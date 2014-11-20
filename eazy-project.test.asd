
(in-package :cl-user)
(defpackage eazy-project.test-asd
  (:use :cl :asdf))
(in-package :eazy-project.test-asd)

(defsystem eazy-project.test
  :author "Masataro Asai"
  :license "LLGPL"
  :depends-on (:eazy-project :fiveam)
  :components ((:module "t"
                :components
                ((:file "eazy-project"))))
  :perform (load-op :after (op c)
		    (eval (read-from-string "(fiveam:run! :eazy-project)"))
                    (asdf:clear-system c)))
