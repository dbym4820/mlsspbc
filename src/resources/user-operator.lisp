(in-package :mlsspbc.resources)
(enable-annot-syntax)

@export
(defun add-user (user-name user-type password gender birth-year birth-month birth-day mail-address nationality)
  (add-user-query user-name user-type password gender birth-year birth-month birth-day mail-address nationality))

(defun add-user-query (user-name user-type password gender birth-year birth-month birth-day mail-address nationality)
  (let* ((user-id (or (cadar (send-query (format nil "select max(user_id)+1 from user"))) 1))
	 (current-time (now))
	 (year (timestamp-year current-time))
	 (month (timestamp-month current-time))
	 (day (timestamp-day current-time))
	 (hour (timestamp-hour current-time))
	 (mini (timestamp-minute current-time))
	 (sec (timestamp-second current-time))
	 (time-stamp (format nil "~A-~2,,,'0@A-~2,,,'0@A ~2,,,'0@A:~2,,,'0@A:~2,,,'0@A" year month day hour mini sec)))
    (send-query (format nil "insert into user(\"user_id\", \"user_name\", \"user_type\", \"password\", \"gender\", \"birth_year\", \"birth_month\", \"birth_day\", \"mail_address\", \"nationality\", \"created_at\", \"edited_at\") values (\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\")"
			user-id user-name user-type password gender birth-year birth-month birth-day mail-address nationality time-stamp time-stamp))))

@export
(defun user-check (user-name password)
  (let ((true-password (cadar (select "password" "user" (format nil "user_name=\"~A\"" user-name)))))
    (when (string= true-password password)
	user-name)))

@export
(defun user-type-check (user-name)
  (let ((user-type (cadar (select "\"user_type\"" "user" (format nil "user_name=\"~A\"" user-name)))))
    (cond ((string= "learner" user-type)
	   'learner)
	  ((string= "teacher" user-type)
	   'teacher))))

@export
(defun exist-user-p (user-name)
  (when (cadar (select "user_name" "user" (format nil "user_name=\"~A\"" user-name))) t))
    
