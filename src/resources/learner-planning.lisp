(in-package :mlsspbc.resources)

(defpage learner-planning ()
  `(:br)
  `(:div :id "container"
	 (:div :id "m-window" :class "split split-horizontal"
	       (:div :id "b-window" :class ""
		     (:div :id "orgChartContainer" ;;インテンションマップ構築スペース
			   (:div :id "orgChart")))
	       (:div :class "gutter gutter-horizontal" :style "width:8px;hight:100%")
	       (:div :id "c-window" :class "" ;; コンテンツパーツを置いているウィンドウ
		     (:div :id "print-pointer-position"
			   (:p "X: " (:span :id "pointer-position-x") "px, Y: " (:span :id "pointer-position-y") "px"))
		     ;; (:img :id "trashbox" :src "/static/image/menu/trashbox.png")
		     (:div :class "clear-float")
		     ;; スライドとインテンションマップの切り替えタブ
		     (:ul :class "nav nav-tabs" :id "tabs"
			  (:li :class "active"
			       (:a :href "#intensions" :data-toggle "tab" "Terms of Learning Goal"))
			  (:li :class ""
			       (:a :href "#slides" :data-toggle "tab" "Slides")))
		     ;; スライドとインテンションパーツのコンポーネント
		     (:div :id "myTabContent" :class "tab-content"
			   (:div :class "tab-pane fade in active" :id "intensions"
				 :ondragover "f_dragover(event)"
				 :ondrop "f_drop(event)"
				 (:br)
				 (:script
				  "let html = intentList();document.write(html);"))
			   (:div :class "tab-pane fade" :id "slides"
				 (:div :id "nestable"
				       ,(slides-planning (get-parameter "lesson-id"))))
			   (:div :style "clear:both;"))))
	 (:button :id "finish-declare-btn" "Finish to Presentation Design Task") ;;終了宣言ボタン
	 (:button :type "button" :onclick "saveDatas();" "SAVE") ;;コンセプトマップのセーブボタン => 一段落したら，intro-js/portfolio.jsないに，確認後セーブ処理として移す（このボタンは消して，終了宣言ボタンと同期させる
	 ;;各コンセプトをクリックしたときの詳細をモーダルとして表示
	 (:div :id "modal-content-div"
	       (:div :class "modal-header"
		     (:button :id "modal-close-btn1" :type "button" :class "close" "&times;")
		     (:h4 :id "modal-title" :class "modal-title" "Knowledge installation"))
	       (:div :class "modal-body"
		     (:h1 :id "super-class")
		     (:br)
		     (:div :id "modal-inner-content"
			   (:h1 :id "modalSelectedNode")
			   (:div :id "knowledge-structure")
			   (:br)
			   (:form :id "k-submit-form"
				  (:input :id "lesson-id-in-modal" :type "hidden" :value ,(get-parameter "lesson-id"))
				  (:input :id "lesson-id-in-modal" :type "hidden" :value ,(get-parameter "lesson-id")))))
	       (:div :class "modal-footer"
		     (:button :type "button" :id "modal-close-btn2" :class "btn btn-default" "close")
		     (:button :type "button" :class "btn btn-primary" :data-dismiss "modal" :id "k-save-btn" "save")))
	 (:br)
	 (:br)
	 (:script :type "text/javascript" :src ,(js-path "cytoscape/save-knowledge.js"))
	 (:script :type "text/javascript" :src ,(js-path "window-setting/redirect.js"))
	 (:script :type "text/javascript" :src ,(js-path "split-js/setting.js"))
	 (:script :type "text/javascript" :src ,(js-path "sigma/advanced-setting.js"))))

(defun slides-planning (lesson-id)
  (let* ((code nil)
	 (result-code-list nil)
	 (domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id=\"~A\"" lesson-id))))
	 (slide-pathname (mapcar #'cadr (select "slide_path" "domain_slide" (format nil "domain_id=\"~A\"" domain-id)))))
    (loop for x in slide-pathname
	  do (push `(:img :id ,x :class "slide-image intension-items" :ondragstart "f_dragstart(event)" :src ,x) code))
    (setf result-code-list (reverse code))
    (push "slide-rows" result-code-list)
    (push :id result-code-list)
    (push :div result-code-list)
    result-code-list))
