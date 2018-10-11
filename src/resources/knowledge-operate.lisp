(in-package :loapeat.resources)

(defpage knowledge-operate ()
  `(:div
    (:form :action ,(append-root-url "/knowledge-save") :method "get"
	   (:label "Knowledge: "
		   (:input :type "text" :name "know" :placeholder "knowledge" :style "width:1000"))
	   (:input :type "hidden" :name "lesson-id" :value ,(get-parameter "lesson-id"))
	   (:input :type "submit" :name "sub" :value "send"))
    (:div :id "knowledge-structure")))

(defun knowledge-save ()
  (labels ((shaping (raw-data trim-from-even trim-from-odd &optional trim-end)
	     (let* ((full (mapcar #'(lambda (d)
				      (string-trim "}" (string-trim "{" (string-trim "\"" (string-trim " " d)))))
				  (split-sequence:split-sequence #\, (subseq raw-data 1 (1- (length raw-data))))))
		    (even-data (loop for x from 0
				     for y in full
				     when (evenp x)
				       collect (subseq y trim-from-even (if trim-end (1- (length y)) (length y)))))
		    (odd-data (loop for x from 0
				    for y in full
				    when (oddp x)
				      collect (subseq y trim-from-odd (if trim-end (1- (length y)) (length y)))))
		    (result-data (mapcar #'list even-data odd-data)))
	       result-data))
	   (moment-timestamp (&optional (addition ""))
	     (let* ((current-time (now))
		    (year (timestamp-year current-time))
		    (month (timestamp-month current-time))
		    (day (timestamp-day current-time))
		    (hour (timestamp-hour current-time))
		    (mini (timestamp-minute current-time))
		    (sec (timestamp-second current-time))
		    (time-stamp (format nil "~A~2,,,'0@A~2,,,'0@A~2,,,'0@A~2,,,'0@A~2,,,'0@A~A" year month day hour mini sec addition)))
	       time-stamp)))
    (let* ((node-content (get-parameter "node-content"))
	   (lesson-id (get-parameter "lesson-id"))
	   (domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id = ~A" lesson-id))))
	   (vocabrary-id (cadar (select "id" "goal_vocabrary" (format nil "domain_id = \"~A\" and vocabrary = \"~A\"" domain-id node-content))))
	   (user-k-list (shaping (get-parameter "k-list") 0 0)) ;; ((k-id exp/imp) (k-id exp/imp) ...)	
	   (system-k-list (shaping (get-parameter "system-k-list") 4 7 t)) ;; ((k-id label) (k-id label) ...)
	   (system-edge-list (shaping (get-parameter "system-edge-list") 6 4 t))) ;; ((from-k-id to-k-id) (from-k-id to-k-id) ...)
      
      ;; 知識ノードのdomain_knowledgeテーブルへのインサートかアップデート
      (sql-delete "domain_knowledge" (format nil "domain_id='~A'" domain-id))
      (loop for x in system-k-list
	    do (let* ((timestamp (moment-timestamp))
		     (k-id (first x))
		     (k-content (second x)))
		 (insert "domain_knowledge" "knowledge_id, knowledge_id_in_graph, knowledge_content, domain_id, created_at, edited_at"
			 (format nil "'~A','~A','~A','~A','~A','~A'" (moment-timestamp (random 1000)) k-id k-content domain-id timestamp timestamp))))

      ;; エッジのdomain_knowledge_edgeでのアップデート（総入れ替え）
      (sql-delete "domain_knowledge_edge" (format nil "domain_id='~A'" domain-id))
      (loop for x in system-edge-list
	    do (let ((timestamp (moment-timestamp)))
		 (insert "domain_knowledge_edge" "edge_id, edge_from, edge_to, domain_id, created_at, edited_at"
			 (format nil "'~A','~A','~A','~A','~A','~A'" (moment-timestamp (random 1000)) (first x) (second x) domain-id timestamp timestamp))))

      ;; 知識ノードのGoal_vocabraryのアップデート
      ;; 明示
      (update "goal_vocabrary" (format nil "'explicit_knowledge'='~A'"
				       (format nil "{~{\"~A\"~^,~}}" (mapcar #'car (remove-if #'(lambda (im-ex)
												  (string= "imp" (second im-ex)))
											      user-k-list))))
	      (format nil "id='~A'" vocabrary-id))
      ;; 潜在
      (update "goal_vocabrary" (format nil "'implicit_knowledge'='~A'"
				       (format nil "{~{\"~A\"~^,~}}" (mapcar #'car (remove-if #'(lambda (im-ex)
												  (string= "exp" (second im-ex)))
											      user-k-list))))
	      (format nil "id='~A'" vocabrary-id))
      )))


(defpage slide-knowledge-operate ()
  `(:div))

