(in-package :mlsspbc.resources)

#|
助言生成モジュール
|#

(defun inference-output (slide-path lesson-id)
  (declare (ignorable slide-path lesson-id))
  (format nil "~A" (apply-advice (get-slide-id-from-path slide-path) lesson-id)));;"あなたはこのスライドから，「<b>オントロジー</b>」について「<b>プロトコルの一種</b>」や「<b>プロトコルとしての使用例</b>」といった，<i>スライドに明示的に記されていることはよく理解できている</i>ようです．しかし，<i>目に見えている以上のことは十分に理解できていない</i>かもしれません．「<b><i>プロトコルとしてのオントロジーの必要性</i></b>」の観点から当スライドを読み解くことはできますか")); slide-path))

#|
いつか，下で定義している関数群を，ここから定義しているCLOSに置き換えて賢く推論させる
|#

#|
領域知識関係のクラス
|#
(defclass knowledge-relation ()
  ((relation-id :initarg :relation-id :initform nil :accessor id)
   (relation-type :initarg :relation-type :initform nil :accessor relation-type)))

(defclass domain-knowledge ()
  ((knowledge-id :initarg :knowledge-id :initform nil :reader id)
   (knowledge-content :initarg :content :initform "" :accessor content)
   (related-knowledge :initarg :related-knowledge :initform nil :accessor :related-knowledge)))

#|
ピラミッド型構造に関するクラス
|#
(defclass concept-relation ()
  ((relation-id :initarg :relation-id :initform nil :accessor id)
   (parent-node-id :initarg :parent-node-id :accessor parent-id)
   (child-node-id :initarg :child-node-id :accessor child-node)))

(defclass conceptual-node ()
  ((node-id :initarg :node-id :accessor node-id)
   (content-type :initarg :content-typedbym482)
   (target-knowledge :initarg :target-knowledge :initform nil :accessor :target-knowledge)))

(defclass conceptual-slide (conceptual-node)
  ((content-type :initarg :slide-node)
   (slide-path :initarg :slide-path :initform "" :accessor slide-path)
   (slide-title :initarg :title :initform "No title" :accessor title)
   (implicit-knowledge :initarg :implicit :initform nil :accessor implicit)
   (explicit-knowledge :initarg :explicit :initform nil :accessor explicit)))
   
#|
クラス情報を操作・利用するための関数群
|#
(defun a ()
  )

#|###################################
ここまで
|#


#|
データベースからクラス作成の際に使用する関数群
|#
(defun get-slide-id-from-path (slide-path)
  (cadar (select "id" "goal_vocabrary" (format nil "vocabrary=\"~A\"" slide-path))))

(defun get-s-path-from-id (slide-id)
  (cadar (select "vocabrary" "goal_vocabrary" (format nil "id=\"~A\"" slide-id))))

(defun get-parent-node-ids-from-slide-id (slide-id lesson-id)
  (append
   (mapcar #'second (select "parent_node_id" "other_relations" (format nil "child_node_id='~A' and lesson_id='~A'" slide-id lesson-id)))
   (mapcar #'cadr (select "parent_term_id" "user_concepts"
			  (format nil "concept_term_id = \"~A\" and lesson_id = \"~A\"" slide-id lesson-id)))))

(defun get-slide-tree (slide-id lesson-id)
  (get-parent-node-ids-from-slide-id slide-id lesson-id))
    
      
  
(defun get-parent-node-ids-from-node-id (node-id lesson-id)
  (append
   (mapcar #'second (select "parent_node_id" "other_relations" (format nil "child_node_id='~A' and lesson_id='~A'" node-id lesson-id)))
   (mapcar #'cadr (select "parent_term_id" "user_concepts"
			  (format nil "node_id = \"~A\" and lesson_id = \"~A\"" node-id lesson-id)))))

(defun root-node-p (node-id lesson-id)
  )

(defun leaf-node-p (node-id lesson-id)
  )

(defun get-child-node-ids (current-node-id)
  )

(defun get-content-from-id (node-id)
  )

(defun get-attached-node-ids (slide-id)
  )

(defun get-forward-slide-ids (node-id)
  )



#|
ノードの属性情報を取得
|#
(defun get-slide-kma-attribute (slide-id)
  (let ((kma-result (cadar (select "kma_result" "user_slide" (format nil "slide_id = ~A" slide-id)))))
    kma-result))

(defun get-slide-errata (slide-id)
  (let ((slide-path (get-s-path-from-id slide-id)))
    (cadar (select "slide_errata" "domain_slide" (format nil "slide_path = \"~A\"" slide-path)))))


