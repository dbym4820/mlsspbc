(in-package :cl-user)
(defpackage loapeat.resources.api
  (:use :cl)
  (:import-from :cl-annot
   :enable-annot-syntax)
  (:import-from :loapeat.db
                :send-query
  		:select :update :insert :sql-delete)
  (:import-from :loapeat.web-utils
                :request-host
  		:root-url
  		:site-path
  		:redirect-to-path
  		:remove-session
  		:session-value
  		:set-session-value
  		:post-parameter
                :post-parameters
                :get-parameter)
  (:import-from :cl-json
  		:decode-json-from-string)
  (:import-from :local-time
  		:now
  		:timestamp-year
  		:timestamp-month
  		:timestamp-day
  		:timestamp-hour
  		:timestamp-minute
  		:timestamp-second))
  
(in-package :loapeat.resources.api)


#|
Basic functions and Macros related with API
|#
(defmacro defapi (api-name (value-symbol get-post-request-parameter-list) &body body)
  (let* ((test-symbol (gensym))
	 (api-type (cond ((string= "POST" (subseq (format nil "~A" api-name) 0 4)) 'post)
			 ((string= "GET" (subseq (format nil"~A" api-name) 0 3)) 'get))))
    (setf test-symbol value-symbol)
    (cond ((eq api-type 'get)
	   (let ((get-param-list
		   (loop for request-parameter in get-post-request-parameter-list
			 collect `(cons ,request-parameter (get-parameter ,request-parameter)))))
	     `(defun ,api-name ()
		(let ((,test-symbol (list ,@get-param-list)))
		    ,@body))))
	   ((eq api-type 'post)
	    (let ((post-param-list
		   (loop for request-parameter in get-post-request-parameter-list
			 collect `(cons ,request-parameter (post-parameter ,request-parameter)))))
	    `(defun ,api-name ()
	       (let ((,test-symbol (list ,@post-param-list)))
		   ,@body)))))))

(defun brew-parameter (parameter-list-symbol brew-parameter-string)
  "(brew-parameter sim \"lesson-id\") => 1"
  (cdr (assoc brew-parameter-string parameter-list-symbol :test #'string=)))

(defun get-timestamp ()
  (let* ((current-time (now))
	 (year (timestamp-year current-time))
	 (month (timestamp-month current-time))
	 (day (timestamp-day current-time))
	 (hour (timestamp-hour current-time))
	 (mini (timestamp-minute current-time))
	 (sec (timestamp-second current-time)))
    (format nil "~A-~2,,,'0@A-~2,,,'0@A ~2,,,'0@A:~2,,,'0@A:~2,,,'0@A" year month day hour mini sec)))


#|
CLOS Class related with Database table
|#
(defclass database-schema ()
  ((table-name :initform nil :reader table-name)
   (created-at :initarg :created-at :initform (get-timestamp) :accessor created-at)
   (edited-at :initarg :edited-at :initform (get-timestamp) :accessor edited-at)))

(defgeneric get-data (database-schema list object))
(defmethod get-data ((table-instance database-schema) (obtain-value-list list) (restriction-cons-list list))
  (handler-case
      (select (format nil "~{~A~^,~}" obtain-value-list)
	      (table-name table-instance)
	      (format nil "~{~A ~^and ~}"
		      (loop for restrict in restriction-cons-list
			    collect (let ((column-name (first restrict))
					  (column-value (second restrict)))
				      (format nil "~A='~A'" column-name column-value)))))
    (dbi.error:<dbi-programming-error> ()
      (format nil ""))))

(defgeneric update-data (database-schema object list))
(defmethod update-data ((table-instance database-schema) (update-key-value-list list) (restriction-cons-list list))
  (handler-case
      (progn
	(update (table-name table-instance)
		(format nil "~{~A~^, ~}"
			(loop for data in update-key-value-list
			      collect (let ((column-name (first data))
					    (column-value (second data)))
					(format nil "~A='~A'" column-name column-value))))
		(format nil "~{~A ~^and ~}"
			(loop for restrict in restriction-cons-list
			      collect (let ((column-name (first restrict))
					    (column-value (second restrict)))
					(format nil "~A='~A'" column-name column-value)))))
	(format nil "success"))
    (dbi.error:<dbi-programming-error> ()
      (format nil ""))))

(defgeneric insert-data	 (database-schema list))
(defmethod insert-data ((table-instance database-schema) (insert-key-value-list list))
  (let* ((timestamp (get-timestamp))
	 (timestamp-key-value-list `(("created_at" ,timestamp) ("edited_at" ,timestamp)))
	 (insert-list-time-appended (append timestamp-key-value-list insert-key-value-list)))
    (handler-case
	(progn
	  (insert (table-name table-instance)
		  (format nil "~{~A~^, ~}"
			  (mapcar #'first insert-list-time-appended))
		  (format nil "~{'~A'~^, ~}"
			  (mapcar #'second insert-list-time-appended)))
	  (format nil "success"))
      (dbi.error:<dbi-programming-error> ()
	(format nil "")))))

(defgeneric delete-data (database-schema list))
(defmethod delete-data ((table-instance database-schema) (restriction-cons-list list))
  (handler-case
      (progn
	(sql-delete (table-name table-instance)
		    (format nil "~{~A ~^and ~}"
			    (loop for restrict in restriction-cons-list
				  collect (let ((column-name (first restrict))
						(column-value (second restrict)))
					    (format nil "~A='~A'" column-name column-value)))))
	(format nil "success"))
    (dbi.error:<dbi-programming-error> ()
      (format nil ""))))

(defclass lesson (database-schema)
  ((table-name :initform "lessons")
   (lesson-id :initarg :lesson-id :accessor lesson-id)
   (domain-id :initarg :domain-id :accessor domain-id)
   (learner-id :initarg :learner-id :accessor learner-id)))

(defclass user (database-schema)
  ((table-name :initform "user")
   (user-id :initarg :user-id :accessor user-id)
   (user-name :initarg :user-name :accessor user-name)
   (mail :initarg :mail :accessor mail)
   (user-type :initarg :user-type :initform "learner" :accessor user-type)
   (password :initarg :password :accessor password)
   (gender :initarg :gender :accessor gender)
   (birth-year :initarg :birth-year :accessor birth-year)
   (birth-month :initarg :birth-month :accessor birth-month)
   (birth-day :initarg :birth-day :accessor birth-day)
   (nationality :initarg :nationality :accessor nationality)))
   
(defclass domain-semantic-node (database-schema)
  ((table-name :initform "domain_knowledge")
   (knowledge-id :initarg :knowledge-id :accessor knowledge-id)
   (knowledge-id-in-graph :initarg :knowledge-id-in-graph :accessor kid-in-graph)
   (knowledge-content :initarg :content :accessor content)
   (node-type :initarg :node-type :initform "fact" :accessor node-type)
   (domain-id :initarg :domain-id :accessor domain-id)))

(defclass domain-semantic-edge (database-schema)
  ((table-name :initform "domain_knowledge_edge")
   (edge-id :initarg :edge-id :accessor edge-id)
   (edge-from :initarg :edge-from :accessor edge-from)
   (edge-to :initarg :edge-to :accessor edge-to)
   (domain-id :initarg :domain-id :accessor domain-id)))

(defclass slide (database-schema)
  ((table-name :initform "domain_slide")
   (slide-id :initarg :slide-id :accessor slide-id)
   (domain-id :initarg :domain-id :accessor domain-id)
   (path-name-to-slide :initarg :slide-path :accessor slide-path)
   (slide-title :initarg :slide-title :initform "" :accessor slide-title)
   (explicit-knowledge-list :initarg :explicit :accessor explicit)
   (implicit-knowledge-list :initarg :implicit :accessor implicit)
   (slide-errata :initarg :errata :accessor errata)))

(defclass other-relation (database-schema)
  ((table-name :initform "other_relations")
   (relation-id :initarg :relation-id :accessor relation-id)
   (parent-node-id-on-graph :initarg :parent-node-id :accessor parent-node-id)
   (chid-node-id-on-graph :initarg :child-node-id :accessor child-node-id)
   (lesson-id :initarg :lesson-id :accessor lesson-id)
   (relation-type :initarg :relation-type :accessor relation-type)))

(defclass educational-domain (database-schema)
  ((table-name :initform "educational_domain")
   (domain-id :initarg :domain-id :accessor domain-id)
   (domain-name :initarg :domain-name :accessor domain-name)
   (root-goal-id :initarg :root-goal-id :accessor :root-goal-id)
   (owner-id :initarg :owner-id :accessor :owner-id)))

(defclass goal-term (database-schema)
  ((table-name :initform "goal_vocabrary")
   (term-id :initarg :term-id :accessor term-id)
   (term-content-or-slide-id :initarg :term-content :accessor term-content)
   (domain-id :initarg :domain-id :accessor :domain-id)
   (owner-id :initarg :owner-id :accessor owner-id)
   (term-type :initarg :term-type :initform "term" :accessor term-type)
   (included-knowledge-list :initarg :knowledge-list :accessor knowledge-list)))

(defclass user-presentation (database-schema)
  ((table-name :initform "user_concepts")
   (lesson-id :initarg :lesson-id :accessor lesson-id)
   (node-id-on-graph :initarg :node-id-on-graph :accessor node-id-on-graph)
   (parent-node-id-on-graph :initarg :parent-node-id-on-graph :accessor parent-node-id-on-graph)
   (term-id-in-system :initarg :term-id-in-system :accessor term-id-in-system)))

(defclass user-kma (database-schema)
  ((table-name :initform "user_slide")
   (kma-id :initarg :kma-id :accessor kma-id)
   (lesson-id :initarg :lesson-id :accessor lesson-id)
   (slide-id :initarg :slide-id :accessor slide-id)
   (kma-result :initarg :kma-result :accessor kma-result)))


#|
Simple table instances
|#
(defvar *lesson-table* (make-instance 'lesson))
(defvar *user-table* (make-instance 'user))
(defvar *semantic-node-table* (make-instance 'domain-semantic-node))
(defvar *semantic-edge-table* (make-instance 'domain-semantic-edge))
(defvar *slide-table* (make-instance 'slide))
(defvar *relations-table* (make-instance 'other-relation))
(defvar *domain-table* (make-instance 'educational-domain))
(defvar *term-table* (make-instance 'goal-term))
(defvar *presentation-table* (make-instance 'user-presentation))
(defvar *kma-table* (make-instance 'user-kma))

#|
Basic functions to generate API
|#
(defun list-to-json (label-list data-list)
  "(list-to-json '(\"id\" \"label\") '((1 \"hogehoge\") (2 \"blahblah\")) => [{'id':'hogehoge', 'label':'blahblah'}]"
  (format nil "[~{~A~^, ~}]"
	  (loop for data in data-list
		collect (format nil "{~{~{\"~A\"~^:~}~^, ~}}"
				(mapcar #'list label-list data)))))

(defun list-to-list (label-list data-list)
  "(list-to-json '(\"id\" \"label\") '((1 \"hogehoge\") (2 \"blahblah\")) => (((\"id\" 1) (\"label\" \"hogehoge\")) ...)"
  (loop for data in data-list
		collect (mapcar #'list label-list data)))

(defun partition (ls)
  (labels ((odd-part (ls xs ys)
             (if (null ls)
                 (values (nreverse xs) (nreverse ys))
		 (even-part (cdr ls) xs (cons (car ls) ys))))
           (even-part (ls xs ys)
             (if (null ls)
                 (values (nreverse xs) (nreverse ys))
		 (odd-part (cdr ls) (cons (car ls) xs) ys))))
    (even-part ls nil nil)))

(defun trim-labels (query-result-list)
  (multiple-value-bind (even-part-list odd-part-list) (partition query-result-list)
    (declare (ignore even-part-list))
    odd-part-list))

(defun shaping-node-json (raw-data)
  "return list: (knowledge_graph_id_in_graph(id) knowledge_content(label) node_type(group))"
  ;;(parse raw-data)
  (let* ((full (mapcar #'(lambda (d)
			   (string-trim "}" (string-trim "{" (string-trim "\"" (string-trim " " d)))))
		       (split-sequence:split-sequence #\, (subseq raw-data 1 (1- (length raw-data))))))
	 (triple-set-list
	   (list
	    (loop for x from 0
		  for y in full
		  when (= 0 (mod x 3))
		    collect y)
	    (loop for x from 0
		  for y in full
		  when (= 1 (mod x 3))
		    collect y)
	    (loop for x from 0
		  for y in full
		  when (= 2 (mod x 3))
		    collect y)))
	 (first-data
	   (loop for y in (first triple-set-list)
		 collect (subseq y 4 (1- (length y)))))
    	 (second-data (loop for y in (second triple-set-list)
    			    collect (subseq y 7 (1- (length y)))))
    	 (third-data (loop for y in (third triple-set-list)
    			   collect (subseq y 7 (1- (length y))))))
    (mapcar #'list first-data second-data third-data)))


(defun shaping-edge-json (raw-data trim-from-even trim-from-odd &optional trim-end)
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
			   collect (subseq y trim-from-odd (if trim-end (1- (length y)) (length y))))))
    (mapcar #'list even-data odd-data)))

(defun string-list-to-list (raw-data)
  (mapcar #'(lambda (d)
	      (string-trim "}" (string-trim "{" (string-trim "\"" (string-trim " " d)))))
	  (split-sequence:split-sequence #\, (subseq raw-data 1 (1- (length raw-data))))))
