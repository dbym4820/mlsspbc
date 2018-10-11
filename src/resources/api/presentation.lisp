(in-package :loapeat.resources.api)

#|
API
|#
(defapi get-presentations-api (sim ("purpose" "lesson-id"))
  (let ((purpose (brew-parameter sim "purpose"))
	(lesson-id (brew-parameter sim "lesson-id")))
    (cond ((string= purpose "construct-side-line")
	   (lessons-side-lines-json lesson-id))
	  ((string= purpose "construct-presentation")
	   (lessons-presentation-structure-json lesson-id))
	  ((string= purpose "construct-term-parts")
	   (lessons-term-parts-json lesson-id))
	  ((string= purpose "construct-slide-parts")
	   (lessons-slide-parts-json lesson-id))
	  (t
	   (format nil "[{}]")))))

(defapi post-presentaions-api (sim ("purpose" "lessonId" "lineId" "parentId" "childId" "type"))
  (let ((purpose (brew-parameter sim "purpose"))
	(lesson-id (brew-parameter sim "lessonId")))
    (cond ((string= purpose "save-side-line")
	   (save-side-line lesson-id
			   (brew-parameter sim "lineId")
			   (brew-parameter sim "parentId")
			   (brew-parameter sim "childId")
			   (brew-parameter sim "type")))
	  ((string= purpose "delete-side-line")
	   (delete-side-line (brew-parameter sim "lineId")))
	  (t
	   (format nil "")))))


