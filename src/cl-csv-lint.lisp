(in-package :cl-user)
(defpackage cl-csv-lint
  (:use :cl)
  (:export :validate))
(in-package :cl-csv-lint)

(defun open-stream (file-path f)
  (with-open-file (stream file-path :if-does-not-exist nil)
    (when stream
      (funcall f stream))))

(defun read-json (json-file)
  (open-stream json-file (lambda (stream) (yason:parse stream))))

(defun read-csv (csv-file &key (skip-header nil))
  (let ((csv (open-stream csv-file (lambda (stream) (cl-csv:read-csv stream)))))
    (if skip-header
      (cdr csv)
      csv)))

(defun validate-csv-column (rule-hash csv-value)
  (let ((name    (gethash "name" rule-hash))
        (pattern (gethash "pattern" rule-hash)))
    (unless (ppcre:scan pattern csv-value)
      (format () "~A error: rule[~A] value[~A]"
               name pattern csv-value))))

(defun validate-csv-row (rule-hash-list target-csv-row)
  (if (not (= (length rule-hash-list) (length target-csv-row)))
    (list (format () "invalid length: expected[~A] actual[~A]"
                  (length rule-hash-list) (length target-csv-row)))
    (remove-if #'not
               (mapcar #'validate-csv-column
                       rule-hash-list
                       target-csv-row))))

(defun validate-csv (rule csv)
  (reduce (lambda (res row)
            (append res (validate-csv-row rule row)))
          csv :initial-value ()))

(defun validate (rule-file csv-file &key (skip-header nil))
  (let ((rule (read-json rule-file))
        (csv  (read-csv csv-file :skip-header skip-header)))
    (validate-csv rule csv)))
