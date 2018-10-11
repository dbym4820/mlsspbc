(in-package :cl-user)
(defpackage loapeat.db
  (:use :cl)
  (:import-from :loapeat.config
                :config)
  (:import-from :cl-annot
                :enable-annot-syntax)
  (:import-from :dbi
                :connect :disconnect
		:prepare :fetch :execute)
  (:import-from :cl-json
		:decode-json-from-string))
(in-package :loapeat.db)

(enable-annot-syntax)

@export
(defun send-query (query)
  (let* ((database-connection (connect :sqlite3 :database-name (config :path-to-database)))
	 (pre-query (prepare database-connection query))
	 (result (execute pre-query))
	 (return-value
	   (loop for row = (fetch result)
		 while row
		 collect row)))
    (disconnect database-connection)
    return-value))

@export
(defun select (param table &optional condition)
  (send-query (format nil "select ~A from ~A ~A" param table
		      (when condition
			(format nil " where ~A" condition)))))

@export
(defun update (table param &optional condition)
  (send-query (format nil "update ~A set ~A ~A" table param
		      (when condition
			(format nil " where ~A" condition)))))

@export
(defun insert (table param-name param)
  (send-query (format nil "insert into ~A (~A) values (~A)" table param-name param)))

@export
(defun sql-delete (table condition)
  (send-query (format nil "delete from \"~A\" where ~A" table condition)))
