#|
  This file is a part of <% @var name %> project.
<% @if author %>  Copyright (c) <%= (local-time:timestamp-year (local-time:now)) %> <% @var author %><% @if email %> (<% @var email %>)<% @endif %>
<% @endif %>|#

<% @unless asdf3 %>
(in-package :cl-user)
(defpackage <% @var test-name %>-asd
  (:use :cl :asdf))
(in-package :<% @var test-name %>-asd)
<% @endunless %>

(defsystem <% @var test-name %>
  :author "<% @var author %>"
  :mailto "<% @var email %>"
  :description "Test system of <% @var name %>"
  :license "<% @var license %>"
  :depends-on (:<% @var name %>
               :<% @var test %>)
  :components ((:module "<% @var test-dir %>"
                :components
                ((:file "package"))))
  :perform (load-op :after (op c) <%= (cl-emb:execute-emb
     (merge-pathnames
      (getf env :test-template)
      (merge-pathnames "includes/"))
      :env env) %>))
