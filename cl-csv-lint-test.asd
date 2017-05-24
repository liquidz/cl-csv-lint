#|
  This file is a part of cl-csv-lint project.
|#

(in-package :cl-user)
(defpackage cl-csv-lint-test-asd
  (:use :cl :asdf))
(in-package :cl-csv-lint-test-asd)

(defsystem cl-csv-lint-test
  :author ""
  :license ""
  :depends-on (:cl-csv-lint
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "cl-csv-lint"))))
  :description "Test system for cl-csv-lint"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
