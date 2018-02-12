(in-package :cl-user)
(defpackage mlsspbc.rooting
  (:use :cl :hunchentoot)
  (:import-from :cl-annot
                :enable-annot-syntax)
  (:import-from :mlsspbc.config
                :config)
  ;; (:import-from :hunchentoot
  ;;               :*dispatch-table*
  ;; 		:create-regex-dispatcher
  ;; 		:create-folder-dispatcher-and-handler)
  (:import-from :mlsspbc.resources
                :index :domain-select :domain-create :domain-create-page
		:lesson-create-page :lesson-create
		:authering-intension-map :authering-slide :authering-target
		:authering-slide-check :upload-slide
		:authering-kma-save
                :knowledge-operate :knowledge-save
                :slide-knowledge-operate :slide-knowledge-save
		:term-knowledge-operate :term-knowledge-save
		:learner-planning
                :learner-kma :slide-kma-save
		:learner-collaborate 
                :generate-advice :knowledge-struct :slide-knowledge-struct
		:sign-in :sign-up :sign-process :sign-out-process :register-process
		:load-concept-map :save-concept-map
		:load-intent-list :save-intent-list :add-intent-list
		:load-slide-line-list :save-side-line-list
		:find-parent-node-id
		:inference-output		
		))
(in-package :mlsspbc.rooting)
(enable-annot-syntax)

@export
(defun dispatcher ()
  (setf *dispatch-table*
	(list
	 'dispatch-easy-handlers
	 ;; Static Resource Rooting
	 (create-folder-dispatcher-and-handler "/static/" (config :static-directory))

	 ;; Page Rooting
	 (create-regex-dispatcher "^/$" (lambda () (eval (index))))
	 (create-regex-dispatcher "^/index$" (lambda () (eval (index))))

	 (create-regex-dispatcher "^/domain-select$" (lambda () (eval (domain-select))))
	 (create-regex-dispatcher "^/domain-create-page$" (lambda () (eval (domain-create-page))))
	 (create-regex-dispatcher "^/domain-create$" (lambda () (eval (domain-create))))

	 (create-regex-dispatcher "^/lesson-create-page$" (lambda () (eval (lesson-create-page))))
	 (create-regex-dispatcher "^/lesson-create$" (lambda () (eval (lesson-create))))
	 
	 ;; Learner Tool
	 (create-regex-dispatcher "^/learner/learner-planning$" (lambda () (eval (learner-planning))))

	 (create-regex-dispatcher "^/learner/learner-kma$" (lambda () (eval (learner-kma))))
	 (create-regex-dispatcher "^/slide-kma-save$" (lambda () (eval (slide-kma-save))))
	 (create-regex-dispatcher "^/learner/learner-collaborate$" (lambda () (eval (learner-planning))))
	 
         ;; Get Advice
         (create-regex-dispatcher "^/generate-advice$" (lambda () (generate-advice)))

	 ;; Authering Tool
	 (create-regex-dispatcher "^/authering/authering-intension-map$" (lambda () (eval (authering-intension-map))))
	 (create-regex-dispatcher "^/authering/authering-slide$" (lambda () (eval (authering-slide))))
	 (create-regex-dispatcher "^/authering/upload-slide$" (lambda () (eval (upload-slide))))
	 (create-regex-dispatcher "^/authering/authering-slide-check$" (lambda () (eval (authering-slide-check))))
	 (create-regex-dispatcher "^/authering-kma-save$" (lambda () (eval (authering-kma-save))))
	 (create-regex-dispatcher "^/authering/knowledge-operate$" (lambda () (eval (knowledge-operate))))
	 (create-regex-dispatcher "^/knowledge-save$" (lambda () (eval (knowledge-save))))
	 (create-regex-dispatcher "^/authering/slide-knowledge-operate$" (lambda () (eval (slide-knowledge-operate))))
	 (create-regex-dispatcher "^/slide-knowledge-save$" (lambda () (eval (slide-knowledge-save))))
	 (create-regex-dispatcher "^/authering/term-knowledge-operate$" (lambda () (eval (term-knowledge-operate))))
	 (create-regex-dispatcher "^/term-knowledge-save$" (lambda () (eval (term-knowledge-save))))
	 
	 (create-regex-dispatcher "^/authering/authering-target$" (lambda () (eval (authering-target))))
	 
	 (create-regex-dispatcher "^/sign-in$" (lambda () (eval (sign-in))))
	 (create-regex-dispatcher "^/sign-up$" (lambda () (eval (sign-up))))

	 ;; Function Rooting
	 (create-regex-dispatcher "^/sign-process$" (lambda () (eval (sign-process))))
	 (create-regex-dispatcher "^/register-process$" (lambda () (eval (register-process))))	 
	 (create-regex-dispatcher "^/sign-out-process$" (lambda () (eval (sign-out-process))))
	 (create-regex-dispatcher "^/find-parent-node-id$" (lambda () (eval (find-parent-node-id))))

	 ;; Static Resource Loader
	 (create-regex-dispatcher "^/load-concept-map$" (lambda () (eval (load-concept-map))))
	 (create-regex-dispatcher "^/load-intent-list$" (lambda () (eval (load-intent-list))))
	 (create-regex-dispatcher "^/save-concept-map$" (lambda () (eval (save-concept-map))))
	 (create-regex-dispatcher "^/save-intent-list$" (lambda () (eval (save-intent-list))))
	 (create-regex-dispatcher "^/add-intent-list$" (lambda () (eval (add-intent-list))))
	 (create-regex-dispatcher "^/load-slide-line-list$" (lambda () (eval (load-slide-line-list))))
	 (create-regex-dispatcher "^/save-side-line-list$" (lambda () (eval (save-side-line-list))))
	 
	 ;; Inference output
	 (create-regex-dispatcher "^/inference-output$" (lambda () (eval (inference-output))))
	 (create-regex-dispatcher "^/knowledge-struct$" (lambda () (knowledge-struct)))
	 (create-regex-dispatcher "^/slide-knowledge-struct$" (lambda () (slide-knowledge-struct)))
 
	 )))
