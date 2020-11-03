;;; sql-presto --- Adds Presto support to SQLi mode. -*- lexical-binding: t -*-

;; Copyright (C) since 2018 Katherine Cox-Buday
;; Author: Katherine Cox-Buday <cox.katherine.e@gmail.com>
;; Version: 1.0.0
;; Keywords: sql presto database
;; Package-Requires: ((emacs "24.4"))


;;; Commentary:
;; $$COMMENTARY$$

;;; Code:
(require 'sql)

(defgroup sql-presto nil
  "Use Presto with sql-interactive mode."
  :group 'SQL
  :prefix "sql-presto-")

(defcustom sql-presto-program "presto"
  "Command to start the Presto command interpreter."
  :type 'file
  :group 'sql-presto)

(defcustom sql-presto-login-params '(server default-catalog default-schema)
  "Parameters needed to connect to Presto."
  :type 'sql-login-params
  :group 'sql-presto)

(defcustom sql-presto-options '("--output-format" "CSV_HEADER")
  "List of options for `sql-presto-program'."
  :type '(repeat string)
  :group 'sql-presto)

(defun sql-presto-comint (product options &optional buffer-name)
  "Connect to Presto in a comint buffer.

PRODUCT is the sql product (presto). OPTIONS are any additional
options to pass to presto-shell. BUFFER-NAME is what you'd like
the SQLi buffer to be named."
  (let ((params (append (unless (string= "" sql-server)
                          `("--server" ,sql-server))
                        (unless (string= "" sql-database)
                          `("--catalog" ,sql-database))
                        options)))
    ;; See: https://github.com/prestodb/presto/issues/2907
    (setenv "PRESTO_PAGER" "cat")
    (sql-comint product params buffer-name)))

;;;###autoload
(defun sql-presto (&optional buffer)
  "Run Presto as an inferior process.

The buffer with name BUFFER will be used or created."
  (interactive "P")
  (sql-product-interactive 'presto buffer))

;; in emacs 27.1, the plist of options needs to be wrapped, like '(:foo "bar"). But even
;; then, it complains that sql-presto-comint isn't a valid function, so WTF. Stick to
;; 26.3 for now.
(sql-add-product 'presto "Presto"
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

;; It's kind of annoying to get a sql-mode buffer to connect to a SQLi buffer,
;; so this automates a lot of it.
;;
;; this answer helps me understand how to link a sql buffer to a presto SQLi
;; buffer: https://stackoverflow.com/a/14322667
(defun sql-prestofy-buffer ()
  "Make a generic sql-mode buffer into a connected presto buffer."
  (interactive)
  (sql-set-product "presto")
  (sql-set-sqli-buffer))

(defun sql-presto-scratch ()
  "Open a scratch buffer that connects to a presto instance."
  (interactive)
  (switch-to-buffer "*sql-scratch*")
  (sql-mode)
  (sql-prestofy-buffer))

(provide 'sql-presto)
;;; sql-presto.el ends here
