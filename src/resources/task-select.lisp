(in-package :loapeat.resources)

(defpage domain-select ()
  `(:div :style "overflow: scroll;"
	 (:div :style "text-align:center;margin-right:auto;margin-left:auto;text-align:center;"
	       (:h1 :style "text-decoration:underline;font-size:4em;width:700px;margin-right:auto;margin-left:auto;"
		    ,(format nil "学習ドメイン：~A" (get-domain-name-from-id-for-select (get-parameter "lesson-id")))))
	 (:div :class "honeycombs" :style "overflow: scroll;"
	       ,(cond ((string= "teacher" (session-value 'user-role))
		       `(:div
			  (:a :class "comb" :href ,(append-root-url (format nil "/authering/authering-slide?lesson-id=~A" (get-parameter "lesson-id"))) :style "float:left;"
			      (:div :class "front-content"
				    (:p "スライドを<br />アップロードする"))
			      (:div :class "back-content"
				    (:p "スライドを<br />アップロードする")))
			  (:a :class "comb" :href ,(append-root-url (format nil "/authering/authering-slide-check?lesson-id=~A&kma=0" (get-parameter "lesson-id"))) :style "float:left;"
			       (:div :class "front-content"
				     (:p "スライドに<br />正誤付与する"))
			       (:div :class "back-content"
				     (:p "スライドに<br />正誤付与する")))
			  (:a :class "comb" :href ,(append-root-url (format nil "/authering/authering-intension-map?lesson-id=~A" (get-parameter "lesson-id"))) :style "float:left;"
			      (:div :class "front-content"
				    (:p "正解のプレゼンを<br />設計する"))
			      (:div :class "back-content"
				    (:p "正解のプレゼンを<br />設計する")))
			  ;; (:a :class "comb" :href ,(append-root-url (format nil "/authering/authering-slide-check?lesson-id=~A&kma=0" (get-parameter "lesson-id"))) :style "float:left;"
			  ;;     (:div :class "front-content"
			  ;; 	    (:p "スライドを<br />確認する"))
			  ;;     (:div :class "back-content"
			  ;; 	    (:p "スライドを<br />確認する")))
			  ;; (:a :class "comb" :href ,(append-root-url (format nil "/authering/knowledge-operate?lesson-id=~A" (get-parameter "lesson-id"))) :style "float:left;"
			  ;;     (:div :class "front-content"
			  ;; 	    (:p "領域知識を<br />規定する"))
			  ;;     (:div :class "back-content"
			  ;; 	    (:p "領域知識を<br />規定する")))
			  ;; (:a :class "comb" :href ,(append-root-url (format nil "/index")) :style "float:left;"
			  ;;     (:div :class "front-content"
			  ;; 	    (:p "学習者を<br />課題に追加する"))
			  ;;     (:div :class "back-content"
			  ;; 	    (:p "学習者を<br />課題に追加する")))
			  ;; (:a :class "comb" :href "/authering/authering-target?lesson=1" :style "float:left;"
			  ;; 	   (:div :class "front-content"
			  ;; 		 (:p "学習目標語彙を設計する"))
			  ;; 	   (:div :class "back-content"
			  ;; 		 (:p "学習目標語彙を設計する")))
			  ))
		      ((or (string= "learner" (session-value 'user-role)) (string= "teacher" (session-value 'user-role)))
		       `(:div :style "clear:both;"
			 (:a :class "comb" :href ,(append-root-url (format nil "/learner/learner-kma?lesson-id=~A&kma=0" (get-parameter "lesson-id"))) :style "float:left;"
			     (:div :class "front-content"
				   (:p "理解を<br />表明する"))
			     (:div :class "back-content"
				   (:p "理解を<br />表明する")))
			 ,(when (string= "learner" (session-value 'user-role))
			    `(:a :class "comb" :href ,(append-root-url (format nil "/learner/learner-slide-selection?lesson-id=~A" (get-parameter "lesson-id"))) :style "float:left;"
				 (:div :class "front-content"
				       (:p "スライドを<br />選択する"))
				 (:div :class "back-content"
				       (:p "スライドを<br />選択する"))))
			 (:a :class "comb" :href ,(append-root-url (format nil "/learner/learner-planning?lesson-id=~A" (get-parameter "lesson-id")))  :style "float:left;"
			     (:div :class "front-content"
				   (:p "プレゼンを<br />設計する"))
			     (:div :class "back-content"
				   (:p "プレゼンを<br />設計する")))
#| 協調学習はまた今度			 
			 (:a :class "comb" :href ,(format nil "/learner/learner-collaborate?lesson=~A" (get-parameter "lesson-id")) :style "float:left;"
			     (:div :class "front-content"
				   (:p "協調学習課題する"))
			     (:div :class "back-content"
				   (:p "協調学習課題する")))))
|#
			 ))
		      (t (format nil "")))))
  `(:script
    "$(document).ready(function() {
        $('.honeycombs').honeycombs({
   	    combWidth:250,  // width of the hexagon
  	    margin: 0,		// spacing between hexagon
            threshold: 3
        });
     });"))

(defun get-domain-name-from-id-for-select (lesson-id)
  (cadar (select "domain_name" "educational_domain"
		 (format nil "domain_id = \"~A\""
			 (cadar (select "domain_id" "lessons" (format nil "lesson_id = \"~A\"" lesson-id)))))))
							    