(defun get-slide-implicit-knowledge (slide-id)
  (let* ((slide-path (get-s-path-from-id slide-id))
	 (slide-implicit-knowledge
	   (cadar (select "implicit_knowledge" "domain_slide" (format nil "slide_path = \"~A\"" slide-path))))
	 (result (mapcar #'(lambda (d)
			     (string-trim "\"" (string-trim " " d)))
			 (split-sequence:split-sequence #\, (subseq slide-implicit-knowledge 1 (1- (length slide-implicit-knowledge)))))))
    (unless (equal result '(""))
      result)))

(defun get-slide-explicit-knowledge (slide-id)
  (let* ((slide-path (get-s-path-from-id slide-id))
	 (slide-explicit-knowledge
	   (cadar (select "explicit_knowledge" "domain_slide" (format nil "slide_path = \"~A\"" slide-path))))
	 (result (mapcar #'(lambda (d)
			     (string-trim "\"" (string-trim " " d)))
			 (split-sequence:split-sequence #\, (subseq slide-explicit-knowledge 1 (1- (length slide-explicit-knowledge)))))))
    (unless (equal result '(""))
      result)))


(defun get-node-knowledge (node-id)
  (cadar (select "explicit_knowledge, implicit_knowledge" "goal_vocabrary" (format nil "id = \"~A\"" node-id))))


#|
学習者のKMAの正しさ判定
|#

(defun judge-kma (slide-id)
  (let ((learner-kma (get-slide-kma-attribute slide-id))
	(teacher-kma (get-slide-errata slide-id)))
    (labels ((kma-check (t-kma l-kma)
	       (and (string= teacher-kma t-kma) (string= learner-kma l-kma))))
      (cond ((kma-check "ok" "ok")
	     "正しいスライドを正しく理解")
	    ((kma-check "ok" "ng")
	     "正しいスライドを間違って理解")
	    (t "www")))))

(defun judge-knowledge (slide-id lesson-id)
  (let* ((learner-knowledge

	   (mapcar #'(lambda (true-k-str)
		       
		       ;; (mapcar #'(lambda (d) 
		       ;; 		   (string-trim "\"" d))
		       ;;(split-sequence:split-sequence #\, 
		       ;; (string-trim "{" (string-trim "}"

#|


(format nil "~A" (mapcar #'(lambda (d)
		     (string-trim "{" (string-trim "}" (string-trim "\"" d))))
		 (alexandria:flatten
		  (mapcar #'(lambda (d)
			      (split-sequence:split-sequence #\, d))
			  (mlsspbc.resources::judge-knowledge 3 1)))))

|#



		       
											    true-k-str);)
					;)
		   (remove-if #'(lambda (k-str)
				  (string= k-str "{}"))
			      (mapcar #'(lambda (d)
					  (get-node-knowledge d))
				      (get-parent-node-ids-from-slide-id slide-id lesson-id)))))
			    ;; 学習者が説明しようとしている知識：これをどこまで見るかどうかは議論の余地有り
	 (teacher-implicit-knowledge (get-slide-implicit-knowledge slide-id))
	 (teacher-explicit-knowledge (get-slide-explicit-knowledge slide-id))
	 (teacher-knowledge (append teacher-implicit-knowledge teacher-explicit-knowledge))
	 (diff (append (set-difference learner-knowledge teacher-knowledge :test #'string=)
		       (set-difference teacher-knowledge learner-knowledge :test #'string=))))
    learner-knowledge
    ;; (mapcar #'(lambda (d)
    ;; 		(cond ((find d teacher-implicit-knowledge :test #'string=)
    ;; 		       `(,d "implicit-miss"))
    ;; 		      ((find d teacher-explicit-knowledge :test #'string=)
    ;; 		       `(,d "explicit-miss"))
    ;; 		      ((find d learner-knowledge :test #'string=)
    ;; 		       `(,d "non-exist-appear"))))
    ;; 	    diff)
    ))


#|
書くスライドに対するポートフォリオ
|#
(defun slide-portfolio (slide-id lesson-id)
  (let ((slide-path (get-s-path-from-id slide-id))
	(kma-correctness (judge-kma slide-id))
	(knowledge-coverage (judge-knowledge slide-id lesson-id)))
    (format nil "slide id: ~A~%slide path: ~A~%KMA: ~A~%knowledge: ~A~%"
	    slide-id slide-path kma-correctness knowledge-coverage)))


#|
助言適用
|#
(defun apply-advice (slide-id lesson-id)
  (let ((kma-correctness (judge-kma slide-id))
	(knowledge-coverage (judge-knowledge slide-id lesson-id)))
    (cond ((and
	    (string= kma-correctness "正しいスライドを正しく理解")
	    (null knowledge-coverage))
	   (format nil "よく理解し，説明しようとすることができています．~%この調子で積極的に行間を読み取りましょう"))
	  ((and
	    (string= kma-correctness "正しいスライドを正しく理解")
	    (null knowledge-coverage))
	   (format nil "よく理解し，説明しようとすることができています．~%この調子で積極的に行間を読み取りましょう"))
	  ((and
	    (string= kma-correctness "正しいスライドを正しく理解")
	    (null knowledge-coverage))
	   (format nil "よく理解し，説明しようとすることができています．~%この調子で積極的に行間を読み取りましょう"))
	  ((and
	    (string= kma-correctness "正しいスライドを正しく理解")
	    (null knowledge-coverage))
	   (format nil "よく理解し，説明しようとすることができています．~%この調子で積極的に行間を読み取りましょう"))
	  (t (format nil "~A" knowledge-coverage)))))
	  
  
