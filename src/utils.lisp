(in-package :cl-user)
(defpackage loapeat.utils
  (:use :cl)
  (:import-from :loapeat.config
   :config)
  (:import-from :cl-annot
		:enable-annot-syntax))
(in-package :loapeat.utils)
(enable-annot-syntax)

@export
(defun replace-all-string (string part replacement &key (test #'char=))
  (with-output-to-string (out)
    (loop with part-length = (length part)
	  for old-pos = 0 then (+ pos part-length)
	  for pos = (search part string
			    :start2 old-pos
			    :test test)
	  do (write-string string out
			   :start old-pos
			   :end (or pos (length string)))
	  when pos do (write-string replacement out)
            while pos)))



(set-macro-character #\?
   (lambda (stream char)
     (declare (ignore char))
     (eval (car (read-delimited-list #\? stream t)))))
