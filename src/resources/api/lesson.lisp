(in-package :loapeat.resources.api)

(defapi get-lessons-api (sim ("user-id"))
  (format nil "arg=~%"))

(defun lessons-domain (lesson-id)
  (cadar (get-data *lesson-table* '("domain_id") `(("lesson_id" ,lesson-id)))))
