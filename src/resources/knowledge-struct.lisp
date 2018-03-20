(in-package :mlsspbc.resources)

;; 知識ノード
(defun knowledge-struct ()
  (let* ((lesson-id (get-parameter "lesson-id"))
	 (domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id='~A'" lesson-id)))))
    (format nil "[~{{~{id:'~A', label:'~A'~}}~^,~}]"
	    (mapcar #'(lambda (d)
			(list (second d) (fourth d)))
		    (select "knowledge_id_in_graph, knowledge_content" "domain_knowledge" (format nil "domain_id='~A'" domain-id))))))


;; 知識エッジ
(defun knowledge-edge ()
  (let* ((lesson-id (get-parameter "lesson-id"))
	 (domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id='~A'" lesson-id)))))
    (format nil "[~{{~{from:'~A', to:'~A'~}}~^,~}]"
	    (mapcar #'(lambda (d)
			(list (second d) (fourth d)))
		    (select "edge_from, edge_to" "domain_knowledge_edge" (format nil "domain_id='~A'" domain-id))))))



;; 明示知識リストを返す
(defun exp-knowledge-list ()
  (let* ((node-content (get-parameter "node-content"))
	 (lesson-id (get-parameter "lesson-id"))
	 (domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id='~A'" lesson-id))))
	 (vocabrary-id (cadar (select "id" "goal_vocabrary" (format nil "vocabrary='~A' and domain_id='~A'" node-content domain-id))))
	 (k-list-raw (cadar (select "explicit_knowledge" "goal_vocabrary" (format nil "id='~A'" vocabrary-id))))
	 (k-list (format nil "[~{{id:~A}~^,~}]"
			 (mapcar #'(lambda (d) (string-trim " " d))
				 (split-sequence:split-sequence #\, (subseq k-list-raw 1 (1- (length k-list-raw))))))))
    (format nil "~A" k-list)))

;; 潜在知識リストを返す
(defun imp-knowledge-list ()
  (let* ((node-content (get-parameter "node-content"))
	 (lesson-id (get-parameter "lesson-id"))
	 (domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id='~A'" lesson-id))))
	 (vocabrary-id (cadar (select "id" "goal_vocabrary" (format nil "vocabrary='~A' and domain_id='~A'" node-content domain-id))))
	 (k-list-raw (cadar (select "implicit_knowledge" "goal_vocabrary" (format nil "id='~A'" vocabrary-id))))
	 (k-list (format nil "[~{{id:~A}~^,~}]"
			 (mapcar #'(lambda (d) (string-trim " " d))
				 (split-sequence:split-sequence #\, (subseq k-list-raw 1 (1- (length k-list-raw))))))))
    (format nil "~A" k-list)))
