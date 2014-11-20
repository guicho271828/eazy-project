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
  (:shadow :!))
(in-package :eazy-project.test)

(def-suite :eazy-project)
(in-suite :eazy-project)

(test defmenu
  ;; forward-reference
  
  (defmenu (test-submenu2 :in test-main :title "submenu2")
    (format t "Entering the submenu2"))

  (defmenu (unrelated :title "Enter the main menu")
    (format t "Entering the main menu"))

  (defmenu (test-main :title "Enter the main menu")
    (format t "Entering the main menu"))

  (defmenu (test-submenu :in test-main :title "submenu")
    (format t "Entering the submenu")))

(test (with-menus-in :depends-on defmenu)
  (signals ask
    (ask "select a submenu"))
  (signals ask
    (with-menus-in (test-main)
      (ask "select a submenu")))
  (is-true
   (block nil
     (handler-bind ((ask (lambda (c)
                           (signals error
                             (invoke-restart 'test-main))
                           (finishes
                             (invoke-restart 'test-submenu))
                           (finishes
                             (invoke-restart 'test-submenu))
                           (return t))))
       (with-menus-in (test-main)
         (ask "select a submenu"))))))

(test (main-loop :depends-on with-menus-in)
  
  (signals ask (launch-menu))
  (is-true
   (handler-bind ((ask (lambda (c)
                         (invoke-restart
                          (find-restart :quit-session c)))))
     (launch-menu))))

