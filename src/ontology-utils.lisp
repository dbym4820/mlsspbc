(in-package :cl-user)

(defpackage :loapeat.ontology-operator
  (:use :cl :cl-user)
  (:import-from :loapeat.config
		:config)
  (:import-from :cxml
		:parse-file)
  (:import-from :cl-annot
                :enable-annot-syntax)
  (:import-from :cxml-xmls
		:make-xmls-builder))
(defpackage :loapeat.instance
  (:use :cl :cl-user))

(in-package :loapeat.ontology-operator)
(enable-annot-syntax)

(defparameter *ontology-file* (format nil "~A~A" (config :document-root) "ontology/anime-ontology.xml"))

(defun xml-source ()
  (let ((source (with-open-file (in *ontology-file* :direction :input)
		  (do ((line (read-line in nil nil) (read-line in nil nil))
		       (lines nil (push line lines)))
		      ((null line) (format nil "~{~A~^~%~}" (nreverse lines)))))))
    source))

(defparameter *xml-source* (xml-source))

(defun xml-to-list ()
  (parse-file *ontology-file* (make-xmls-builder)))

(defun delete-newline (origin-tree)
  (labels ((replacer (tree &optional (acc nil))
	     (cond
	       ((null tree)
		(nreverse acc))
	       ((stringp tree)
		(if (string= #\LineFeed tree)
		    acc
		    (cons (car tree) acc)))
	       ((listp (car tree))
		(replacer (cdr tree) (cons (replacer (car tree) nil) acc)))
	       (t
		(replacer (cdr tree)
			  (if (string= #\LineFeed (car tree))
			      acc
			      (cons (car tree) acc)))))))
    (replacer origin-tree)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 法造の解析    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
(defun conv ()  
  (delete-newline (xml-to-list)))

(defun w-concept ()
  (let* ((origin-tree (conv))
	 (len (length origin-tree)))
    (loop for count from 0 below len
	  when (listp (nth count origin-tree))
	    do (if (stringp (car (nth count origin-tree)))
		   (if (string= "W_CONCEPTS" (car (nth count origin-tree)))
		       (return (nth count origin-tree)))))))

(defun concepts ()
  (let* ((w-concepts (w-concept))
	 (len (length w-concepts))
	 (concept-list nil))
    (loop for count from 0 below len
	  when (and (listp (nth count w-concepts)) (string= (car (nth count w-concepts)) "CONCEPT"))
	    do (setf concept-list (append concept-list (list (nth count w-concepts)))))
    concept-list))
    
(defun search-concept (concept-name)
  (let* ((concept-list (concepts))
	 (len (length concept-list)))
    (loop for count from 0 below len
	  do (let ((concept-name-in-list (nth 2 (nth 2 (nth count concept-list)))))
	       (if (string= concept-name concept-name-in-list)
		   (return (nth count concept-list)))))))


(defun concept-name-list ()
  (let* ((concept-list (concepts))
	 (len (length concept-list))
	 (c-list nil))
    (loop for count from 0 below len
	  do (let ((concept-name-in-list (nth 2 (nth 2 (nth count concept-list)))))
	       (setf c-list (append c-list (list concept-name-in-list)))))
    c-list))


(defun get-concept-position (class-name)
  (let* ((concept (search-concept class-name))
	 (len (length concept)))
    (loop for count from 0 below len
	  do (let ((arg (nth count concept)))
	       (when (and (listp arg) (string= "POS" (car arg)))
		 (return (list (parse-integer (cadr (cadadr arg))) (parse-integer (car (cdaadr arg))))))))))
		   

(defun class-relations ()
  (let* ((concept (w-concept))
	 (len (length concept))
	 (relation-list nil))
    (loop for count from 0 below len
	  do (let ((concept-tree (nth count concept)))
	       (when (and (listp concept-tree) (stringp (car concept-tree)))
		 (when (string= "ISA" (car concept-tree))
		   (setf relation-list (append relation-list (list (second concept-tree))))))))
    relation-list))

(defun parent (class-name)
  (let* ((relations (class-relations))
	 (len (length relations)))
    (loop for count from 0 below len
	  when (string= class-name (second (car (nth count relations))))
	    do (return (second (cadr (nth count relations)))))))

(defun childs (class-name)
  (let* ((relations (class-relations))
	 (len (length relations))
	 (child-list nil))
    (loop for count from 0 below len
	  do (let* ((rel (nth count relations))
		    (parent-name (second (cadr rel))))
	       (when (string= class-name parent-name)
		 (setf child-list (append child-list (list (second (car rel))))))))
    child-list))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; クラスの定義    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;起動時に個々で検索して出て来る名前やサブクラスなんかを，CLOSに落とし込む
(defclass ontology ()
  ((class-name :initarg :class-name :accessor :class-name)
   (super-class :initform nil :initarg :super-class :accessor :super-class)
   (childs :initform nil :initarg :childs :accessor :childs)
   (id :initarg :id :reader :id)
   (pos-x :initarg :position-x :reader :pos-x)
   (pos-y :initarg :position-y :reader :pos-y)
   (other :initarg :other :accessor :other)))


(defmacro convert-ontology ()
  (let* ((concept-list (concept-name-list))
	 (len (length concept-list)))
    (defparameter *ontology-list* nil)
    (loop for count from 0 below len
	  do (let* ((concept-name (nth count concept-list))
		    (interned-symbol (intern (string-upcase concept-name) :loapeat.ontology-operator))
		    (instance-symbol (intern (string-upcase concept-name) :loapeat.instance))
		    (concept-list (search-concept concept-name)))
	       (setf *ontology-list* (append *ontology-list* (list
					     (eval `(defparameter ,instance-symbol
						      (make-instance (quote ontology)
								     :class-name (quote ,interned-symbol)
								     :super-class (quote
										   ,(when (parent concept-name)
										      (intern (string-upcase (parent concept-name)) :loapeat.ontology-operator)))
								     :childs (quote ,(childs concept-name))
								     :id 2
								     :position-x 100
								     :position-y 200
								     :other (quote ,concept-list)))))))))))

(defun instance-detail (instance-name)
  (let ((instance-symbol (intern (string-upcase instance-name) :loapeat.instance)))
    (format t "CLASS-NAME: ~A~%" (eval `(slot-value ,instance-symbol 'class-name)))
    (format t "SUPER-CLASS: ~A~%" (eval `(slot-value ,instance-symbol 'super-class)))
    (format t "CHILDS-CLASS: ~A~%" (eval `(slot-value ,instance-symbol 'childs)))
    (format t "ID: ~A~%" (eval `(slot-value ,instance-symbol 'id)))
    (format t "POSITION-X: ~A~%" (eval `(slot-value ,instance-symbol 'pos-x)))
    (format t "POSITION-Y: ~A~%" (eval `(slot-value ,instance-symbol 'pos-y)))
    (format t "CONCEPT-LIST: ~A~%" (eval `(slot-value ,instance-symbol 'other)))))


(defmacro ontology-slot (instance-name slot-name)
  (let ((instance-symbol
	  (intern (string-upcase
		   (eval (if (symbolp instance-name) (symbol-name instance-name) instance-name)))
		  :loapeat.instance))
        (slot-symbol
	  (intern (string-upcase
		   (eval (if (symbolp slot-name) (symbol-name slot-name) slot-name)))
		  :loapeat)))
    `(slot-value ,instance-symbol (quote ,slot-symbol))))



(defun assumption ())
  
