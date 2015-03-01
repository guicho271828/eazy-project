
(handler-case
    (ql:quickload :eazy-project.test)
  (serious-condition (c)
    (describe c)
    (uiop:quit 1)))
(uiop:quit 0)