#|
Term API
|#
(defun term-ids-term (term-id)
  (cadar (get-data *term-table* '("vocabrary") `(("id" ,term-id)))))

#|
Presentaion constructor
|#
(defun lessons-presentation-structure-json (lesson-id)
  (list-to-json '("id" "name" "parent") (lessons-presentation-structure lesson-id)))

(defun lessons-presentation-structure (lesson-id)
  (mapcar #'(lambda (node-data)
	      (list (first node-data)
		    (term-ids-term (third node-data))
		    (second node-data)))
	  (lessons-user-selected-node-id-on-graph lesson-id)))

(defun lessons-user-selected-node-id-on-graph (lesson-id)
  (mapcar #'trim-labels
	  (get-data *presentation-table* '("node_id" "parent_term_id" "concept_term_id")
		    `(("lesson_id" ,lesson-id) ("flag" "true")))))

#|==============================================
================ Presentation Parts ============
================================================
|#
(defun lessons-all-term-id (lesson-id)
  (let ((domain-id (lessons-domain lesson-id)))
    (mapcar #'(lambda (data)
		       (car (trim-labels data)))
	    (get-data *term-table* '("id")
		      `(("domain_id" ,domain-id) ("type" "term"))))))

(defun lessons-all-slide-id (lesson-id)
  (let ((domain-id (lessons-domain lesson-id)))
    (mapcar #'(lambda (data)
		(car (trim-labels data)))
	    (get-data *term-table* '("id")
		      `(("domain_id" ,domain-id) ("type" "slide"))))))
  

(defun lessons-user-selected-node-id-in-system (lesson-id)
  (mapcar #'(lambda (data)
	      (car (trim-labels data)))
	  (get-data *presentation-table* '("concept_term_id")
		    `(("lesson_id" ,lesson-id) ("flag" "true")))))

(defun lessons-user-selected-node-id-in-system (lesson-id)
  (mapcar #'(lambda (data)
	      (car (trim-labels data)))
	  (get-data *presentation-table* '("concept_term_id")
		    `(("lesson_id" ,lesson-id) ("flag" "true")))))

#|
Term parts API
|#
(defun lessons-term-parts-json (lesson-id)
  (list-to-json '("id") (lessons-term-parts lesson-id)))

(defun lessons-term-parts (lesson-id)
  (let ((lesson-all-term-id-content-list (lessons-all-term-content lesson-id)))
    (mapcar #'(lambda (data)
		(cdr (assoc data lesson-all-term-id-content-list)))
	    (lessons-user-doesnot-selected-term-id lesson-id))))

(defun lessons-all-term-content (lesson-id)
  (let ((domain-id (lessons-domain lesson-id)))
    (mapcar #'trim-labels
	    (get-data *term-table* '("id" "vocabrary")
		      `(("domain_id" ,domain-id) ("type" "term"))))))

(defun lessons-user-doesnot-selected-term-id (lesson-id)
  (let ((user-selected-term-id-list (lessons-user-selected-node-id-in-system lesson-id)))
    (loop for data in (lessons-all-term-id lesson-id)
	  unless (find data user-selected-term-id-list)
	    collect data)))

#|
Slide parts API
|#
(defun lessons-slide-parts-json (lesson-id)
  (list-to-json '("id") (lessons-slide-parts lesson-id))))

(defun lessons-slide-parts (lesson-id)
  (let ((lesson-all-slide-id-path-list (lessons-all-slide-path lesson-id)))
    (mapcar #'(lambda (data)
		(cdr (assoc data lesson-all-slide-id-path-list)))
	    (lessons-user-doesnot-selected-slide-id lesson-id))))

(defun lessons-all-slide-path (lesson-id)
  (let ((domain-id (lessons-domain lesson-id)))
    (mapcar #'trim-labels
	    (get-data *term-table* '("id" "vocabrary")
		      `(("domain_id" ,domain-id) ("type" "slide"))))))

(defun lessons-user-doesnot-selected-slide-id (lesson-id)
  (let ((user-selected-term-id-list (lessons-user-selected-node-id-in-system lesson-id)))
    (loop for data in (lessons-all-slide-id lesson-id)
	  unless (find data user-selected-term-id-list)
	    collect data)))
  

#|
Special Link operator
|#
(defun lessons-side-lines-json (lesson-id)
  (list-to-json '("parent" "child" "edgeId" "functor") (lessons-side-lines lesson-id)))

(defun lessons-side-lines (lesson-id)
  (let ((lessons-presentation-node (lessons-presentation-node-id-on-presentation lesson-id)))
    (remove-if #'null
	       (loop for line in (lessons-side-line-parent-child-id-on-graph lesson-id)
		     collect (let ((parent-id (second (assoc (first line) lessons-presentation-node)))
				   (child-id (second (assoc (second line) lessons-presentation-node)))
				   (edge-id (third line))
				   (functor "super"))
			       (when (and parent-id child-id edge-id functor)
				 (list (format nil "#~A" parent-id)
				       (format nil "#~A" child-id)
				       edge-id functor)))))))

(defun lessons-side-line-parent-child-id-on-graph (lesson-id)
  (mapcar #'trim-labels
	  (get-data *relations-table*
		    '("parent_node_id" "child_node_id" "relation_id")
		    `(("lesson_id" ,lesson-id)))))

(defun lessons-presentation-node-id-on-graph-to-system-id (lesson-id)
  (mapcar #'trim-labels
	  (get-data *presentation-table*
		    '("node_id" "concept_term_id")
		    `(("lesson_id" ,lesson-id) ("flag" "true")))))

(defun lessons-presentation-node-id-on-presentation (lesson-id)
  (loop for node in (lessons-presentation-node-id-on-graph-to-system-id lesson-id)
	collect (list (first node) (term-ids-term (second node)))))

#|
Presentation Save Unit
|#
(defun save-side-line (lesson-id line-id parent-node-id-on-presentation child-node-id-on-presentation line-type)
  (let ((parent-node-id (terms-presentation-id parent-node-id-on-presentation lesson-id))
	(child-node-id (terms-presentation-id child-node-id-on-presentation lesson-id)))
    (if (side-line-exist-p line-id)
	(update-data *relations-table*
		     `(("parent_node_id" ,parent-node-id) ("child_node_id" ,child-node-id))
		     `(("lesson_id" ,lesson-id) ("relation_id" ,line-id)))
	(insert-data *relations-table*
		     `(("relation_id" ,line-id)
		       ("parent_node_id" ,parent-node-id)
		       ("child_node_id" ,child-node-id)
		       ("lesson_id" ,lesson-id)
		       ("relation_type" ,line-type))))
    (format nil "lesson: ~A~%line: ~A~%parent: ~A~%child: ~A~%type: ~A~%" lesson-id line-id parent-node-id-on-presentation child-node-id-on-presentation line-type)))

(defun side-line-exist-p (line-id)
  (when (get-data *relations-table* '("*") `(("relation_id" ,line-id))) t))

(defun terms-id-on-presentation (term-content lesson-id)
  (let ((domain-id (lessons-domain lesson-id)))
    (cadar (get-data *term-table* '("id") `(("vocabrary" ,term-content) ("domain_id" ,domain-id))))))

(defun presentation-ids-node-id-on-graph (term-id lesson-id)
  (cadar (get-data *presentation-table* '("node_id") `(("concept_term_id" ,term-id) ("lesson_id" ,lesson-id) ("flag" "true")))))

(defun terms-presentation-id (term-content lesson-id)
  (presentation-ids-node-id-on-graph 
   (terms-id-on-presentation term-content lesson-id)
   lesson-id))

#|
Delete functions
|#
(defun delete-side-line (line-id)
  (delete-data *relations-table* `(("relation_id" ,line-id)))
  (format nil "korekaeriti: ~A" line-id))
