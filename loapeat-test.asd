(in-package :cl-user)
(defpackage loapeat-test-asd
  (:use :cl :asdf))
(in-package :loapeat-test-asd)

(defsystem loapeat-test
  :author "Tomoki Aburatani"
  :license "MIT"
  :depends-on (:loapeat
               :prove)
  :components ((:module "t"
                :components
                ((:file "loapeat"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
