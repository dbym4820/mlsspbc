(in-package #:mlss)

(defun slides ()
  (html-generator
   `((:html
      (:head
       (:meta :name "viewport" :content "width=device-width, initial-scale=1.0")
       (:meta :charset "utf-8")
       (:meta :http-equiv "X-UA-Compatible" :content "IE=edge,chrome=1")
       (:title "メタ学習教材：オントロジー構築")
       (:meta :name "description" :content "IE=edge,chrome=1")
       (:meta :name "apple-mobile-web-app-capable" :content "yes")
       (:meta :name "apple-mobile-web-app-status-bar-style" :content "black-translucent")
       (:link :rel "stylesheet" :href "../js/reveal-js/css/reveal.css" :type "text/css")
       (:link :rel "stylesheet" :href "../js/reveal-js/css/theme/serif.css" :type "text/css" :id "theme")
       (:link :rel "stylesheet" :href "../js/reveal-js/lib/css/zenburn.css" :type "text/css")
       (:script :src "../js/reveal-js/lib/js/html5shiv.js"))
      (:body
       (:div :class "reveal"
	     (:div :class "slides"
		   ,(get-slide)))
       (:script :src "../js/reveal-js/lib/js/head.min.js")
       (:script :src "../js/reveal-js/js/reveal.js")
       (:script :src "./setting.js"))))))
