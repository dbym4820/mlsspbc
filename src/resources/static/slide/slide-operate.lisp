(in-package #:mlss)

      
(defun slide-operate ()
  (let ((par (hunchentoot:post-parameter "files")))
    (add-slide (file-open par))))
  
(defun file-open (file)
  (let* ((source (pic-slide-part (car file))))
    (replace-all source "\"" "&quot;")))


(defun pic-slide-part (file)
  (let ((in (open (file :if-does-not-exist nil))
	(lines "")
	(loop-frag nil))
    (when in
      (loop for line = (read-line in nil)
	    while line
	    do (progn
		 (when (not (string= "" (concatenate 'string (ppcre:scan-to-strings "<section data-id" line) "")))
		   (setf loop-frag t))
		 (when (not (string= "" (concatenate 'string (ppcre:scan-to-strings "^<script>$" line) "")))
		   ;; (setf loop-frag nil)
		   (return lines))
		 (when loop-frag
		   (setf lines (concatenate 'string lines line (princ-to-string #\Newline))))))
      (close in))
    lines)))
