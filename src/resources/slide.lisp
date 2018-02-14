(in-package :mlsspbc.resources)

;; (defun get-slide-pathname ()
;;   (let* ((base-pathname (format nil "~A~A" *application-root* "static/slide/keynote/test/assets/"))
;; 	 (names (remove-duplicates
;; 		 (mapcar #'(lambda (lst)
;; 			     (if
;; 			      (not (or
;; 				    (string= lst (concatenate 'string base-pathname "global/"))
;; 				    (string= lst (concatenate 'string base-pathname "player/"))))
;; 			      lst))
;; 			 (mapcar #'namestring
;; 				 (uiop:subdirectories (concatenate 'string *application-root* "web/slide/keynote/test/assets/")))))))
;;     (loop for lst in names
;; 	  when (not (null lst))
;; 	    collect (concatenate 'string ".." (subseq lst (1- (+ 4 (length *application-root*)))) "thumbnail.jpeg"))))

(defun slide ()
  (let (code)
    (loop for x in (get-slide-pathname)
	  do (push `(:img :id ,x :class "slide-image intension-items" :ondragstart "f_dragstart(event)" :src ,x) code))
    (push :div code)))

(defun already-kma-p (lesson-id slide-id)
  (when (select "kma_result" "user_slide" (format nil "slide_id=\"~A\" and lesson_id=\"~A\"" slide-id lesson-id))
    t))

(defun decide-kma (slide-id lesson-id kma-result)
  (let* ((current-time (now))
	 (year (timestamp-year current-time))
	 (month (timestamp-month current-time))
	 (day (timestamp-day current-time))
	 (hour (timestamp-hour current-time))
	 (mini (timestamp-minute current-time))
	 (sec (timestamp-second current-time))
	 (time-stamp (format nil "~A-~2,,,'0@A-~2,,,'0@A ~2,,,'0@A:~2,,,'0@A:~2,,,'0@A" year month day hour mini sec)))
    (if (already-kma-p lesson-id slide-id)
	(update "user_slide" (format nil "kma_result=\"~A\", edited_at=\"~A\"" kma-result time-stamp) (format nil "slide_id=\"~A\" and lesson_id=\"~A\"" slide-id lesson-id))
	(let ((selection-id (cadar (select "max(selection_id)+1" "user_slide"))))
	  (send-query (format nil "insert into user_slide(\"selection_id\", \"slide_id\", \"lesson_id\", \"kma_result\", \"created_at\", \"edited_at\") values (\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\")" selection-id slide-id lesson-id kma-result time-stamp time-stamp))))))

(defun highlighted-slide-list (lesson-id kma-number)
  (let ((code nil))
    (loop for x in (mapcar #'car (get-lesson-slides-list lesson-id))
	  for y from 0
	  do (if (= y kma-number)
		 (push `(:a :href ,(append-root-url (format nil "/learner/learner-kma?lesson-id=~A&kma=~A" lesson-id y))
			     (:img :class "slide-kma highlighted-slide" :src ,(append-root-url x) :width "100" :height "80" :style "border: 1px black solid")) code)
		 (push `(:a :href ,(append-root-url (format nil "/learner/learner-kma?lesson-id=~A&kma=~A" lesson-id y))
			    (:img :class "slide-kma" :src ,(append-root-url x) :width "80" :height "60" :style "border: 1px black solid")) code))
	  do (if (= 1 (mod y 15))
		 (push `(:div :style "clear:both;") code))
	  finally (progn
		    (setf code (reverse code))
		    (push :div code)))
    code))

(defun slide-length (lesson-id)
  (length (get-lesson-slides-list lesson-id)))
