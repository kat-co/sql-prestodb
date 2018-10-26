(require 'sql)

(defcustom sql-presto-program "presto"
  "Command to start the PrestoDB command interpreter."
  :type 'file
  :group 'SQL)

(defcustom sql-presto-login-params '(server default-catalog default-schema)
  "Parameters needed to connect to PrestoDB."
  :type 'sql-login-params
  :group 'SQL)

(defcustom sql-presto-options '("--output-format" "CSV_HEADER")
  "List of options for `sql-presto-program'."
  :type '(repeat string)
  :group 'SQL)

(defun sql-presto-comint (product options &optional buffer-name)
  "Connect to PrestoDB in a comint buffer.

PRODUCT is the sql product (prestodb). OPTIONS are any additional
options to pass to prestodb-shell. BUFFER-NAME is what you'd like
the SQLi buffer to be named."
  (let ((params (append (unless (string= "" sql-server)
                          `("--server" ,sql-server))
                        (unless (string= "" sql-database)
                          `("--catalog" sql-database))
                        options)))
    ;; See: https://github.com/prestodb/presto/issues/2907
    (setenv "PRESTO_PAGER" "cat")
    (sql-comint product params buffer-name)))

(defun sql-presto (&optional buffer)
  "Run PrestoDB as an inferior process.

The buffer with name BUFFER will be used or created."
  (interactive "P")
  (sql-product-interactive 'prestodb buffer))

(sql-add-product 'prestodb "PrestoDB"
                 :free-software t
                 :list-all "SHOW TABLES;"
                 :list-table "DESCRIBE %s;"
                 :prompt-regexp "^[^>]*> "
                 :prompt-cont-regexp "^[ ]+-> "
                 :sqli-comint-func 'sql-presto-comint
                 :font-lock 'sql-mode-ansi-font-lock-keywords
                 :sqli-login sql-presto-login-params
                 :sqli-program 'sql-presto-program
                 :sqli-options 'sql-presto-options)

(provide 'sql-presto)
