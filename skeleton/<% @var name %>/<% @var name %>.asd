<% @unless asdf3 %>
(in-package :cl-user)
(defpackage <% @var name %>-asd
  (:use :cl :asdf))
(in-package :<% @var name %>-asd)
<% @endunless %>

(defsystem <% @var name %>
  :version "0.1"
  :author "<% @var author %>"
  :mailto "<% @var email %>"<% @if homepage %>
  :homepage "<% @var homepage %>"<% @endif %><% @if bug-tracker %>
  :bug-tracker "<% @var bug-tracker %>"<% @endif %><% @if source-control %>
  :source-control <% (apply #'format t "(:~A \"~A\")" (getf env :source-control)) %><%  @endif %>
  :license "<% @var license %>"
  :depends-on (<% (format t "~{:~(~A~)~^ ~}" (getf env :depends-on)) %>)
  :pathname "<% @var source-dir %>"
  :components ((:file "package"))
  :description "<% @var description %>"
  :in-order-to ((test-op (test-op :<% @var test-name %>))))
