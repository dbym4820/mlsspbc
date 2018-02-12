(in-package :mlsspbc.resources)

;; usage: (get-timestamp (now))
(defun get-timestamp (current-time)
  (let ((year (timestamp-year current-time))
	(month (timestamp-month current-time))
	(day (timestamp-day current-time))
	(hour (timestamp-hour current-time))
	(mini (timestamp-minute current-time))
	(sec (timestamp-second current-time)))
    (format nil "~A-~2,,,'0@A-~2,,,'0@A ~2,,,'0@A:~2,,,'0@A:~2,,,'0@A" year month day hour mini sec)))

;;; Legacy codes for the database whixh has just json-text as a data
;; (defunction-page load-concept-map ()
;;   (let* ((user-name (session-value 'username))
;; 	 (user-id (cadar (select "\"user-id\"" "users" (format nil "name=\"~A\"" user-name)))))
;;     (cadar (select "\"intent_tree\"" "concept" (format nil "\"user_id\"=\"~A\"" user-id)))))
(defun user-concept-encoder (json-list)
  (let ((str "["))
    (labels ((req (head tail tmp-str)
	       (cond ((null tail)
		      (format nil "~A\{\"id\":\"~A\",\"name\":\"~A\",\"parent\":\"~A\"\}]"
			      tmp-str (first head) (second head) (third head)))
		     ((listp head)
		      (format nil "~A\{\"id\":\"~A\",\"name\":\"~A\",\"parent\":\"~A\"\},~A"
			      tmp-str (first head) (or (second head) "") (third head) (req (car tail) (cdr tail) ""))))))
      (req (car json-list) (cdr json-list) str))))

(defunction-page load-concept-map ()
  (let* ((lesson-id (get-parameter "lessonid")))
    (user-concept-encoder
     (mapcar (lambda (d) 
    	       (list (format nil "~A" (second d))
    		     (second (car (select "vocabrary" "goal_vocabrary" (format nil "id=\"~A\"" (or (sixth d) "")))))
    		     (format nil "~A" (fourth d))))
    	     (select "node_id, parent_term_id, concept_term_id" "user_concepts" (format nil "\"lesson_id\"=\"~A\"" lesson-id))))))

;;; 表示には関係しない
;;; 概念情報を取得する
(defun get-concept-info (node-id)
  (let* (;; (user-name "tomoki")
	 (lesson-id (get-parameter "lessonid"))
	 (vocabrary (second (car (select "vocabrary" "goal_vocabrary" (format nil "id=~A" node-id)))))
	 (parent-id (list
		     (second (car (select "parent_term_id" "user_concepts" (format nil "(concept_term_id=~A) and (lesson_id=~A)" node-id lesson-id)))))
		    )
	 (child-id (mapcar #'second 
		 (select "concept_term_id" "user_concepts" (format nil "(parent_term_id=~A)" node-id)))))
    (format nil "vocabrary: ~A~%parent: ~A~%child: ~A~%" vocabrary parent-id child-id)))


(defun relation-encoder (json-list)
  (let ((str "["))
    (labels ((req (head tail tmp-str)
	       (cond ((null tail)
		      (format nil "{\"parent\":\"#~A\",\"child\":\"#~A\",\"function\":\"#~A\"\}]"
			      (first head) (second head) (third head)))
		     ((listp head)
		      (format nil "~A\{\"parent\":\"#~A\",\"child\":\"#~A\",\"function\":\"#~A\"\},~A"
			      tmp-str (first head) (second head) (third head) (req (car tail) (cdr tail) ""))))))
      (req (car json-list) (cdr json-list) str))))

(defunction-page load-slide-line-list ()
  (let* ((lesson-id 1)
	 (data-set (select "parent_node_id,child_node_id,relation_type" "other_relations" (format nil "(lesson_id=~A)" lesson-id))))
    (labels ((get-vocabrary (id-num)
	       (second (car (select "vocabrary" "goal_vocabrary" (format nil "id=~A" id-num))))))
      (relation-encoder (mapcar #'(lambda (d) (list (get-vocabrary (second d)) (get-vocabrary (fourth d)) (sixth d))) data-set)))))


;;; 概念間の関係を取得する
;; (defun get-relations ()
  


;; not yet
;; (defunction-page save-concept-map ()
;;   (let* (;; (user-name (session-value 'username))
;; 	 ;; (user-id (cadar (select "user_id" "user" (format nil "user_name=\"~A\"" user-name))))
;; 	 (data (post-parameter "dat"))
;; 	 ;; (timestamp (get-timestamp (now)))
;; 	 )
;;     ;; ;; (update "concept" (format nil "intent_tree='~A', edited_at='~A'" data timestamp) (format nil "user_id='~S'" user-id))
;;     (format nil "~A" data)
;;     ))


(defunction-page save-concept-map ()
  (let* (;; (user-name "tomoki")
	 ;; (user-id (cadar (select "user_id" "user" (format nil "user_name=\"~A\"" user-name))))
	 (lesson-id (get-parameter "lessonid"))
	 (timestamp (get-timestamp (now)))
	 (data (post-parameter "dat"))
	 (latest-user-concept (loop for x in (decode-json-from-string (format nil "~A" data))
	  			    collect (list
					     (cons :node-id (cdr (first x)))
					     (cons :vocabrary-id (second (car (select "id" "goal_vocabrary" (format nil "vocabrary=\"~A\"" (cdr (second x)))))))
					     (third x)
					     (cons :type (or (second (car (select "type" "goal_vocabrary" (format nil "id=\"~A\"" (or (cdr (first x)) 1))))) "term")))))
	 (old-user-concept (loop for d in (select "concept_term_id, parent_term_id, node_id" "user_concepts"
						  (format nil "\"lesson_id\"=\"~A\"" lesson-id))
				 collect (list (cons :node-id (format nil "~A" (sixth d)))
					       (cons :vocabrary-id (format nil "~A" (second d)))
					       (cons :parent (format nil "~A" (fourth d)))
					       (cons :type (second (car (select "type" "goal_vocabrary" (format nil "id=\"~A\"" (or (second d) 1))))))))))
    (let ((insert-list nil)
	  (update-list nil)
	  (delete-list nil)
	  (frag nil))
      (declare (ignorable frag))
      (loop for x in latest-user-concept
    	    do (progn
		 (setf frag nil)
		 (loop for y in old-user-concept
		       when (equal (format nil "~A" (cdr (first x))) (cdr (first y)))
      			 do (progn
      			      (push x update-list)
      			      (setf frag t))))
      	    unless frag
      	      do (push x insert-list))

      (loop for x in old-user-concept
	    do (progn
		 (setf frag nil)
		 (loop for y in latest-user-concept
		       when (equal (format nil "~A" (cdr (first y))) (cdr (first x)))
			 do (progn
			      (setf frag t)
			      (loop-finish))))
	    unless frag
	      do (push x delete-list))
      (when update-list
      	(loop for d in update-list
      	      do (update "user_concepts" (format nil "\"parent_term_id\"=\"~A\",\"concept_type\"=\"~A\",\"concept_term_id\"=\"~A\",\"edited_at\"=\"~A\""
      						 (cdr (third d)) (cdr (fourth d)) (cdr (second d)) timestamp)
      			 (format nil "\"node_id\"=\"~A\" and \"lesson_id\"=\"~A\"" (cdr (first d)) lesson-id))))
      (when insert-list
      	(insert "user_concepts" "\"lesson_id\",\"node_id\",\"parent_term_id\",\"concept_term_id\",\"created_at\",\"edited_at\",\"concept_type\""
      		(format nil "~:{(\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\")~:^,~}"
      			(loop for d in insert-list
      			      collect (list lesson-id (cdr (first d)) (cdr (third d)) (cdr (second d)) timestamp timestamp (cdr (fourth d)))))))
      (when delete-list
	(loop for d in delete-list
	      do (sql-delete "user_concepts" (format nil "(\"lesson_id\"=\"~A\") and (\"node_id\"=\"~A\")" lesson-id (cdr (first d)))))))))



(defunction-page load-intent-list ()
  (let* ((lesson-id (get-parameter "lessonid")))
    (format nil "[~{\{\"id\":\"~A\"\}~^,~}]"
	    (reverse (mapcar #'second
		    (remove-if #'symbolp
			       (send-query (format nil "select vocabrary from goal_vocabrary left outer join user_concepts on (goal_vocabrary.id=user_concepts.concept_term_id) where (domain_id in (select domain_id from lessons where lesson_id=\"~A\")) and (type=\"term\") and ((lesson_id is null) or (not (lesson_id=\"~A\")))" lesson-id lesson-id))))))))

;;not yet (below from here are all not yet
(defunction-page save-intent-list ()
  (let* ((user-name (session-value 'user-name))
	 (user-id (cadar (select "user_id" "user" (format nil "user_name=\"~A\"" user-name))))
	 (data (post-parameter "dat"))
	 (timestamp (get-timestamp (now))))
    (update "intent" (format nil "intent_tree='~A', edited_at='~A'" data timestamp) (format nil "user_id='~S'" user-id))))


(defunction-page add-intent-list ()
  (let* ((lesson-id (post-parameter "lesson-id"))
	 (domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id=\"~A\"" lesson-id))))
	 (new-intent (post-parameter "newintent"))
	 (user-id (session-value 'user-id)))
	 (insert-intent domain-id new-intent user-id)
    (redirect-to-path (format nil "authering/authering-intension-map?lesson-id=~A" lesson-id))))

(defun insert-intent (domain-id new-intent user-id)
  (let ((new-vocabrary-id (cadar (select "max(id)+1" "goal_vocabrary")))
	(timestamp (get-timestamp (now))))
    (send-query (format nil "insert into goal_vocabrary (\"id\", \"vocabrary\", \"domain_id\", \"defined_by\", \"created_at\", \"edited_at\", \"type\", \"explicit_knowledge\", \"implicit_knowledge\") values (\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\")"
			new-vocabrary-id new-intent domain-id user-id timestamp timestamp "term" "{}" "{}"))))


(defunction-page save-side-line-list ()
  (let ((data (post-parameter "dat")))
    (with-open-file (file (format nil "~Aconcepts/side-line.json" (config :static-path)) :if-exists :supersede :direction :output)
      (format file data))))


(defunction-page find-parent-node-id ()
  (let* ((json-string (post-parameter "jsonObject"))
	 (concept-name (post-parameter "conceptName"))
	 ;;(concepts-json (second (first (select "intent_tree" "concept" "user_id=1"))))
	 (decoded-json (decode-json-from-string json-string)))
    (format nil "~A"
	    (cdar (remove nil 
			  (mapcar #'(lambda (assoc-list)
				      (when (string= concept-name
						     (cdr (assoc :name assoc-list)))
					(assoc :parent assoc-list)))
				  decoded-json))))))
