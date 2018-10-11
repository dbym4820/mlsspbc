(in-package :loapeat.resources)

(defunction-page register-process
  (let* ((posted-email (post-parameter "email"))
	 (posted-password1 (post-parameter "password1"))
	 (posted-password2 (post-parameter "password2"))
	 (posted-user-name (post-parameter "username"))
	 (posted-nationality (post-parameter "nationality"))
	 (posted-gender (post-parameter "gender"))
	 (posted-birth-year (post-parameter "birth_year"))
	 (posted-birth-month (post-parameter "birth_month"))
	 (posted-birth-day (post-parameter "birth_day"))
	 (posted-user-type (post-parameter "user_type")))
    (cond ((violated-email-address-p posted-email)
	   (redirect-to-path "sign-up?er=v-mail"))
	  ((empty-email-address-p posted-email)
	   (redirect-to-path "sign-up?er=e-mail"))
	  ((duplicated-email-address-p posted-email)
	   (redirect-to-path "sign-up?er=d-mail"))
	  ((violated-password-p posted-password1 posted-password2)
	   (redirect-to-path "sign-up?er=v-password"))
	  ((empty-password-p posted-password1 posted-password2)
	   (redirect-to-path "sign-up?er=e-password"))
	  ((empty-name-p posted-user-name)
	   (redirect-to-path "sign-up?er=e-name"))
	  ((empty-birth-year-p posted-birth-year)
	   (redirect-to-path "sign-up?er=e-year"))
	  (t
	   (add-user posted-user-name posted-user-type posted-password1 posted-gender posted-birth-year posted-birth-month posted-birth-day posted-email posted-nationality)
	   (redirect-to-path "")))))

(defun get-user-id-from-address (address)
  (cadar (select "user_id" "user" (format nil "\"mail_address\" = \"~A\"" address))))

(defun empty-p (elm)
  (cond ((string= elm "") t)
	((string= elm "null") t)
	((string= elm "nil") t)
	((null elm) t)
	(t nil)))

(defun violated-email-address-p (address)
  (declare (ignorable address))
  (when t nil))

(defun empty-email-address-p (address)
  (empty-p address))

(defun duplicated-email-address-p (address)
  (when (select "mail_address" "user" (format nil "\"mail_address\" = \"~A\"" address))
    t))

(defun violated-password-p (password1 password2)
  (cond ((not (string= password1 password2)) t)
	(t nil)))
	 

(defun empty-password-p (password1 password2)
  (cond ((empty-p password1) t)
	((empty-p password2) t)
	(t nil)))

(defun empty-name-p (uname)
  (cond ((empty-p uname) t)
	(t nil)))

(defun empty-birth-year-p (birth-year)
  (cond ((empty-p birth-year) t)
	(t nil)))
