(in-package :mlsspbc.resources)
(enable-annot-syntax)

@export
(defun get-slide ()
  (cadar (select "slide" "slide" "id=1")))

@export
(defun add-slide (text)
  (if text
      (let ((ran (princ-to-string (random 100000000))))
	(send-query (format nil "insert into slide(slide) values (\"~A\")" text)))
      ""))
