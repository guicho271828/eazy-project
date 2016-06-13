(eval
 (read-from-string
  "(let ((res (5am:run :<% @var name%>)))
     (explain! res)
     (every #'fiveam::TEST-PASSED-P res))"))
