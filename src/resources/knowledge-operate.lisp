(in-package :mlsspbc.resources)

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
	       result-data)))
    (let* ((node-content (get-parameter "node-content"))
	   (lesson-id (get-parameter "lesson-id"))
	   (domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id = ~A" lesson-id))))
	   (user-k-list (shaping (get-parameter "k-list") 0 0)) ;; ((k-id exp/imp) (k-id exp/imp) ...)	
	   (system-k-list (shaping (get-parameter "system-k-list") 4 7 t)) ;; ((k-id label) (k-id label) ...)
	   (system-edge-list (shaping (get-parameter "system-edge-list") 6 4 t)) ;; ((from-k-id to-k-id) (from-k-id to-k-id) ...)
	   (current-time (now))
	   (year (timestamp-year current-time))
	   (month (timestamp-month current-time))
	   (day (timestamp-day current-time))
	   (hour (timestamp-hour current-time))
	   (mini (timestamp-minute current-time))
	   (sec (timestamp-second current-time))
	   (time-stamp (format nil "~A-~2,,,'0@A-~2,,,'0@A ~2,,,'0@A:~2,,,'0@A:~2,,,'0@A" year month day hour mini sec))
	   (new-knowledge-id (or (cadar (select "max(knowledge_id)+1" "domain_knowledge")) 1))
	   (new-knowledge-edge-id (or (cadar (select "max(edge_id)+1" "domain_knowledge_edge")) 1)))
	 

      (format nil "uk: ~A~%sk: ~A~%se: ~A~%" user-k-list system-k-list system-edge-list)
      ;; ここで，Goal_vocabraryのExplicit_Knowledgeとdomain_knowledgeのImp,Expそれぞれ(vocabrary = nodeContentのとこ)をアップデートする．Domain_knowledgeにはインサートかアップデート．同じドメインIDの場合，それらすべてを破棄した後
      ;; まず，関係するドメイン知識をすべて破棄
      ;;(send-query (format nil "delete from \"domain_knowledge\" where \"domain_id\" = ~A" domain-id))
      )))


(defpage slide-knowledge-operate ()
  `(:div))

(defun slide-knowledge-save ()
  )

(defpage term-knowledge-operate ()
  `(:div))

(defun term-knowledge-save ()
  )

(defun k-list-create ()
  "(1 2 3 4)形式のリストを受け取って{1,2,3,4,5...}のデータを返す")

(defun k-list-analyse ()
  "{1,2,3,4,...}を分解して(1 2 3 4...)形式のリストを返す")
