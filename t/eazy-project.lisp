#|
  This file is a part of Eazy-Project project.
  Copyright (c) 2011 Eitarow Fukamachi (e.arrows@gmail.com)
|#

(in-package :cl-user)
(defpackage eazy-project.test
  (:use :cl
        :trivial-shell
        :eazy-project
        :lisp-n
        :fiveam)
  (:shadow :! :!!))
(in-package :eazy-project.test)

(def-suite :eazy-project)
(in-suite :eazy-project)

(test defmenu
  ;; forward-reference
  (finishes
    (defmenu (test-submenu2 :in test-main :message "submenu2")
      (format t "Entering the submenu2")))

  (finishes
    (defmenu (unrelated :message "Enter the main menu")
      (format t "Entering the main menu")))

  (finishes
    (defmenu (test-main :message "Enter the main menu")
      (ask "Select submenu")))

  (finishes
    (defmenu (test-submenu :in test-main :message "submenu")
      (format t "Entering the submenu")))

  (finishes
    (print
     (eazy-project::generate-restart-hander-forms
      'test-main)))

  (signals ask
    (ask "select a submenu"))
  (signals ask
    (eazy-project::invoke-menu
     (eazy-project::symbol-menu 'test-main)))

  (is-true
   (block out
     (handler-bind ((ask (lambda (c)
                           (finishes
                             (invoke-restart
                              (find-restart 'test-submenu c)))
                           (return-from out t))))
       (invoke-menu 'test-main))))

  (signals ask (launch-menu))
  (finishes
   (handler-bind ((ask (lambda (c) (quit-menu))))
     (launch-menu))))

