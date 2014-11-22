

(in-package :eazy-project)

(defun update-interval (x)
  "portfolio setting"
  (if (> (* 2 x) (g :session.watch.max))
      x
      (* 2 x)))

(defun watch ()
  (iter (while (g :session.watch))
        (with interval = (g :session.watch.min))
        (sleep interval)
        (let ((*query-io* (make-broadcast-stream))) ;; /dev/null
          (when (bt:interrupt-thread *main-thread* #'save-session)
            (setf interval (update-interval interval))))))

(defun enable-watch ()
  (bt:make-thread #'watch)
  (setf *main-thread* (bt:current-thread)))


  
