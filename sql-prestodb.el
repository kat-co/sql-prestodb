(require 'sql)

(defcustom sql-prestodb-program "presto"
  "Command to start the PrestoDB command interpreter."
  :type 'file
  :group 'SQL)

(defcustom sql-prestodb-login-params '(server default-catalog default-schema)
  "Parameters needed to connect to PrestoDB."
  :type 'sql-login-params
  :group 'SQL)

(defcustom sql-prestodb-options '()
  "List of options for `sql-prestodb-program'."
  :type '(repeat string)
  :group 'SQL)

(defun sql-comint-prestodb (product options &optional buffer-name)
  "Connect to PrestoDB in a comint buffer.

`product' is the sql product (prestodb). `options' are any
additional options to pass to prestodb-shell."
  (let ((params (append (unless (string= "" sql-server)
                          `("--server" ,sql-server))
                        (unless (string= "" sql-database)
                          `("--catalog" sql-database))
                        options)))
    (setenv "PAGER" "cat")
    (setenv "PRESTO_PAGER" "cat")
    (sql-comint product params buffer-name)))

(defun sql-prestodb (&optional buffer)
  "Run PrestoDB as an inferior process.

The buffer with name `buffer' will be used or created."
  (interactive "P")
  (sql-product-interactive 'prestodb buffer))

(sql-add-product 'prestodb "PrestoDB"
                 :prompt-regexp "^presto> "
                 :prompt-cont-regexp "^\\* "
                 :prompt-length 8
                 :sqli-comint-func 'sql-comint-prestodb
                 :sqli-login sql-prestodb-login-params
                 :sqli-program 'sql-prestodb-program
                 :sqli-options 'sql-prestodb-options)

(provide 'sql-prestodb)
