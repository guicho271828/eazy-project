

(in-package :eazy-project)

(defun update-interval (x)
  "portfolio setting"
  (if (> (* 2 x) (g :session.watch.max))
      x
      (* 2 x)))

(defun watch ()
  (iter (while (g :session.watch))
        (with interval = (g :session.watch.min))
        (setf interval (sleep-and-check interval))))

(defun sleep-and-check (interval)
  (sleep interval)
  (let ((*query-io* (make-broadcast-stream))) ;; /dev/null
    ;; this is run in the watcher thread.
    ;; in order to print to the stdout of the main thread, it should
    ;; interrupt the main thread.
    (if (bt:interrupt-thread *main-thread* #'save-session)
        (g :session.watch.min)  ;; t: updated
        (update-interval interval))))  ;; nil: increase interval

(defun enable-watch ()
  (format t "~&[Initiated a session watcher]~&")
  (bt:make-thread #'watch :name "session watcher thread")
  (setf *main-thread* (bt:current-thread)))


  
