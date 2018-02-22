(in-package :mlsspbc.resources)

(defpage domain-create-page ()
  `(:form :action ,(append-root-url "/domain-create") :method "post"
	  (:p "ドメイン")
	  (:input :type "text" :name "domain-name")
	  (:input :type "submit" :value "send")))


(defun domain-create ()
  (let* ((domain-name (post-parameter "domain-name"))
	 (user-id (session-value 'user-id))
	 (domain-id (cadar (select "max(domain_id)+1" "educational_domain")))
	 (current-time (now))
	 (year (timestamp-year current-time))
	 (month (timestamp-month current-time))
	 (day (timestamp-day current-time))
	 (hour (timestamp-hour current-time))
	 (mini (timestamp-minute current-time))
	 (sec (timestamp-second current-time))
	 (time-stamp (format nil "~A-~2,,,'0@A-~2,,,'0@A ~2,,,'0@A:~2,,,'0@A:~2,,,'0@A" year month day hour mini sec))
	 (new-vocabrary-id (cadar (select "max(id)+1" "goal_vocabrary")))
	 (new-lesson-id (cadar (select "max(lesson_id)+1" "lessons"))))
    (progn
      (send-query (format nil "insert into \"educational_domain\" (\"domain_id\", \"domain_name\", \"root_vocabrary_id\", \"defined_by\", \"created_at\", \"edited_at\") values (\"~A\", \"~A\", \"~A\", \"~A\", \"~A\", \"~A\")" domain-id domain-name new-vocabrary-id user-id time-stamp time-stamp))
      (goal-vocabrary-init new-vocabrary-id domain-id domain-name user-id time-stamp)
      (lesson-init new-lesson-id domain-id user-id time-stamp)
      (concept-init new-lesson-id new-vocabrary-id time-stamp))
    (redirect-to-path "")))

(defun goal-vocabrary-init (new-vocabrary-id domain-id domain_name user-id timestamp)
  (send-query (format nil "insert into goal_vocabrary (id, vocabrary, domain_id, defined_by, created_at, edited_at, type, explicit_knowledge, implicit_knowledge) values (\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\")"
		      new-vocabrary-id (format nil "~Aについて理解させる" domain_name) domain-id user-id timestamp timestamp "term" "{}" "{}")))

(defun lesson-init (new-lesson-id domain-id user-id timestamp)
  (send-query (format nil "insert into lessons (lesson_id, domain_id, user_id, created_at, edited_at) values (\"~A\",\"~A\",\"~A\",\"~A\",\"~A\")"
		      new-lesson-id domain-id user-id timestamp timestamp)))

(defun concept-init (lesson-id concept-term-id timestamp)
  (send-query (format nil "insert into user_concepts (lesson_id, node_id, parent_term_id, concept_term_id, created_at, edited_at, concept_type) values (\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\")"
		      lesson-id 1 0 concept-term-id timestamp timestamp "term")))

(defun exist-domain-list ()
  (mapcar #'(lambda (d) (list (second d) (fourth d)))
	  (select "domain_id, domain_name" "educational_domain")))
