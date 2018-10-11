(in-package :loapeat.resources)

(defpage lesson-create-page ()
  `(:div :id "dom-select" :style "height:400px;overflow:scroll;"
	 ;; (:form :action "/lesson-create" :method "get"
	 (:h1 "学習を始めるドメインを選択してください")
	 ,(let ((urole (session-value 'user-role)))
	    (cond ((string= urole "teacher")
		   `(:div
		     ,(make-domain-list)
		     (:input :type "text" :name "domain-id")
		     (:input :type "submit" :value "send")))
		  ((string= urole "learner")
		   `(:div
		     ,(make-domain-list)))))))

(defun lesson-create ()
  (let* ((user-id (session-value 'user-id))
	 (new-lesson-id (or (cadar (select "max(lesson_id)+1" "lessons")) 1))
	 (domain-id (get-parameter "domain-id"))
	 (root-vocabrary-id (cadar (select "root_vocabrary_id" "educational_domain" (format nil "domain_id =\"~A\"" domain-id))))
	 (current-time (now))
	 (year (timestamp-year current-time))
	 (month (timestamp-month current-time))
	 (day (timestamp-day current-time))
	 (hour (timestamp-hour current-time))
	 (mini (timestamp-minute current-time))
	 (sec (timestamp-second current-time))
	 (time-stamp (format nil "~A-~2,,,'0@A-~2,,,'0@A ~2,,,'0@A:~2,,,'0@A:~2,,,'0@A" year month day hour mini sec)))
    (progn
      (send-query (format nil "insert into \"lessons\" (\"lesson_id\", \"domain_id\", \"user_id\", \"created_at\", \"edited_at\") values (\"~A\", \"~A\", \"~A\", \"~A\", \"~A\")" new-lesson-id domain-id user-id time-stamp time-stamp))
      (init-concept new-lesson-id root-vocabrary-id time-stamp))
    (redirect-to-path "")))

(defun init-concept (lesson-id concept-term-id timestamp)
  (send-query (format nil "insert into user_concepts (lesson_id, node_id, parent_term_id, concept_term_id, created_at, edited_at, concept_type) values (\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\")"
		      lesson-id 1 0 concept-term-id timestamp timestamp "term")))


(defun lesson-initialize (lesson-id)
  "各Lessonのルートノードとかの準備"
  (declare (ignorable lesson-id)))

(defun make-domain-list ()
  (let ((code nil))
    (loop for x in (exist-domain-list)
	  do (push `(:li :style "font-size: 2em;margin-bottom:10px;"
			 (:a :href ,(append-root-url (format nil "/lesson-create?domain-id=~A" (first x)))
			     ,(format nil "~A" (second x))))
		   code))
    (push :ul code)
    code))
