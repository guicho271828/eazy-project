#|
  This file is a part of Eazy-Project project.
  Copyright (c) 2011 Eitarow Fukamachi (e.arrows@gmail.com)
|#

(in-package :cl-user)
(defpackage eazy-project-test-asd
  (:use :cl :asdf))
(in-package :eazy-project-test-asd)

(defsystem eazy-project-test
  :author "Eitarow Fukamachi"
  :license "LLGPL"
  :depends-on (:eazy-project
               :cl-test-more)
  :components ((:module "t"
                :components
                ((:file "eazy-project"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
