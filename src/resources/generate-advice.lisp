(in-package :mlsspbc.resources)

(defun get-slide-stub (get-name online-p)
  (if online-p
      (get-parameter get-name)
      (append-root-url "/static/slide/keynote/test/assets/7F62948A-FD98-4CF8-ACE7-626FB404E94F/thumbnail.jpeg")))

(defun get-lesson-stub (get-name online-p)
  (if online-p (get-parameter get-name) 2))

(defun generate-advice ()
  (let ((slide-id (get-slide-stub "slide-id" t))
	(lesson-id (get-lesson-stub "lesson-id" t)))
    (format nil "~A" ;; <br /><br /><div id='paper' style='overflow:scroll;padding-left:220px;width:220px;height:180px;border:solid 1px black;'></div>"
	    (inference-output (format nil "~A" slide-id) (format nil "~A" lesson-id)))))

