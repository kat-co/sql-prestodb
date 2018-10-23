;;; sql-prestodb --- Adds Presto support to Emacs's SQLi mode.

;;; Commentary:



;; * What is it?

;;   Emacs comes with a SQL interpreter which is able to open a connection
;;   to databases and present you with a prompt you are probably familiar
;;   with (e.g. `mysql>', `pgsql>', `presto>', etc.). This mode gives you
;;   the ability to do that for Presto.


;; * How do I get it?

;;   The canonical repository for the source code is
;;   [https://github.com/kat-co/sql-prestodb].

;;   I am working on getting this into MEPLA (and perhaps ELPA). For now,
;;   clone the repo, open src/sql-prestodb.el in Emacs, and run `M-x
;;   eval-buffer'.


;; * How do I use it?

;;   Within Emacs, run `M-x sql-prestodb'. You will be prompted by in the
;;   minibuffer for a server. Enter the correct server and you should be
;;   greeted by a SQLi buffer with a `presto>' prompt.

;;   From there you can either type queries in this buffer, or open a
;;   `sql-mode' buffer and send chunks of SQL over to the SQLi buffer with
;;   the requisite key-chords.


;; * Contributing

;;   Please open GitHub issues and issue pull requests.

;;   I find the packaging requirements for emacs-lisp files to be onerous
;;   for code in its home repository (albeit very nice once packaged). As
;;   such, the code is "naked" in the sense that it is not wrapped in the
;;   requisite comment blocks. These blocks are added in when the package
;;   is built by pulling from README.org. This has the added benefit of
;;   maintaining a single source of the truth for things like summaries,
;;   commentary, and documentation.


;; * License

;;   Please see the LICENSE file.

;;; Code:
(require 'sql)

(defcustom sql-prestodb-program "presto"
  "Command to start the PrestoDB command interpreter."
  :type 'file
  :group 'SQL)

(defcustom sql-prestodb-login-params '(server default-catalog default-schema)
  "Parameters needed to connect to PrestoDB."
  :type 'sql-login-params
  :group 'SQL)

(defcustom sql-prestodb-options '("--output-format" "CSV_HEADER")
  "List of options for `sql-prestodb-program'."
  :type '(repeat string)
  :group 'SQL)

(defun sql-prestodb-comint (product options &optional buffer-name)
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

(defun sql-prestodb (&optional buffer)
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
                 :sqli-comint-func 'sql-prestodb-comint
                 :font-lock 'sql-mode-ansi-font-lock-keywords
                 :sqli-login sql-prestodb-login-params
                 :sqli-program 'sql-prestodb-program
                 :sqli-options 'sql-prestodb-options)

(provide 'sql-prestodb)
;;; sql-prestodb.el ends here
