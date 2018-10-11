(in-package :loapeat.resources)

(defpage authering-slide ()
  `(:form :action ,(append-root-url (format nil "/authering/upload-slide?lesson-id=~A" (get-parameter "lesson-id"))) :method "post" :enctype "multipart/form-data"
	  (:input :type "file" :name "input_file" :multiple "multiple")
	  (:input :type "submit" :value "send")))
   

(defun upload-slide ()
  (let* ((lesson-id (get-parameter "lesson-id"))
	 (current-time (now))
	 (year (timestamp-year current-time))
	 (month (timestamp-month current-time))
	 (day (timestamp-day current-time))
	 (hour (timestamp-hour current-time))
  	 (mini (timestamp-minute current-time))
  	 (sec (timestamp-second current-time))
	 (time-stamp (format nil "~A~2,,,'0@A~2,,,'0@A~2,,,'0@A~2,,,'0@A~2,,,'0@A" year month day hour mini sec)))
    (loop for file in (mapcar #'(lambda (f) (list (second f) (third f)))
    			      (hunchentoot:post-parameters hunchentoot:*request*))
    	  do (let ((f-name (format nil "static/slide/~A/~A.~A~A.png"
				   lesson-id (second file) time-stamp (random 10000000000))))
	       (cl-fad:copy-file
		(format nil "~A" (first file))
		(format nil (namestring (merge-pathnames f-name (config :document-root))))
		:overwrite t)
	       (add-slide-data (get-parameter "lesson-id") (append-root-url (format nil "/~A" f-name)))))
    (redirect-to-path (format nil "domain-select?lesson-id=~A" lesson-id))))

(defun add-slide-data (lesson-id slide-path)
  (let* ((current-time (now))
	 (year (timestamp-year current-time))
	 (month (timestamp-month current-time))
	 (day (timestamp-day current-time))
	 (hour (timestamp-hour current-time))
  	 (mini (timestamp-minute current-time))
  	 (sec (timestamp-second current-time))
	 (time-stamp (format nil "~A-~2,,,'0@A-~2,,,'0@A ~2,,,'0@A:~2,,,'0@A:~2,,,'0@A" year month day hour mini sec))
	 (user-id (cadar (select "user_id" "lessons" (format nil "lesson_id=\"~A\"" lesson-id))))
	 (new-slide-id (or (cadar (select "max(slide_id)+1" "domain_slide")) 1))
	 (new-vocabrary-id (or (cadar (select "max(id)+1" "goal_vocabrary")) 1))
	 (domain-id (cadar (select "domain_id" "lessons" (format nil "\"lesson_id\"=\"~A\"" lesson-id)))))
    ;;; スライドテーブルに突っ込む
    (send-query (format nil "insert into \"domain_slide\" (\"slide_id\", \"slide_path\", \"slide_title\", \"explicit_knowledge\", \"implicit_knowledge\", \"domain_id\", \"slide_errata\", \"uploaded_at\") values (\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\",\"~A\")"
			new-slide-id slide-path "" "{}" "{}" domain-id "" time-stamp))
    ;;; 目標語彙一覧に突っ込む
    (send-query (format nil "insert into goal_vocabrary(\"id\", \"vocabrary\", \"domain_id\", \"defined_by\", \"created_at\", \"edited_at\", \"type\", \"explicit_knowledge\", \"implicit_knowledge\") values (\"~A\", \"~A\", \"~A\", \"~A\", \"~A\", \"~A\", \"~A\", \"~A\", \"~A\")"
			new-vocabrary-id slide-path domain-id user-id time-stamp time-stamp "slide" "{}" "{}"))))



#|
スライドの確認と正誤情報の付加・削除を行う
|#
(defpage authering-slide-check ()
  `(:div :id "container"
	(:div :class "col-xs-8"
	      ,(let ((lesson-id (get-parameter "lesson-id"))
		     (kma (get-parameter "kma")))
		 `(:div
		   (:div :style "float:left"
			 ,(first (kma-authering-slide lesson-id kma)))
		   (:div :style "float:left; padding-left: 30px"
			 (:form :style "font-size: 2em" :action ,(append-root-url "/authering-kma-save") :method "get"
				(:input :type "hidden" :name "slide-id" :value ,(second (kma-authering-slide lesson-id kma)))
				(:input :type "hidden" :name "lesson-id" :value ,(format nil "~A" lesson-id))
				(:input :type "hidden" :name "kma" :value ,(format nil "~A" (1+ (parse-integer kma))))
				;;　KMAの宣言１
				(:label :style "font-size: 1.5em"
					(:input :type "radio" :name "kma-result" :value "ok" :checked "checked"
						:style "width:20px; height:20px"
						"正しく，選択することが望ましい"));;"I understand about the contents on this slide"
				(:br)(:br)(:br)
				;;　KMAの宣言２
				(:label :style "font-size: 1.5em"
					(:input :type "radio" :name "kma-result" :value "ng" :style "width:20px; height:20px"
						"正しいが，選択は望ましくない"));;"I don't understand about the contents on this slide"
				(:br)
				(:br)
				(:br)
				;;　KMAの宣言３
				(:label :style "font-size: 1.5em"
					(:input :type "radio" :name "kma-result" :value "error" :style "width:20px; height:20px"
						"誤っている"));;"This slide has incorrect information"
				(:br)
				(:br)
				(:br)
				;;　Next slides
				(:button :class "btn-danger" :type "submit" :style "font-size:1.5em;padding:10px 20px;" "Next Sldie")))
		   (:div :style "clear:both;"
			 (:div :id "declare-time-slide-highlight"
			       ,(slide-row-list lesson-id (parse-integer kma))
			       )))))
	(:script :type"text/javascript" :src ,(append-root-url "/static/js/window-setting/redirect.js"))))

(defun authering-kma-save ()
  (let ((lesson-id (get-parameter "lesson-id"))
	(slide-id (get-parameter "slide-id"))
	(kma-result (get-parameter "kma-result"))
	(kma-number (get-parameter "kma")))
    (fix-kma slide-id kma-result)
    (if (>= (parse-integer kma-number) (slide-length lesson-id))
	(redirect-to-path (format nil "domain-select?lesson-id=~A" lesson-id))
	(redirect-to-path (format nil "authering/authering-slide-check?lesson-id=~A&kma=~A" lesson-id kma-number)))))

(defun fix-kma (slide-id kma-result)
  (let* ((current-time (now))
	 (year (timestamp-year current-time))
	 (month (timestamp-month current-time))
	 (day (timestamp-day current-time))
	 (hour (timestamp-hour current-time))
	 (mini (timestamp-minute current-time))
	 (sec (timestamp-second current-time))
	 (time-stamp (format nil "~A-~2,,,'0@A-~2,,,'0@A ~2,,,'0@A:~2,,,'0@A:~2,,,'0@A" year month day hour mini sec)))
    (update "domain_slide" (format nil "slide_errata=\"~A\", uploaded_at=\"~A\"" kma-result time-stamp)
	    (format nil "slide_id=\"~A\"" slide-id))))

(defun kma-authering-slide (lesson-id kma-number)
    (let ((code nil))
      (loop for x in (get-slide-list-for-authering lesson-id)
	    do (push `((:img :id ,(first x) :class "slide-kma" :src ,(first x) :width "400" :height "300" :style "border: 1px black solid") ,(second x)) code))
      `,(nth
	 (if (stringp kma-number)
	     (parse-integer kma-number)
	     kma-number)
	 (reverse code))))

(defun get-slide-list-for-authering (lesson-id)
  (let ((domain-id (cadar (select "domain_id" "lessons" (format nil "lesson_id=\"~A\"" lesson-id)))))
    (mapcar #'(lambda (d)
		(list (second d) (fourth d)))
	    (select "slide_path, slide_id" "domain_slide" (format nil "domain_id=\"~A\"" domain-id)))))


(defun slide-row-list (lesson-id kma-number)
  (let ((code nil))
    (loop for x in (mapcar #'car (get-slide-list-for-authering lesson-id))
	  for y from 0
	  do (if (= y kma-number)
		 (push `(:img :class "slide-kma highlighted-slide" :src ,x :width "100" :height "80" :style "border: 1px black solid") code)
		 (push `(:img :class "slide-kma" :src ,x :width "80" :height "60" :style "border: 1px black solid") code))
	  do (if (= 0 (mod (1+ y) 8))
		 (push `(:br) code))
	  finally (progn
		    (setf code (reverse code))
		    (push :div code)))
    code))
