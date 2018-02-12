(in-package :cl-user)
(defpackage mlsspbc.web-utils
  (:use :cl)
  (:import-from :mlsspbc.config
                :config :append-root-url)
  (:import-from :cl-annot
                :enable-annot-syntax)
  (:import-from :hunchentoot
                :host
                :*request*
		:*session*
		:post-parameters*))
(in-package :mlsspbc.web-utils)
(enable-annot-syntax)

;;; Path to request packet
(defun request () *request*)

;;; localhost:8000
@export
(defun request-host ()
  (host (request)))


;;; http://localhost:8000/
@export
(defun root-url ()
  (format nil "http://~A~A" (request-host) "/"));;(append-root-url "/")))

;;; http://localhost:8000/index
@export
(defun site-path (&optional (page-name ""))
  (format nil "http://~A~A" (request-host) (append-root-url (format nil "/~A" page-name))))

(defun redirect (url)
  (hunchentoot:redirect url))

;;; http://localhost:8000/path
@export
(defun redirect-to-path (path)
  (redirect (site-path path)))

(defun session () *session*)

@export
(defun remove-session ()
  (hunchentoot:remove-session (session)))

@export
(defun session-value (value-name)
  (hunchentoot:session-value value-name))

@export
(defun set-session-value (session-value-name value)
  (setf (hunchentoot:session-value session-value-name) value))

@export
(defun post-parameters ()
  (let ((params (hunchentoot:post-parameters* (request))))
    (if params params (princ-to-string ""))))

@export
(defun post-parameter (parameter-name)
  (let ((param (hunchentoot:post-parameter parameter-name (request))))
    (if param param (princ-to-string ""))))

@export
(defun get-parameter (parameter-name)
  (let ((param (hunchentoot:get-parameter parameter-name (request))))
    (if param param (princ-to-string ""))))