(defun slide-knowledge-save (lesson-id)
  ;; スライドの親ノードをたどって，すべての知識をマッピング
  ;; しようと思ってたけど，実際に知識を持つのは，スライド直前リーフノードだけで，その上のノードは，リーフノードが持つ知識の集合そのものになるはず
  ;; なので，スライドの１つ親ノードをすべて見つけ，それらの知識を当該スライドの知識にすればいい
  ;; 今は念の為，domain_slideとgoal_vocabraryのどちらにも明示/潜在データを挿入しておくがいずれはdomain_slideに固定したい

  ;; 今のレッスン内（操作している教師の）にあるスライドの情報を取得

  (let* ((domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id='~A'" lesson-id))))
	 (nid-eximklist-list
	   (loop for xd in
			(mapcar #'(lambda (vid-voc)
				    (list
				     (first vid-voc)
				     (mapcar #'(lambda (pid)
						 (cadar (select "concept_term_id" "user_concepts"
								(format nil "lesson_id='~A' and node_id='~A'" lesson-id pid))))
					     (append
					      (mapcar #'second (select "parent_node_id" "other_relations" 
								       (format nil "child_node_id='~A'"
									       (cadar (select "node_id" "user_concepts"
											      (format nil "concept_term_id='~A'"
												      (first vid-voc)))))))
					      
					      (mapcar #'second
						      (select "parent_term_id" "user_concepts"
							      (format nil "concept_term_id = ~A" (first vid-voc))))))))
				(mapcar #'(lambda (vid-vv-vty-tmp-without-term)
					    (list (first vid-vv-vty-tmp-without-term) (second vid-vv-vty-tmp-without-term)))
					(remove-if #'(lambda (vid-vv-vty-tmp)
						       (not (string= "slide" (third vid-vv-vty-tmp))))
						   (mapcar #'(lambda (vid-vv-vty)
							       (loop for x in vid-vv-vty
								     for y from 0
								     when (oddp y)
								       collect x))					     
							   (select "goal_vocabrary.id, goal_vocabrary.vocabrary, goal_vocabrary.type" "goal_vocabrary, user_concepts"
								   (format nil "user_concepts.lesson_id = '~A' and goal_vocabrary.id = user_concepts.concept_term_id" lesson-id))))))
		 collect (cons
			  (first xd)
			  (mapcar #'(lambda (dd)
				      (let ((tmp (select "explicit_knowledge, implicit_knowledge" "goal_vocabrary"
							 (format nil "id = '~A'" dd))))
					(list (car (mapcar #'second tmp))
					      (car (mapcar #'fourth tmp)))))
				  (second xd)))))
	 (nid-ex-im-k
	   (mapcar #'(lambda (d)
		       (list
			(first d)
			(mapcar #'(lambda (dd)
				    (loop for x in dd
					  collect (split-sequence:split-sequence #\, (string-trim "}" (string-trim "{" (string-trim "\"" x))))))
				(subseq d 1))))
		   nid-eximklist-list))
	 (nid-expklist-impklist
	   (mapcar #'(lambda (x)
		       (list
			(first x)
			(remove-if #'(lambda (str)
				       (string= str ""))
				   (alexandria:flatten 
				    (loop for d in (second x)
					  collect (first d))))
			(remove-if #'(lambda (str)
				       (string= str ""))
				   (alexandria:flatten 
				    (loop for d in (second x)
					  collect (second d))))))
		   nid-ex-im-k)))

    (loop for slide-info-list in nid-expklist-impklist
	  ;; goal_vocabraryへのセーブ
	  do (update "goal_vocabrary" (format nil "explicit_knowledge='~A', implicit_knowledge='~A'"
					      (if (second slide-info-list)
						  (format nil "{~{~A~^,~}}" (second slide-info-list))
						  (format nil "{}"))
					      (if (third slide-info-list)
						  (format nil "{~{~A~^,~}}" (third slide-info-list))
						  (format nil "{}")))
		     (format nil "domain_id='~A' and id='~A'" domain-id (first slide-info-list)))
	     ;; domain_slideへのセーブ
	  do (update "domain_slide" (format nil "explicit_knowledge='~A', implicit_knowledge='~A'"
					    (if (second slide-info-list)
						(format nil "{~{~A~^,~}}" (second slide-info-list))
						(format nil "{}"))
					    (if (third slide-info-list)
						(format nil "{~{~A~^,~}}" (third slide-info-list))
						(format nil "{}")))
		     (format nil "domain_id='~A' and slide_path='~A'" 
			     domain-id
			     (cadar (select "vocabrary" "goal_vocabrary" (format nil "id='~A'" (first slide-info-list)))))))))







(defpage term-knowledge-operate ()
  `(:div))

(defun term-knowledge-save ()
  )

(defun k-list-create ()
  "(1 2 3 4)形式のリストを受け取って{1,2,3,4,5...}のデータを返す")

(defun k-list-analyse ()
  "{1,2,3,4,...}を分解して(1 2 3 4...)形式のリストを返す")
