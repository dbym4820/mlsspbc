(in-package :loapeat.resources.api)

(defapi get-slides-api (sim ("user-id"))
  (format nil "arg=~%"))

(defun slides-domain (slide-id)
  (cadar (get-data *slide-table* '("domain_id") `(("slide_id" ,slide-id)))))
