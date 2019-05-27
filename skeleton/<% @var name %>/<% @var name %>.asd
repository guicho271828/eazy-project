(defsystem <% @var name %>
  :version "0.1"
  :author "<% @var author %>"
  :mailto "<% @var email %>"<% @if homepage %>
  :homepage "<% @var homepage %>"<% @endif %><% @if bug-tracker %>
  :bug-tracker "<% @var bug-tracker %>"<% @endif %><% @if source-control %>
  :source-control <% (apply #'format t "(:~A \"~A\")" (getf env :source-control)) %><%  @endif %>
  :license "<% @var license %>"
  :defsystem-depends-on (<% (format t "~{:~(~A~)~^ ~}" (getf env :defsystem-depends-on)) %>)
  :depends-on (<% (format t "~{:~(~A~)~^ ~}" (getf env :depends-on)) %>)
  :pathname "<% @var source-dir %>"
  :components ((:file "package"))
  :description "<% @var description %>"
  :in-order-to ((test-op (test-op :<% @var test-name %>)))
  ;; :defsystem-depends-on (:trivial-package-manager)
  ;; :perform
  #+(or)
  (load-op :before (op c)
           (uiop:symbol-call :trivial-package-manager
                             :ensure-program
                             "minisat"
                             :apt "minisat"
                             :dnf "minisat2"
                             :yum "minisat2"
                             :packman ""
                             :yaourt ""
                             :brew "minisat"
                             :choco ""
                             :from-source (format nil "make -C ~a"
                                                  (asdf:system-source-directory :<% @var name %>)))
           (uiop:symbol-call :trivial-package-manager
                             :ensure-library
                             "libfixposix"
                             :apt "libfixposix0"
                             :dnf ""
                             :yum ""
                             :packman ""
                             :yaourt ""
                             :brew "libfixposix"
                             :choco ""
                             :from-source (format nil "make -C ~a"
                                                  (asdf:system-source-directory :<% @var name %>)))))
