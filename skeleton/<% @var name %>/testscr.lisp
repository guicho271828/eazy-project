
(in-package :cl-user)

(uiop:quit (if (handler-case
                   (progn
                     (asdf:load-system :<% @var test-name %>)
                     <%= (cl-emb:execute-emb
                          (merge-pathnames
                           (getf env :test-template)
                           (merge-pathnames "includes/"))
                          :env env) %>)
                 (serious-condition (c)
                   (describe c)
                   (uiop:quit 2)))
               0 1))


