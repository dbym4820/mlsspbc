(in-package :cl-user)
(defpackage mlsspbc.rooting
  (:use :cl :hunchentoot)
  (:import-from :cl-annot
                :enable-annot-syntax)
  (:import-from :mlsspbc.config
                :config :append-root-url)
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
	 (create-folder-dispatcher-and-handler "/software/aburatani/static/" (config :static-directory))

	 ;; Page Rooting
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/")) (lambda () (eval (index))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/index")) (lambda () (eval (index))))

         ;; ;; DB
         ;; (create-static-file-dispatcher-and-handler "/software/aburatani/database" "./databases/database.sqlite")

	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/domain-select")) (lambda () (eval (domain-select))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/domain-create-page")) (lambda () (eval (domain-create-page))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/domain-create")) (lambda () (eval (domain-create))))

	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/lesson-create-page")) (lambda () (eval (lesson-create-page))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/lesson-create")) (lambda () (eval (lesson-create))))
	 
	 ;; Learner Tool
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/learner/learner-planning")) (lambda () (eval (learner-planning))))

	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/learner/learner-kma")) (lambda () (eval (learner-kma))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/slide-kma-save")) (lambda () (eval (slide-kma-save))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/learner/learner-collaborate")) (lambda () (eval (learner-planning))))
	 
         ;; Get Advice
         (create-regex-dispatcher (format nil "^~A$" (append-root-url "/generate-advice")) (lambda () (generate-advice)))

	 ;; Authering Tool
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/authering/authering-intension-map")) (lambda () (eval (authering-intension-map))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/authering/authering-slide")) (lambda () (eval (authering-slide))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/authering/upload-slide")) (lambda () (eval (upload-slide))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/authering/authering-slide-check")) (lambda () (eval (authering-slide-check))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/authering-kma-save")) (lambda () (eval (authering-kma-save))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/authering/knowledge-operate")) (lambda () (eval (knowledge-operate))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/knowledge-save")) (lambda () (eval (knowledge-save))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/authering/slide-knowledge-operate")) (lambda () (eval (slide-knowledge-operate))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/slide-knowledge-save")) (lambda () (eval (slide-knowledge-save))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/authering/term-knowledge-operate")) (lambda () (eval (term-knowledge-operate))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/term-knowledge-save")) (lambda () (eval (term-knowledge-save))))
	 
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/authering/authering-target")) (lambda () (eval (authering-target))))
	 
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/sign-in")) (lambda () (eval (sign-in))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/sign-up")) (lambda () (eval (sign-up))))

	 ;; Function Rooting
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/sign-process")) (lambda () (eval (sign-process))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/register-process")) (lambda () (eval (register-process))))	 
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/sign-out-process")) (lambda () (eval (sign-out-process))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/find-parent-node-id")) (lambda () (eval (find-parent-node-id))))

	 ;; Static Resource Loader
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/load-concept-map")) (lambda () (eval (load-concept-map))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/load-intent-list")) (lambda () (eval (load-intent-list))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/save-concept-map")) (lambda () (eval (save-concept-map))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/save-intent-list")) (lambda () (eval (save-intent-list))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/add-intent-list")) (lambda () (eval (add-intent-list))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/load-slide-line-list")) (lambda () (eval (load-slide-line-list))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/save-side-line-list")) (lambda () (eval (save-side-line-list))))
	 
	 ;; Inference output
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/inference-output")) (lambda () (eval (inference-output))))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/knowledge-struct")) (lambda () (knowledge-struct)))
	 (create-regex-dispatcher (format nil "^~A$" (append-root-url "/slide-knowledge-struct")) (lambda () (slide-knowledge-struct)))
 
	 )))
