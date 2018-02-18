(in-package :mlsspbc.resources)
(enable-annot-syntax)

(defun system-name ()
  "PROTOTYPE SYSTEM")

@export
(defun js-path (path)
  (append-root-url (format nil "~A~A" "/static/js/" path)))

@export
(defun css-path (path)
  (append-root-url (format nil "~A~A" "/static/css/" path)))

@export
(defun image-path (path)
  (append-root-url (format nil "~A~A" "/static/image/" path)))


(setf (cl-who:html-mode) :html5)

(defmacro html-generator (&body body)
  `(quote
    (with-html-output (*standard-output* nil :indent t :prologue nil)
      ,@body)))

@export
(defmacro defunction-page (page-name &body body)
  `(defun ,page-name nil
     ,@body))

@export
(defmacro defpage (page-name (&rest preprocess) &body body)
  `(defun ,page-name nil
     ,(when (not (equal page-name 'sign-in))
	`(when (not (session-value 'login-frag))
	   (redirect-to-path "sign-in")))
     ,preprocess
     `(with-html-output (*standard-output* nil :indent t :prologue t)
	(:html :lang "ja"
	       (:head
		(:meta :charset "utf-8")
		(:meta :http-equiv "X-UA-Comatible" :content "IE=edge")
		(:meta :name "viewpoint" :content "width=device-width, initial-scale=1")
		(:title "Meta Learning Support System")

		(:script :type "text/javascript" :src ,(js-path "first-load.js"))
		
               ;;; Basic libraries
		(:script :type "text/javascript" :src ,(js-path "jquery.min.js"))
		(:script :type "text/javascript" :src ,(js-path "bootstrap/js/bootstrap.min.js"))
		(:script :type "text/javascript" :src ,(js-path "reveal/js/reveal.js"))
		(:script :type "text/javascript" :src ,(js-path "jquery-ui/jquery-ui.min.js"))
		;;; Concept map editor
		(:script :type "text/javascript" :src ,(js-path "concept-map/setup.js"))
		(:script :type "text/javascript" :src ,(js-path "concept-map/advanced-setting.js"))
		(:script :type "text/javascript" :src ,(js-path "concept-map/side-line.js"))
		(:script :type "text/javascript" :src ,(js-path "concept-map/inference-output.js"))

                (:script :type "text/javascript" :src ,(js-path "splitter/splitter.js"))
		
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "bootstrap/css/bootstrap.min.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "concept-editor/concept-editor.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "concept-editor/main-window.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "concept-editor/movable-intension-parts.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "concept-editor/slide-parts.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "concept-editor/slide-setting-container.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "jquery-ui/jquery-ui.min.css"))
                (:link :rel "stylesheet" :type "text/css" :href ,(js-path "splitter/splitter.css"))

		;;; Knowledge operators
		(:link :rel "stylesheet" :type "text/css" :href ,(js-path "cytoscape/knowledge-express.css"))
		(:script :type "text/javascript" :src ,(js-path "cytoscape/cytoscape.min.js")) 
		(:script :type "text/javascript" :src ,(js-path "cytoscape/advanced-setting.js"))
		
	        ;;; Index Setup
		(:script :type "text/javascript" :src ,(js-path "index-setup/cards.js"))
		;; (:script :type "text/javascript" :src ,(js-path "index-setup/bootcards.js"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "index-setup/cards.css"))
		;; (:link :rel "stylesheet" :type "text/css" :href ,(css-path "index-setup/bootcards-android.css"))
		
		;;; sigma(network graph library)
                ;; (:script :type "text/javascript" :src ,(js-path "graphdracula/dist/dracula.min.js"))
                ;; (:script :type "text/javascript" :src ,(js-path "graphdracula/advanced-setting.js"))
		(:script :type "text/javascript" :src ,(js-path "sigma/sigma.min.js"))
		(:script :type "text/javascript" :src ,(js-path "sigma/plugins/sigma.parsers.json.min.js"))

		;;; Intro.js
		(:link :rel "stylesheet" :type "text/css" :href ,(js-path "intro-js/introjs.min.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(js-path "intro-js/introjs-rtl.min.css"))
		(:script :type "text/javascript" :src ,(js-path "intro-js/intro.min.js"))
		(:script :type "text/javascript" :src ,(js-path "intro-js/portfolio.js"))
		
		;;; Alert setup
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "sweet-alert/sweetalert.css"))
		(:script :type "text/javascript" :src ,(js-path "sweet-alert/sweetalert.min.js"))
		(:script :type "text/javascript" :src ,(js-path "sweet-alert/advanced-setup.js"))
		
               ;;; Default window setting
		(:script :type "text/javascript" :src ,(js-path "window-setting/basic.js"))
		(:script :type "text/javascript" :src ,(js-path "split-js/split.min.js"))
                (:link :rel "stylesheet" :type "text/css" :href ,(css-path "split-js/split.css"))
                ;;(:script :type "text/javascript" :src ,(js-path "split-js/setting.js"))
		
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "loading.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "main.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "sign.css"))
		
		;;; register-window-design
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "register.css"))
		
               ;;; Favicon
		(:link :rel "icon" :type "text/css" :href ,(image-path "icon/favicon.ico")))
	       
	       (:body
		(:script :type "text/javascript" "window.onload = function(){ $(function() { $(\"#loading\").fadeOut();	$(\"#loaded\").fadeIn(); }); }")
		(:nav :class "navbar navbar-default"
		      (:div :class "container-fluid"
			    (:div :class "navbar-header"
				  (:button :type "button" :class "navbar-toggle collapsed" :data-toggle "collapse"
					   :data-target "#navbar" :aria-expanded "false" :aria-controls "navbar"
					   (:span :class "sr-only" "Toggle navigation"))
				  (:a :class "navbar-brand" :href ,(append-root-url "/") ,(system-name)))
			    (:div :id "navbar" :class "navbar-collapse collapse"
				  (:ul :class "nav navbar-nav navbar-right"
				       (:li :class "dropdown"
					    (:a :href "" :class "dropdown-toggle login-indicater" :data-toggle "dropdown"
						:role "button" :aria-expanded "false"
						,(format nil "<span style=\"color:red;\">~A</span>"
							 (if (session-value 'login-frag)
							     (format nil "ログイン中：~A (~A)" (session-value 'user-name)
								     (session-value 'user-role))
							     "未ログイン"))
						;;(session-value 'username)
						(:span :class "caret"))
					    (:ul :class "dropdown-menu" :role "menu"
						 (:li :class "dropdown-header" "Preference")
						 (:li (:a :href "#" "Profole"))
						 (:li (:a :href "#" "Setting"))
						 ;; (:li :class "divider")
						 ;; (:li :class "dropdown-header" "Meta-Lerning System")
						 ;; (:li (:a :href "#" "Developer's System"))
						 ;; (:li (:a :href "#" "Learner's System"))
						 ;; (:li :class "divider")
						 ;; (:li :class "dropdown-header" "Presentation System")
						 ;; (:li (:a :href "#" "Presentation System"))
						 (:li :class "divider")
						 (:li :class "dropdown-header" "Session Management")
						 (:li (:a :href ,(append-root-url "/sign-out-process")
							  (:span :class "glyphicon glyphicon-log-out") " Logout"))))))))
		(:div :id "loading"
		      (:img :src ,(append-root-url "/static/image/loading/loading.gif")))
		(:div :class "modal fade" :id "login-modal" :tabindex "-1" :role "dialog"
		      :aria-lebelledby "myModalLabel" :aria-hidden "true" :style "display: none;"
		      (:div :class "modal-dialog"
			    (:div :class "loginmodal-container"
				  (:h1 "Login to Your Account")
				  (:br)
				  (:form :method "post" :action ,(append-root-url "/sign")
					 (:input :type "text" :name "username" :placeholder "UserName")
					 (:input :type "password" :name "password" :placeholder "Password")
					 (:div :class "modal-footer"
					       (:input :type "submit" :name "login" :class "login loginmodal-submit" :value "login")
					       (:button :type "button " :class "btn btn-default" :data-dismiss "modal" "Close")))
				  (:div :class "login-help"
					(:a :href "#" "Register-")
					(:a :href "#" "-Forgot Password")))))
		(:div :id "loaded" :class "loaded"
		      (:div  :id "container" :class "col-md-12 container"
			     ,,@body))
		(:script :type "text/javascript" :src ,(js-path "test/after-loaded.js")))))))


@export
(defmacro defpage-no-redirect (page-name (&rest preprocess) &body body)
  `(defun ,page-name nil
     ,preprocess
     `(with-html-output (*standard-output* nil :indent t :prologue t)
	(:html :lang "ja"
	       (:head
		(:meta :charset "utf-8")
		(:meta :http-equiv "X-UA-Comatible" :content "IE=edge")
		(:meta :name "viewpoint" :content "width=device-width, initial-scale=1")
		(:title "Meta Learning Support System")

;;; Basic libraries
		(:script :type "text/javascript" :src ,(js-path "jquery.min.js"))
		(:script :type "text/javascript" :src ,(js-path "bootstrap/js/bootstrap.min.js"))
		(:script :type "text/javascript" :src ,(js-path "reveal/js/reveal.js"))
		(:script :type "text/javascript" :src ,(js-path "jquery-ui/jquery-ui.min.js"))
		
		;;; Concept map editor
		(:script :type "text/javascript" :src ,(js-path "concept-map/setup.js"))
		(:script :type "text/javascript" :src ,(js-path "concept-map/advanced-setting.js"))
		(:script :type "text/javascript" :src ,(js-path "concept-map/side-line.js"))
		(:script :type "text/javascript" :src ,(js-path "concept-map/inference-output.js"))

                (:script :type "text/javascript" :src ,(js-path "splitter/splitter.js"))
		
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "bootstrap/css/bootstrap.min.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "concept-editor/concept-editor.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "concept-editor/main-window.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "concept-editor/movable-intension-parts.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "concept-editor/slide-parts.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "concept-editor/slide-setting-container.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "jquery-ui/jquery-ui.min.css"))
                (:link :rel "stylesheet" :type "text/css" :href ,(js-path "splitter/splitter.css"))

	        ;;; Index Setup
		(:script :type "text/javascript" :src ,(js-path "index-setup/cards.js"))
		;; (:script :src "https://unpkg.com/minigrid@3.1.1/dist/minigrid.min.js")
		;; (:script :type "text/javascript" :src ,(js-path "index-setup/bootcards.js"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "index-setup/cards.css"))
		;; (:link :rel "stylesheet" :type "text/css" :href ,(css-path "index-setup/bootcards-android.css"))
		;;;(:link :rel "stylesheet" :type "text/css" :href ,(css-path "index-setup/bootcards-ios.css"))
		
		;;; sigma(network graph library)
                ;; (:script :type "text/javascript" :src ,(js-path "graphdracula/dist/dracula.min.js"))
                ;; (:script :type "text/javascript" :src ,(js-path "graphdracula/advanced-setting.js"))
		(:script :type "text/javascript" :src ,(js-path "sigma/sigma.min.js"))
		;; (:script :type "text/javascript" :src ,(js-path "sigma/sigma.require.js"))
		(:script :type "text/javascript" :src ,(js-path "sigma/plugins/sigma.parsers.json.min.js"))

		;;; Intro.js
		(:link :rel "stylesheet" :type "text/css" :href ,(js-path "intro-js/introjs.min.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(js-path "intro-js/introjs-rtl.min.css"))
		(:script :type "text/javascript" :src ,(js-path "intro-js/intro.min.js"))
		(:script :type "text/javascript" :src ,(js-path "intro-js/portfolio.js"))
		
		;;; Alert setup
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "sweet-alert/sweetalert.css"))
		(:script :type "text/javascript" :src ,(js-path "sweet-alert/sweetalert-dev.js"))
		(:script :type "text/javascript" :src ,(js-path "sweet-alert/sweetalert.min.js"))
		(:script :type "text/javascript" :src ,(js-path "sweet-alert/advanced-setup.js"))
		
               ;;; Default window setting
		(:script :type "text/javascript" :src ,(js-path "window-setting/basic.js"))
		(:script :type "text/javascript" :src ,(js-path "split-js/split.min.js"))
                (:link :rel "stylesheet" :type "text/css" :href ,(css-path "split-js/split.css"))
                ;;(:script :type "text/javascript" :src ,(js-path "split-js/setting.js"))
		
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "loading.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "main.css"))
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "no-modal-sign.css"))

		;;; register-window-design
		(:link :rel "stylesheet" :type "text/css" :href ,(css-path "register.css"))

               ;;; Favicon
		(:link :rel "icon" :type "text/css" :href ,(image-path "icon/favicon.ico")))
	       
	       (:body
		(:script :type "text/javascript" "window.onload = function(){ $(function() { $(\"#loading\").fadeOut();	$(\"#loaded\").fadeIn(); }); }")
		(:nav :class "navbar navbar-default"
		      (:div :class "container-fluid"
			    (:div :class "navbar-header"
				  (:button :type "button" :class "navbar-toggle collapsed" :data-toggle "collapse"
					   :data-target "#navbar" :aria-expanded "false" :aria-controls "navbar"
					   (:span :class "sr-only" "Toggle navigation"))
				  (:a :class "navbar-brand" :href ,(append-root-url "/") ,(system-name)))
			    (:div :id "navbar" :class "navbar-collapse collapse"
				  (:ul :class "nav navbar-nav navbar-right"
				       (:li :class "dropdown"
					    (:a :href "" :class "dropdown-toggle" :data-toggle "dropdown"
						:role "button" :aria-expanded "false"
						,(format nil "<span style=\"color:red;\">~A</span>"
							 (if (session-value 'login-frag)
							     (format nil "ログイン中：~A" (session-value 'user-name))
							     "未ログイン"))
						;;(session-value 'username)
						(:span :class "caret"))
					    (:ul :class "dropdown-menu" :role "menu"
						 (:li :class "dropdown-header" "Preference")
						 (:li (:a :href "#" "Profole"))
						 (:li (:a :href "#" "Setting"))
						 (:li :class "divider")
						 (:li :class "dropdown-header" "Meta-Lerning System")
						 (:li (:a :href "#" "Developer's System"))
						 (:li (:a :href "#" "Learner's System"))
						 (:li :class "divider")
						 (:li :class "dropdown-header" "Presentation System")
						 (:li (:a :href "#" "Presentation System"))
						 (:li :class "divider")
						 (:li :class "dropdown-header" "Session Management")
						 (:li (:a :href ,(append-root-url "/sign-out-process")
							  (:span :class "glyphicon glyphicon-log-out") " Logout"))))))))
		(:div :id "loading"
		      (:img :src ,(append-root-url "/static/image/loading/loading.gif")))
		(:div :class "modal fade" :id "login-modal" :tabindex "-1" :role "dialog"
		      :aria-lebelledby "myModalLabel" :aria-hidden "true" :style "display: none;"
		      (:div :class "modal-dialog"
			    (:div :class "loginmodal-container"
				  (:h1 "Login to Your Account")
				  (:br)
				  (:form :method "post" :action ,(append-root-url "/sign")
					 (:input :type "text" :name "username" :placeholder "UserName")
					 (:input :type "password" :name "password" :placeholder "Password")
					 (:div :class "modal-footer"
					       (:input :type "submit" :name "login" :class "login loginmodal-submit" :value "login")
					       (:button :type "button " :class "btn btn-default" :data-dismiss "modal" "Close")))
				  (:div :class "login-help"
					(:a :href "#" "Register-")
					(:a :href "#" "-Forgot Password")))))
		(:div :id "loaded" :class "loaded"
		      (:div  :id "container" :class "col-md-12 container"
			     ,,@body))
		(:script :type "text/javascript" :src ,(js-path "test/after-loaded.js")))))))
