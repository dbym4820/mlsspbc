(in-package :cl-user)
(defpackage mlsspbc-asd
  (:use :cl :asdf))
(in-package :mlsspbc-asd)

(defsystem mlsspbc
  :version "0.3"
  :license "MIT"
  :author "Tomoki Aburatani <aburatanitomoki@gmail.com>"
  :depends-on (:closure-html ;; CAn't load by abcl
	       :local-time
	       :alexandria 
	       :hunchentoot
	       :cl-who
	       :plump
	       :clss
	       :dbi ;; Cant't load by abcl
	       :babel
	       :drakma ;; Can't load by abcl
	       :cl-json ;; Can't load by abcl
	       :cl-ppcre
	       :uiop
	       :cl-fad
	       ;;:cxml ;; Can't load by abcl
	       :cl-html-parse ;; Can't load by abcl
	       :cl-html5-parser
	       ;;:ceramic ;; Can't load by abcl
	       :cl-annot
	       :envy
	       :split-sequence)
  :components ((:static-file "LICENCE")
	       (:static-file "README.md")
	       (:module "src"
                :components ((:file "config")
			     (:file "db" :depends-on ("config"))
			     (:file "web-utils" :depends-on ("config"))
			     (:file "utils" :depends-on ("config"))
			     ;;(:file "ontology-utils" :depends-on ("config"))
			     (:file "main" :depends-on ("rooting" "config" "db"))
			     (:file "rooting" :depends-on (resources "web-utils")); "ontology-utils"))
			     (:module "resources"
			      :components ((:file "resource")
					   (:file "user-operator" :depends-on ("resource"))
					   (:file "slide-operator" :depends-on ("resource" "user-operator"))
					   (:file "template" :depends-on ("user-operator" "slide-operator"))
					   (:file "slide" :depends-on ("resource"))
                                           (:file "generate-advice" :depends-on ("resource" "inference-output"))
                                           (:file "index" :depends-on ("template" "slide"))
                                           (:file "task-select" :depends-on ("template" "slide"))
					   (:file "domain-operate" :depends-on ("template" "slide"))
					   (:file "knowledge-operate" :depends-on ("template" "slide"))
					   (:file "lesson-operate" :depends-on ("template" "slide" "domain-operate"))
					   (:file "learner-planning" :depends-on ("template" "slide"))
					   (:file "learner-kma" :depends-on ("template" "slide"))
					   (:file "learner-collaborate" :depends-on ("template" "slide"))
					   (:file "authering-intension-map" :depends-on ("template" "slide"))
					   (:file "authering-slide" :depends-on ("template" "slide"))
					   (:file "authering-target" :depends-on ("template" "slide"))
					   (:file "sign-in" :depends-on ("template" "slide"))
					   (:file "sign-up" :depends-on ("template" "slide"))
					   (:file "sign-process" :depends-on ("template" "slide"))
					   (:file "register-process" :depends-on ("template" "slide"))
					   (:file "concept-operator" :depends-on ("template" "slide"))
					   (:file "inference-output" :depends-on ("template" "slide"))
					   (:file "knowledge-struct" :depends-on ("template" "slide" "knowledge-operate"))
					   (:file "slide-knowledge-struct" :depends-on ("template" "slide" "knowledge-operate"))
					   )))))
  :description "Meta-Learning Support System by using presentation slides"
  :in-order-to ((test-op (load-op cl-mlsspbc-test))))
