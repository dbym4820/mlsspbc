(in-package :loapeat.resources)

(defpage sign-in ()
  `(:a :href "#" :data-toggle "" :data-target "#login-modal")
  `(:div :id "login-modal" :tabindex "1" :role "dialog" :aria-lebelledby "myModalLabel" :aria-hidden "false"
  	 (:div :class "modal-dialog"
  	       (:div :class "loginmodal-container"
  		     (:h1 "Login to Your Account")
  		     (:br)
  		     (:form :method "post" :action ,(append-root-url "/sign-process")
  			    (:input :type "text" :name "email" :placeholder "Email" :autofocus)
			    
  			    ;;(:p :style "color: red;" "ユーザ名かパスワードが間違っています")
  			    (:input :type "password" :name "password" :placeholder "Password")
  			    ;;(:p :style "color: red;" "ユーザ名かパスワードが間違っています")
			    
  			    (:input :type "submit" :name "login" :class "login loginmodal-submit" :value "login")
  			    (:div :class "login-help"
  				  (:a :href ,(append-root-url "/sign-up") "Register")
  				  "-"
  				  (:a :href "#" "Forgot Password"))
  			    (:br)
  			    (:div :style "text-align: right;"
  				  (:a :href ,(append-root-url "/") "TOPへ戻る")))))))
