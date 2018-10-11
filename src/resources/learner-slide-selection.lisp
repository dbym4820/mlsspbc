(in-package :loapeat.resources)

(defpage learner-slide-selection ()
  `(:div :id "container"
	 (:h1 "プレゼンに用いようと思うスライドにチェックを付けてください")
	 ;;(:p "※今回選択していないスライドであっても，後のフェーズで選択することは可能です")
	 ,(slides-plan (get-parameter "lesson-id"))))


(defun slides-plan (lesson-id)
  (let* ((code nil)
	 (result-code-list nil)
	 (domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id=\"~A\"" lesson-id))))
	 (slide-pathname (mapcar #'cadr (select "slide_path" "domain_slide" (format nil "domain_id=\"~A\"" domain-id)))))
    (loop for x in slide-pathname
	  do (push `(:a :href ,x :class "" :data-lightbox "slide" :rel "lightbox"
			(:img :id ,x :class "slide-image intension-items" :ondragstart "f_dragstart(event)" :src ,x)) code))
    (setf result-code-list (reverse code))
    (push "slide-sel" result-code-list)
    (push :id result-code-list)
    (push :div result-code-list)
    result-code-list))
