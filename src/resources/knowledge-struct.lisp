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
