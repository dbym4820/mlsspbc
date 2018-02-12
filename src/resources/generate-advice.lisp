(in-package :mlsspbc.resources)

(defun get-stub (get-name online-p)
  (if online-p
      (get-parameter get-name)
      "/static/slide/keynote/test/assets/7F62948A-FD98-4CF8-ACE7-626FB404E94F/thumbnail.jpeg"))


(defun generate-advice ()
  (let ((slide-id (get-stub "slide-id" t)))
    (format nil "~A" ;; <br /><br /><div id='paper' style='overflow:scroll;padding-left:220px;width:220px;height:180px;border:solid 1px black;'></div>"
	    (inference-output (format nil "~A" slide-id)))))
