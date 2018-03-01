(in-package :mlsspbc.resources)

(defun inference-output (slide-path)
  (declare (ignorable slide-path))
  (format nil "あなたはこのスライドから，「<b>オントロジー</b>」について「<b>プロトコルの一種</b>」や「<b>プロトコルとしての使用例</b>」といった，<i>スライドに明示的に記されていることはよく理解できている</i>ようです．しかし，<i>目に見えている以上のことは十分に理解できていない</i>かもしれません．「<b><i>プロトコルとしてのオントロジーの必要性</i></b>」の観点から当スライドを読み解くことはできますか")); slide-path))

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

#|
データベースからクラス作成の際に使用する関数群
|#
(defun get-slide-id-from-path (slide-path)
  (cadar (select "id" "domain_slide" (format nil "slide_path=\"~A\"" slide-path))))

(defun get-parent-node-ids-from-slide-id (slide-id lesson-id)
  (mapcar #'cadr (select "parent_term_id" "user_concepts"
			(format nil "concept_term_id = \"~A\" and lesson_id = \"~A\"" slide-id lesson-id))))

(defun get-parent-node-ids-from-node-id (node-id lesson-id)
  (mapcar #'cadr (select "parent_term_id" "user_concepts"
			 (format nil "node_id = \"~A\" and lesson_id = \"~A\"" node-id lesson-id))))

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
