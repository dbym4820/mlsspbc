(in-package :loapeat.resources.api)

#|
API
|#
(defapi get-semantics-api (sim ("purpose" "lesson-id" "user-id" "slide-id" "content"))
  (let ((purpose (brew-parameter sim "purpose"))
	(lesson-id (brew-parameter sim "lesson-id"))
	(user-id (brew-parameter sim "user-id"))
	(slide-id (brew-parameter sim "slide-id"))
	(content (brew-parameter sim "content")))
    (declare (ignorable lesson-id user-id slide-id content))
    (cond ((string= purpose "construct-auth-semantics")
	   (slide-semantic-node-json (paths-slide-id content)))
	  ((string= purpose "construct-auth-semantics-edge")
	   (slide-semantic-edge-json (paths-slide-id content)))
	   (t
	    (format nil "[{}]")))))


#|
Jsonfy Functions
|#
(defun slide-semantic-node-json (slide-id)
  (list-to-json '("id" "label" "group") (slides-semantics slide-id)))

(defun slide-semantic-edge-json (slide-id)
  (list-to-json '("from" "to") (slides-edges slide-id)))


#|
Teachers (Correct) semantics operator
|#
(defun paths-slide-id (slide-path)
  (cadar (get-data *slide-table* '("slide_id") `(("slide_path" ,slide-path)))))

(defun domains-semantic-node (domain-id)
  (mapcar #'trim-labels
	  (get-data *semantic-node-table*
		    '("knowledge_id_in_graph" "knowledge_content" "node_type")
		    `(("domain_id" ,domain-id)))))
  
(defun slides-explicit-knowledge (slide-id)
  (let ((raw-data (cadar (get-data *slide-table* '("explicit_knowledge") `(("slide_id" ,slide-id))))))
    (string-list-to-list raw-data)))

(defun slides-implicit-knowledge (slide-id)
  (let ((raw-data (cadar (get-data *slide-table* '("implicit_knowledge") `(("slide_id" ,slide-id))))))
    (string-list-to-list raw-data)))

(defun lessons-semantic-node (lesson-id)
  (let ((domain-id (lessons-domain lesson-id)))
    (domains-semantic-node domain-id)))


(defun lessons-semantic-edge (lesson-id)
  (let ((domain-id (lessons-domain lesson-id)))
    (domains-semantic-edge domain-id)))

(defun domains-semantic-edge (domain-id)
  (mapcar #'trim-labels
	  (get-data *semantic-edge-table*
		    '("edge_from" "edge_to")
		    `(("domain_id",domain-id)))))

(defun slides-semantics (slide-id)
  (let* ((domains-node-id-list (domains-semantic-node (slides-domain slide-id)))
	 (exp-node-id-list (slides-explicit-knowledge slide-id))
	 (imp-node-id-list (slides-implicit-knowledge slide-id)))
    (loop for single-data-list in domains-node-id-list
	  when (find (first single-data-list) exp-node-id-list :test #'string=)
	    collect (list "exp" (first single-data-list) (second single-data-list) (third single-data-list))
	  when (find (first single-data-list) imp-node-id-list :test #'string=)
	    collect (list "imp" (first single-data-list) (second single-data-list) (third single-data-list)))))

(defun slides-edges (slide-id)
  (let* ((domain-id (slides-domain slide-id))
	 (domain-edge-list (domains-semantic-edge domain-id))
	 (slide-node-id-list (mapcar #'second (slides-semantics slide-id))))
    (loop for edge in domain-edge-list
	  when (and (find (first edge) slide-node-id-list :test #'string=)
		    (find (second edge) slide-node-id-list :test #'string=))
	  collect edge)))
