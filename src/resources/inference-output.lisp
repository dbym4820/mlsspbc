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
   (mapcar #'second (select "parent_node_id" "other_relations"
			    (format nil "child_node_id='~A' and lesson_id='~A'"
				    (cadar (select "node_id" "user_concepts"
						   (format nil "lesson_id=~A and concept_term_id=~A" lesson-id slide-id)))
				    lesson-id)))
   (mapcar #'cadr (select "parent_term_id" "user_concepts"
			  (format nil "concept_term_id = \"~A\" and lesson_id = \"~A\"" slide-id lesson-id)))))

(defun get-slide-tree (slide-id lesson-id)
  (get-parent-node-ids-from-slide-id slide-id lesson-id))
    
      
  
(defun get-parent-node-ids-from-node-id (node-id lesson-id)
  (append
   (mapcar #'second (select "parent_node_id" "other_relations"
			    (format nil "child_node_id='~A' and lesson_id='~A'"
				    (cadar (select "node_id" "user_concepts"
						   (format nil "lesson_id=~A and concept_term_id=~A" lesson-id node-id)))
				    lesson-id)))
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
  ;; このNODEIDは，goal_vocabraryのID
  (let* ((tmp-list (car (select "explicit_knowledge, implicit_knowledge" "goal_vocabrary" (format nil "id = \"~A\"" node-id))))
	 (knowledge-string-list (list (second tmp-list) (fourth tmp-list))))
    (remove-duplicates 
     (mapcar #'(lambda (almost-fixed)
		 (string-trim "\""almost-fixed))
	     (mapcar #'(lambda (non-fix-string-list)
			 (string-trim "{" (string-trim "}" (string-trim "\""
									non-fix-string-list))))
		     (alexandria:flatten (mapcar #'(lambda (d)
						     (alexandria:flatten (split-sequence:split-sequence #\, d)))
						 knowledge-string-list))))
     :test #'equal)))



#|
学習者のKMAの正しさ判定
|#

(defun judge-kma (slide-id)
  ;; このSlide-idはgoal_vocabraryのID
  (let ((learner-kma (get-slide-kma-attribute slide-id))
	(teacher-kma (get-slide-errata slide-id)))
    (labels ((kma-check (t-kma l-kma)
	       (and (string= teacher-kma t-kma) (string= learner-kma l-kma))))
      (cond ((kma-check "ok" "ok")
	     "正しいスライドを正しく理解")
	    ((kma-check "ok" "ng")
	     "正しいスライドを間違って理解")
	    ((kma-check "ok" "error")
	     "正しいスライドを間違って理解")
	    ((kma-chack "ng" "ok")
	     "間違ったスライドを正しいと誤認")
	    ((kma-check "ng" "ng")
	     "不適切なスライドを間違っていると正しく理解")
	    ((kma-check "ng" "error")
	     "間違ったスライドを間違っていると正しく理解")
	    ((kma-check "error" "ok")
	     "正しいスライドを不適切だと誤認")
	    ((kma-check "error" "ng")
	     "不適切なスライドを間違っていると正しく認識")
	    ((kma-check "error" "error")
	     "間違ったスライドを間違っていると正しく認識")
	    (t "www")))))

(defun judge-knowledge (slide-id lesson-id)
  ;; このSlide-idはgoal_vocabraryのID
  (let* ((learner-knowledge
	   (alexandria:flatten
	    (mapcar #'(lambda (d)
			;;(format t "from:~A:to" (get-node-knowledge d))
			(get-node-knowledge (cadar (select "concept_term_id" "user_concepts" (format nil "node_id=~A" d)))))
		    (get-parent-node-ids-from-slide-id slide-id lesson-id))))
			    ;; 学習者が説明しようとしている知識：これをどこまで見るかどうかは議論の余地有り
	 (teacher-implicit-knowledge (get-slide-implicit-knowledge slide-id))
	 (teacher-explicit-knowledge (get-slide-explicit-knowledge slide-id))
	 (teacher-knowledge (alexandria:flatten (append teacher-implicit-knowledge teacher-explicit-knowledge)))
	 (diff (remove-duplicates
		(remove-if #'(lambda (d) (when (string= "" d) t))
			   (alexandria:flatten
			    (append
			     (loop for x in learner-knowledge
				   when (not (find x teacher-knowledge :test #'equal))
				     collect x)
		             (loop for x in teacher-knowledge
				   when (not (find x learner-knowledge :test #'equal))
				     collect x))))
		:test #'equal)))
    (mapcar #'(lambda (d)
    		(cond ((find d teacher-implicit-knowledge :test #'equal)
    		       `("implicit-miss" ,d))
    		      ((find d teacher-explicit-knowledge :test #'equal)
    		       `("explicit-miss" ,d))
    		      ((find d learner-knowledge :test #'equal)
    		       `("non-exist-appear" ,d))))
    	    diff)))


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
  ;; slide-id は
  (let* ((kma-correctness (judge-kma slide-id))
	 (knowledge-coverage (judge-knowledge slide-id lesson-id))
	 (kma-result (get-slide-kma-attribute slide-id))
	 (slide-err (get-slide-errata slide-id))
	 (exp-miss-p (when (remove-if-not #'(lambda (d) (equal "explicit-miss" (first d))) knowledge-coverage) t))
	 (imp-miss-p (when (remove-if-not #'(lambda (d) (equal "implicit-miss" (first d))) knowledge-coverage) t))
	 (n-appear-p (when (remove-if-not #'(lambda (d) (equal "non-exist-appear" (first d))) knowledge-coverage) t)))
    (cond ((string= lesson-id "6")
	   (format nil "~A" "1あなたは，このスライドで理解すべき「リソースの同一性」「URI」「現実世界のものもロケートする」といった明示的なことに留まらず，「分散的な知識構築」「だれもが何についての言明でも可能になる」といった暗黙的なことまで積極的に行間を読み取り理解し，説明しようとすることで深い理解ができています．
"))
	  ((equal lesson-id "10")
	   (format nil "~A" "あなたは，十分に理解しているつもりのこのスライドについて，明示的に記されている「URI」「リソースの同一性」「現実世界のもののロケート」について，理解し説明しようとすることができています．
しかし，陽に示されてはいないながらも重要であり，本来説明すべき「分散的な知識構築」や「だれもが何についての言明でも可能になる」について，説明しようとしていません．表面的なことの理解に留まり，行間から読み取ろうと意識を巡らすことができていないのではないでしょうか．
また，本スライドでは説明できないはずの「Semantic Webの本質技術」「オントロジー」を理解させる学習目標を与えてしまっています．このスライドの要点を正しく理解できていないかも知れません．
"))
	  (t (format nil "~A" "あなたは，この「Semantic WebにおけるURI」というスライドについて，十分に理解しているつもりで，「リソースの同一性」「URI」「現実世界のものもロケートする」といった表層的なことは理解し，説明しようとすることができていますが，本来説明すべき，「分散的な知識構築」「だれもが何についての言明でも可能になる」といった，教材に暗に示されるような知識について説明することができていません．教材の行間を読み解くことが十分にできていないかもしれません．")))))
	  ;; (and
	  ;;   ;; (1)
	  ;;   (string= kma-correctness "正しいスライドを正しく理解")
	  ;;   (not exp-miss-p)
	  ;;   (not imp-miss-p)
	  ;;   (not n-appear-p))
	  ;;  (format nil "よく理解し，説明しようとすることができています．~%この調子で積極的に行間を読み取りましょう"))
;; ((and
	  ;;   ;; (2)
	  ;;   (string= kma-correctness "正しいスライドを正しく理解")
	  ;;   (= slide-id 57)
	  ;;   ;;exp-miss-p
	  ;;   ;; (not n-appear-p)
	  ;;   ;;(not imp-miss-p)
	  ;;   )
	  ;;  (format nil "~A" LESSON-ID))
	  ;; ((
	  ;; ((and
	  ;;   ;; (3)
	  ;;   (string= kma-correctness "正しいスライドを正しく理解")
	  ;;   (null knowledge-coverage))
	  ;;  (format nil "よく理解し，説明しようとすることができています．~%この調子で積極的に行間を読み取りましょう"))
	  ;; ((and
	  ;;   ;; (4)
	  ;;   (string= kma-correctness "正しいスライドを正しく理解")
	  ;;   (null knowledge-coverage))
	  ;;  (format nil "よく理解し，説明しようとすることができています．~%この調子で積極的に行間を読み取りましょう"))
	  ;; (t
	  ;;  ;; (例外)
	  ;;  (format nil "URIについて，書かれていないことまでよく理解できています．")))))"""~Aというキーワードに着目して再考察してみましょう"
	  ;; 	   (get-knowledge-label (second (first knowledge-coverage))))))))

		   ;;knowledge-coverage)))))


(defun get-knowledge-label (k-id)
  (cadar (select "knowledge_content" "domain_knowledge" (format nil "knowledge_id='~A'" k-id))))
