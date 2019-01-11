(require 'subr-x)

(find-file-read-only "README.org")
(find-file "src/sql-presto.el")

;; Export the README file as ASCII to an emacs-lisp buffer so that we
;; can comment the ASCII.
(with-current-buffer "README.org"
  (org-export-to-buffer 'ascii "*E*" nil nil nil t nil 'emacs-lisp-mode))

;; Comment the buffer, and splice it into the artifact.
(let ((commentary (with-current-buffer "*E*"
                    (comment-region (point-min) (point-max))
                    (mark-whole-buffer)
                    (fill-paragraph)
                    ;; Trim string of extraneous space and redundant
                    ;; first comment tokens.
                    (substring (string-trim (buffer-string)) 3))))
  (with-current-buffer "sql-presto.el"
    (replace-string "$$COMMENTARY$$" commentary)
    (write-file "../artifacts/sql-presto.el")))
