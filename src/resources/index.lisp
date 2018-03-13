(in-package :mlsspbc.resources)

(defpage index ()
  `(:div :id "dom-select" :style "height: 400px; overflow: scroll;"
	 ,(let ((uid (session-value 'user-id)))
	    (cond ((and (string= "learner" (session-value 'user-role)) (null (get-lesson-id uid)))
		   `(:div
		     (:h1 "選択可能な科目がありません")))
		  ((and (string= "learner" (session-value 'user-role)) (get-lesson-id uid))
		   `(:div
		     (:h1 "プレゼン設計課題を行う科目を選択してください")
		     ,(get-lesson-list uid)))
		  ((and (string= "teacher" (session-value 'user-role)) (get-lesson-id uid))
		   `(:div
		     (:h1 "プレゼン設計課題の準備を行う科目を選択してください")
		     ,(get-all-lesson-list uid)))
		  (t "")))
	 ,(let ((urole (session-value 'user-role)))
	    (cond ((string= urole "learner")
		   `(:div
		     (:hr)
		     (:a :href ,(append-root-url "/lesson-create-page") (:p :style "font-size:2em" "新しい課題を始める"))))
		  ((string= urole "teacher")
		   `(:ul
		     (:hr)
		     (:li :style "font-size: 2em;"
			  (:a :href ,(append-root-url "/domain-create-page") "新しい学習ドメインを規定する"))))))))


(defun get-lesson-id (user-id)
  (reverse (mapcar #'second (select "lesson_id" "lessons" (format nil "user_id=\"~A\"" user-id)))))

(defun get-lesson-name (lesson-id)
  (cadar (select "domain_name" "educational_domain"
		 (format nil "domain_id=\"~A\""
			 (cadar (select "domain_id" "lessons" (format nil "lesson_id=\"~A\"" lesson-id)))))))

(defun get-lesson-list (user-id)
  (let ((code nil))
    (loop for x in (get-lesson-id user-id)
	  do (push `(:li :style "font-size: 2em;margin-bottom:10px;"
		     (:a :href ,(append-root-url (format nil "/domain-select?lesson-id=~A" x))
			 ,(format nil "~A" (get-lesson-name x))))
		   code))
    (push :ul code)
    code))

(defun get-all-lesson-name-list (user-id)
  (remove-if
   #'(lambda (l-list)
       (when (not (= (cadar (select "user_id" "lessons" (format nil "lesson_id=~A" (second l-list)))) user-id)) t))
   (mapcar #'(lambda (d)
	       (list (get-lesson-name (second d)) (second d)))
	   (select "lesson_id" "lessons"))))

(defun get-all-lesson-list (user-id)
  (let ((code nil))
    (loop for x in (get-all-lesson-name-list user-id)
	  do (push `(:li :style "font-size: 2em;margin-bottom:10px;"
		     (:a :href ,(append-root-url (format nil "/domain-select?lesson-id=~A" (second x)))
			 ,(format nil "~A" (first x))))
		   code))
    (push :ul code)
    code))
