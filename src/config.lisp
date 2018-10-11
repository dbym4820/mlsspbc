(in-package :cl-user)
(defpackage loapeat.config
  (:use :cl)
  (:import-from :envy
                :config-env-var
                :defconfig)
  (:import-from :cl-annot
		:enable-annot-syntax))
(in-package :loapeat.config)
(enable-annot-syntax)

;;; デフォルトのURLがhttp://localhost/aburataniのときなどに対応
(defparameter *root-url* "")

@export
(defun set-root-url (root-url)
  (setf *root-url* root-url))

@export
(defun append-root-url (url)
  (format nil "~A~A" *root-url* url))

(setf (config-env-var) "APP_ENV")

(defvar *application-root* (asdf:system-source-directory :loapeat))

(defconfig :common
    `(:path-to-database ,(append-root-url (format nil "~A~A" (pathname (merge-pathnames #P"src/databases/" *application-root*)) "database.sqlite"))
      :application-root ,*application-root*
      :document-root ,(merge-pathnames #P"src/resources/" *application-root*)
      :document-path ,(namestring (merge-pathnames #P"src/resources/" *application-root*))
      :static-directory ,(merge-pathnames #P"src/resources/static/" *application-root*)
      :static-path ,(namestring (merge-pathnames #P"src/resources/static/" *application-root*))
      :app-port 8000))

(defconfig |development|
  '())

(defconfig |production|
  '())

(defconfig |test|
  '())

@export
(defun config (&optional key)
  (envy:config #.(package-name *package*) key))

(defun appenv ()
  (uiop:getenv (config-env-var #.(package-name *package*))))

(defun developmentp ()
  (string= (appenv) "development"))

(defun productionp ()
  (string= (appenv) "production"))
