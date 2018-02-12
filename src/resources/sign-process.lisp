(in-package :mlsspbc.resources)

(defunction-page sign-process
  (let ((posted-address (post-parameter "email"))
	(posted-password (post-parameter "password")))
    (if (valid-user-p posted-address posted-password)
	(let* ((user-id (get-user-id-for-sign posted-address posted-password))
	       (user-name (get-user-name-for-sign user-id))
	       (user-role (get-user-role-for-sign user-id)))
	  (sign-in-dealing user-id user-name user-role)
	  (redirect-to-path ""))
	(redirect-to-path "sign-in"))))

(defunction-page sign-out-process
  (when (session-value 'login-frag)
    (remove-session))
  (redirect-to-path ""))

(defun valid-user-p (address password)
  (select "user_id" "user" (format nil "mail_address=\"~A\" and password=\"~A\"" address password)))

(defun sign-in-dealing (user-id user-name user-role)
  (set-session-value 'login-frag t)
  (set-session-value 'user-name user-name)
  (set-session-value 'user-id user-id)
  (set-session-value 'user-role user-role))

(defun get-user-id-for-sign (address password)
  (cadar (select "user_id" "user" (format nil "\"mail_address\"=\"~A\" and password=\"~A\"" address password))))

(defun get-user-name-for-sign (user-id)
  (cadar (select "user_name" "user" (format nil "user_id=\"~A\"" user-id))))


(defun get-user-role-for-sign (user-id)
  (cadar (select "user_type" "user" (format nil "user_id=\"~A\"" user-id))))

