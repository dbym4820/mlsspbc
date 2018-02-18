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
				       ,(slides-planning)))
			   (:div :style "clear:both;"))))
	 (:button :class "finish-declare-btn" "Finish to Presentation Design Task") ;;終了宣言ボタン
	 (:button :type "button" :onclick "saveDatas();" "SAVE") ;;コンセプトマップのセーブボタン

	 ;;各コンセプトをクリックしたとき2の詳細をモーダルとして表示
	 (:div :id "modal-content-div"
	       (:div :class "modal-header"
		     (:button :id "modal-close-btn1" :type "button" :class "close" "&times;")
		     (:h4 :id "modal-title" :class "modal-title" "添削"))
	       (:div :class "modal-body"
		     (:h1 :id "super-class")
		     (:br)
		     (:div :id "modal-inner-content"
			   (:h1 :id "modalSelectedNode")
			   (:h2 "添削箇所")
			   (:select
			    (:option "内容") (:option "親ノード") (:option "子ノード"))
			   (:br)
			   (:h2 "添削内容")
			   (:textarea :rows "10" :cols "100")
			   (:br)
			   (:h2 "添削理由")
			   (:textarea :rows "10" :cols "100")
			   (:br)))
	       (:div :class "modal-footer"
		     (:button :type "button" :id "modal-close-btn2" :class "btn btn-default" "閉じる")
		     (:button :type "button" :class "btn btn-primary" :data-dismiss "modal" :id "modal-save" "保存")))
	 (:br)
         (:div :id "knowledge-structure")
	 (:br)
	 (:script :type "text/javascript" :src ,(js-path "window-setting/redirect.js"))
	 (:script :type "text/javascript" :src ,(js-path "split-js/setting.js"))
	 (:script :type "text/javascript" :src ,(js-path "sigma/advanced-setting.js"))))

(defun slide-source ()  
  (let* ((source (with-open-file (in (format nil "~Aslide/keynote/test/index.html" (config :static-path))
				     :direction :input)
		   (do ((line (read-line in nil nil) (read-line in nil nil))
			(lines nil (push line lines)))
		       ((null line) (format nil "~{~A~^~%~}" (nreverse lines)))))))
    (replace-all-string (replace-all-string (replace-all-string source "<" "&lt;") ">" "&gt;") "\"" "&quot;")))


(defun get-slide-pathname ()
  (let* ((base-pathname (format nil "~Aslide/keynote/test/assets/" (config :static-path)))
	 (names (remove-duplicates
		 (mapcar #'(lambda (lst)
			     (if
			      (not (or
				    (string= lst (format nil "~Aglobal/" base-pathname))
				    (string= lst (format nil "~Aplayer/" base-pathname))))
			      lst))
			 (mapcar #'namestring
				 (subdirectories (format nil "~Aslide/keynote/test/assets/" (config :static-path))))))))
    (loop for lst in names
	  when (not (null lst))
	    collect (format nil "/~Athumbnail.jpeg" (subseq lst (length (config :document-path)))
			    ))))


(defun slides-planning ()
  (let ((code nil))
    (loop for x in (get-slide-pathname)
	  do (push `(:img :id ,(append-root-url x) :class "slide-image intension-items" :ondragstart "f_dragstart(event)" :src ,(append-root-url x)) code))
    (push "slide-rows" code)
    (push :id code)
    (push :div code)))
