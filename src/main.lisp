(in-package :cl-user)
(defpackage mlsspbc
  (:use :cl :hunchentoot)
  (:nicknames :slm)
  (:import-from :mlsspbc.config
                :config
		:set-root-url)
  (:import-from :hunchentoot
                :*default-content-type*
		:easy-acceptor 
                :start :stop
		:create-regex-dispatcher :*dispatch-table*)
  (:import-from :cl-annot
                :enable-annot-syntax)
  (:import-from :mlsspbc.rooting
                :dispatcher))
(in-package :mlsspbc)
(enable-annot-syntax)

@export
(defun make-server (port)
  (make-instance 'easy-acceptor
		 :port port
		 :document-root (config :document-root)))  

@export
(defparameter *server-list* nil)

@export
(defun add-server (server)
  (setf *server-list*
	(append *server-list*
		'(((:server . server) (:port . port))))))

@export
(defun remove-server (port)
  (setf *server-list*
	(remove-if #'(lambda (dat) (equal (cdr (second dat)) port)) *server-list*)))

@export
(defun running-p (port)
  (not (null
	(mapcar #'(lambda (dat) (cdr (second dat)))
		(remove-if-not #'(lambda (dat) (equal (cdr (second dat)) port)) *server-list*)))))

@export
(defun get-server (port)
  (cdaar (remove-if-not #'(lambda (dat) (equal (cdr (second dat)) port)) *server-list*)))


@export
(defun start-system (&optional (port 8000) (root-url ""))
  (cond ((running-p port) ;; When it has been running that port
	 (format t "~A ~S~%" "New Hunchentoot process can't launched by using port:" port))
	(t ;; When the port hasn't been running now
	 (set-root-url root-url)
	 (dispatcher)
	 (let ((server (make-server port)))
	   (add-server server)
	   (start server)
	   (format t "~A ~S~%" "Hunchentoot process has launched by using port:" port)))))

@export
(defun restart-system (&optional (port 8000))
  (cond ((not (running-p port)) ;; When it has not been running that port
	 (format t "~A~%" "Hunchentoot process doesn't start yet"))
	(t
	 (stop (get-server port))
	 (set-root-url root-url)
	 (dispatcher)
	 (start (get-server port))
	 (format t "~A ~S~%" "Old Hunchentoot process was killed and New process has launched by using port:" port))))

@export
(defun stop-system (&optional (port 8000))
  (cond ((not (running-p port)) ;; When it has not been running that port
	 (format t "~A~%" "Hunchentoot process doesn't start yet"))
	(t
	 (let ((server (get-server port)))
	   (stop server)
	   (remove-server port)
	   (format t "~A ~S~%" "Hunchentoot process has stopped port:" port)))))
