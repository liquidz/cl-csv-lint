#|
  This file is a part of cl-csv-lint project.
|#

(in-package :cl-user)
(defpackage cl-csv-lint-asd
  (:use :cl :asdf))
(in-package :cl-csv-lint-asd)

(defsystem cl-csv-lint
  :version "0.1"
  :author ""
  :license ""
  :depends-on (
      :cl-ppcre
      :cl-csv
      :yason)
  :components ((:module "src"
                :components
                ((:file "cl-csv-lint"))))
  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.md"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op cl-csv-lint-test))))
