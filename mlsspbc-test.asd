(in-package :cl-user)
(defpackage mlsspbc-test-asd
  (:use :cl :asdf))
(in-package :mlsspbc-test-asd)

(defsystem mlsspbc-test
  :author "Tomoki Aburatani"
  :license "MIT"
  :depends-on (:mlsspbc
               :prove)
  :components ((:module "t"
                :components
                ((:file "mlsspbc"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
