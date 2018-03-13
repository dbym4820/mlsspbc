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
  (format nil "id: ~A~%~A~%" (get-parameter "slide-id") (get-parameter "slide-path"))
  ;; (redirect-to-path
  ;;  (format nil "authering/knowledge-operate?lesson-id=~A" (get-parameter "lesson-id")))
  )

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
