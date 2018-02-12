(in-package :mlsspbc.resources)

(defpage learner-kma ()
  `(:div :id "container"
	 ,(let ((lesson-id (get-parameter "lesson-id"))
		(kma (get-parameter "kma")))
	    `(:div
	      (:div :style "float:left"
		    ,(first (slides-kma lesson-id kma)))
	      (:div :style "float:left; padding-left: 30px"
		    (:form :style "font-size: 2em" :action "/slide-kma-save" :method "get"
			   (:input :type "hidden" :name "slide-id" :value ,(second (slides-kma lesson-id kma)))
			   (:input :type "hidden" :name "lesson-id" :value ,(format nil "~A" lesson-id))
			   (:input :type "hidden" :name "kma" :value ,(format nil "~A" (1+ (parse-integer kma))))
			   ;;　KMAの宣言１
			   (:label :style "font-size: 1.5em"
				   (:input :type "radio" :name "kma-result" :value "ok" :checked "checked"
					   :style "width:20px; height:20px"
					   "理解している"));;"I understand about the contents on this slide"
			   (:br)
			   (:br)
			   (:br)
			   ;;　KMAの宣言２
			   (:label :style "font-size: 1.5em"
				   (:input :type "radio" :name "kma-result" :value "ng" :style "width:20px; height:20px"
					   "理解していない"));;"I don't understand about the contents on this slide"
			   (:br)
			   (:br)
			   (:br)
			   ;;　KMAの宣言３
			   (:label :style "font-size: 1.5em"
				   (:input :type "radio" :name "kma-result" :value "error" :style "width:20px; height:20px"
					   "誤っている"));;"This slide has incorrect information"
			   (:br)
			   (:br)
			   (:br)
			   ;; (:div :style "clear:both")
			   
			   ;; (:br)
			   ;; (:br)
			   ;;　Next slides
			   (:button :class "btn-danger" :type "submit" :style "font-size:1.5em;padding:10px 20px;" "Next Sldie")))
	      (:div :style "clear:both;"
		    (:div :id "declare-time-slide-highlight"
			  ,(highlighted-slide-list lesson-id (parse-integer kma))))))
	 (:script :type"text/javascript" :src "/static/js/window-setting/redirect.js")))

(defun slide-kma-save ()
  (let ((lesson-id (get-parameter "lesson-id"))
	(slide-id (get-parameter "slide-id"))
	(kma-result (get-parameter "kma-result"))
	(kma-number (get-parameter "kma")))
    (decide-kma slide-id lesson-id kma-result)
    (if (>= (parse-integer kma-number) (slide-length lesson-id))
	(redirect-to-path (format nil "domain-select?lesson-id=~A" lesson-id))
	(redirect-to-path (format nil "learner/learner-kma?lesson-id=~A&kma=~A" lesson-id kma-number)))))


(defun get-lesson-slides-list (lesson-id)
  (let ((domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id=\"~A\"" lesson-id)))))
    (mapcar #'(lambda (slide-path)
		(list slide-path
		      (cadar (select "slide_id" "domain_slide" (format nil "domain_id=\"~A\" and slide_path=\"~A\"" domain-id slide-path)))))
	    (mapcar #'cadr (select "slide_path, slide_id" "domain_slide" (format nil "domain_id=\"~A\"" domain-id))))))


(defun slides-kma (lesson-id slide-number)
  (let ((code nil))
    (loop for x in (get-lesson-slides-list lesson-id) ;; get-slide-pathname2 lesson-id)
	  do (push `((:img :id ,(first x) :class "slide-kma" :src ,(first x) :width "400" :height "300" :style "border: 1px black solid") ,(second x)) code))
    `,(nth
       (if (stringp slide-number)
	   (parse-integer slide-number)
	   slide-number)
       code)))

