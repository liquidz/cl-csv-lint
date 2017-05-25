(in-package :cl-user)
(defpackage cl-csv-lint
  (:use :cl)
  (:export :validate))
(in-package :cl-csv-lint)

(defun read-json (json-file)
  (jsown:parse
    (alexandria:read-file-into-string json-file)))

(defun read-rule-json (json-file)
  (let ((json (read-json json-file)))
    (loop for j in json do
      (let ((pattern (jsown:val j "pattern")))
        (setf (jsown:val j "pattern")
              (ppcre:create-scanner pattern))))
    json))

(defun read-csv (csv-file &key (skip-header nil))
  (let ((csv (with-open-file (stream csv-file :if-does-not-exist nil)
               (when stream
                 (cl-csv:read-csv stream)))))
    (if skip-header
      (cdr csv)
      csv)))

;(declaim (ftype (function (list list) (values string &optional))))
(defun validate-csv-column (rule csv-value)
  ;(declare (type string rule-file))
  ;(declare (type string csv-file))
  ;(declare (type boolean skip-header))
  (let ((name    (jsown:val rule "name"))
        (pattern (jsown:val rule "pattern")))
    (unless (ppcre:scan pattern csv-value)
      (format () "~A error: rule[~A] value[~A]"
               name pattern csv-value))))

(defun validate-csv-row (rules target-csv-row)
  (if (not (= (length rules) (length target-csv-row)))
    (list (format () "invalid length: expected[~A] actual[~A]"
                  (length rules) (length target-csv-row)))
    (remove-if #'not
               (mapcar #'validate-csv-column
                       rules
                       target-csv-row))))

(defun validate-csv (rules csv)
  (reduce (lambda (res row)
            (nconc res (validate-csv-row rules row)))
          csv :initial-value ()))

(defun validate (rule-file csv-file &key (skip-header nil))
  (let ((rules (read-rule-json rule-file))
        (csv   (read-csv csv-file :skip-header skip-header)))
    (validate-csv rules csv)))


;(sb-profile:profile "CL-CSV-LINT")
;(time
;  (loop repeat 10 do
;        (validate
;          "~/.roswell/local-projects/cl-csv-lint/benchmark/rule.json"
;          "~/.roswell/local-projects/cl-csv-lint/benchmark/MOCK_DATA.csv")))
;(sb-profile:report)
