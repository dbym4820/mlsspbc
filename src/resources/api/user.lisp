(in-package :loapeat.resources.api)

(defapi get-users-api (sim ("user-id"))
  (format nil "arg=~%"))


(defun users-lesson (user-id)
  (mapcar #'second 
	  (get-data *lesson-table* '("lesson_id") `(("user_id" ,user-id)))))

(defun users-domain (user-id)
  (mapcar #'second
	  (get-data *lesson-table* '("domain_id") `(("user_id" ,user-id)))))
