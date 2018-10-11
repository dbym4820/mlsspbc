(in-package :cl-user)
(defpackage loapeat.rooting
  (:use :cl :hunchentoot)
  (:import-from :cl-annot
                :enable-annot-syntax)
  (:import-from :loapeat.config
                :config :append-root-url)
  ;; (:import-from :hunchentoot
  ;;               :*dispatch-table*
  ;; 		:create-regex-dispatcher
  ;; 		:create-folder-dispatcher-and-handler)
  (:import-from :loapeat.resources
                :index :domain-select :domain-create :domain-create-page
		:lesson-create-page :lesson-create
		:authering-intension-map :authering-slide :authering-target
		:authering-slide-check :upload-slide
		:authering-kma-save
                :knowledge-operate :knowledge-save :exp-knowledge-list :imp-knowledge-list
                :slide-knowledge-operate :slide-knowledge-save
		:term-knowledge-operate :term-knowledge-save
		:learner-planning
                :learner-slide-selection :learner-kma :slide-kma-save
		:learner-collaborate 
                :generate-advice :knowledge-struct :knowledge-edge :slide-knowledge-struct :slide-knowledge-edge
		:sign-in :sign-up :sign-process :sign-out-process :register-process
		:load-concept-map :save-concept-map
		:load-intent-list :save-intent-list :add-intent-list
		:load-slide-line-list :save-side-line-list
		:find-parent-node-id
		:inference-output

		;; API
   ;; :get-lesson-all-test
		))
(in-package :loapeat.rooting)
(enable-annot-syntax)

(defmacro defroute (url &body page-gen-function)
  `(create-regex-dispatcher (format nil "^~A$" (append-root-url ,url)) (lambda () ,@page-gen-function)))

@export
(defun dispatcher ()
  (setf *dispatch-table*
	(list
	 'dispatch-easy-handlers
	 ;; Static Resource Rooting
	 (create-folder-dispatcher-and-handler (format nil "~A~A" (append-root-url "") "/static/") (config :static-directory))

	 ;; defpageで定義したページはevalする必要あり
	 ;; Page Rooting
	 (defroute "/" (eval (index)))
	 (defroute "/index" (eval (index)))

	 (defroute "/domain-select" (eval (domain-select)))
	 
	 (defroute "/domain-create-page" (eval (domain-create-page)))
	 (defroute "/domain-create" (eval (domain-create)))

	 (defroute "/lesson-create-page" (eval (lesson-create-page)))
	 (defroute "/lesson-create" (eval (lesson-create)))
	 
	 ;; Learner Tool
	 (defroute "/learner/learner-planning" (eval (learner-planning)))
	 (defroute "/learner/learner-slide-selection" (eval (learner-slide-selection)))
	 (defroute "/learner/learner-kma" (eval (learner-kma)))
	 (defroute "/slide-kma-save" (eval (slide-kma-save)))
	 (defroute "/learner/learner-collaborate" (eval (learner-planning)))
	 
         ;; Get Advice
         (defroute "/generate-advice" (generate-advice))

	 ;; Authering Tool
	 (defroute "/authering/authering-intension-map" (eval (authering-intension-map)))
	 (defroute "/authering/authering-slide" (eval (authering-slide)))
	 (defroute "/authering/upload-slide" (eval (upload-slide)))
	 (defroute "/authering/authering-slide-check" (eval (authering-slide-check)))
	 (defroute "/authering-kma-save" (eval (authering-kma-save)))
	 (defroute "/authering/knowledge-operate" (eval (knowledge-operate)))
	 (defroute "/knowledge-save" (eval (knowledge-save)))
	 (defroute "/authering/slide-knowledge-operate" (eval (slide-knowledge-operate)))
	 (defroute "/slide-knowledge-save" (eval (slide-knowledge-save)))
	 (defroute "/authering/term-knowledge-operate" (eval (term-knowledge-operate)))
	 (defroute "/term-knowledge-save" (eval (term-knowledge-save)))
	 
	 (defroute "/authering/authering-target" (eval (authering-target)))
	 
	 (defroute "/sign-in" (eval (sign-in)))
	 (defroute "/sign-up" (eval (sign-up)))

	 ;; Function Rooting
	 (defroute "/sign-process" (eval (sign-process)))
	 (defroute "/register-process" (eval (register-process)))
	 (defroute "/sign-out-process" (eval (sign-out-process)))
	 (defroute "/find-parent-node-id" (eval (find-parent-node-id)))

	 ;; Static Resource Loader
	 (defroute "/load-concept-map" (eval (load-concept-map)))
	 (defroute "/load-intent-list" (eval (load-intent-list)))
	 (defroute "/save-concept-map" (eval (save-concept-map)))
	 (defroute "/save-intent-list" (eval (save-intent-list)))
	 (defroute "/add-intent-list" (eval (add-intent-list)))
	 (defroute "/load-slide-line-list" (eval (load-slide-line-list)))
	 (defroute "/save-side-line-list" (eval (save-side-line-list)))
	 
	 ;; Inference output
	 (defroute "/inference-output" (eval (inference-output)))
	 (defroute "/knowledge-struct" (knowledge-struct))
	 (defroute "/knowledge-edge" (knowledge-edge))
	 (defroute "/slide-knowledge-struct" (slide-knowledge-struct))
	 (defroute "/slide-knowledge-edge" (slide-knowledge-edge))

	 ;; knowledge-list
	 (defroute "/exp-knowledge-list" (exp-knowledge-list))
	 (defroute "/imp-knowledge-list" (imp-knowledge-list))

	 ;; APIs
	 (defroute "/api/semantics" (loapeat.resources.api::get-semantics-api))
	 (defroute "/api/domains" (loapeat.resources.api::get-domains-api))
	 (defroute "/api/lessons" (loapeat.resources.api::get-lessons-api))
	 (defroute "/api/presentations" (loapeat.resources.api::get-presentations-api))
	 (defroute "/api/post/presentations" (loapeat.resources.api::post-presentaions-api))
	 (defroute "/api/slides" (loapeat.resources.api::get-slides-api))
	 (defroute "/api/users" (loapeat.resources.api::get-users-api))
	 )))
