;;; sql-presto.el --- Adds Presto support to SQLi mode. -*- lexical-binding: t -*-

;; Copyright (C) since 2018 Katherine Cox-Buday

;; Version: 1.0.0
;; Keywords: sql presto database
;; Package-Requires: ((emacs "24.4"))

;;; Commentary:


;; * What is it?

;;   Emacs comes with a SQL interpreter which is able to open a connection
;;   to databases and present you with a prompt you are probably familiar
;;   with (e.g. `mysql>', `pgsql>', `presto>', etc.). This mode gives you
;;   the ability to do that for Presto.


;; * How do I get it?

;;   The canonical repository for the source code is
;;   [https://github.com/kat-co/sql-prestodb].

;;   The recommended way to install the package is to utilize Emacs's
;;   `package.el' along with MELPA. To set this up, please follow MELPA's
;;   [getting started guide], and then run `M-x package-install
;;   sql-presto'.


;;   [getting started guide] https://melpa.org/#/getting-started


;; * How do I use it?

;;   Within Emacs, run `M-x sql-presto'. You will be prompted by in the
;;   minibuffer for a server. Enter the correct server and you should be
;;   greeted by a SQLi buffer with a `presto>' prompt.

;;   From there you can either type queries in this buffer, or open a
;;   `sql-mode' buffer and send chunks of SQL over to the SQLi buffer with
;;   the requisite key-chords.


;; * Contributing

;;   Please open GitHub issues and issue pull requests. Prior to submitting
;;   a pull-request, please run `make'. This will perform some linting and
;;   attempt to compile the package.

;;   I find the packaging requirements for emacs-lisp files to be onerous
;;   for code in its home repository (albeit very nice once packaged). As
;;   such, the code is "naked" in the sense that it is not wrapped in the
;;   requisite comment blocks. These blocks are added in when the package
;;   is built by pulling from README.org, and echos in the `Makefile'. This
;;   has the added benefit of maintaining a single source of the truth for
;;   things like summaries, commentary, and documentation.


;; * License

;;   Please see the LICENSE file.

;;; Code:
(require 'sql)

(defcustom sql-presto-program "presto"
  "Command to start the Presto command interpreter."
  :type 'file
  :group 'SQL)

(defcustom sql-presto-login-params '(server default-catalog default-schema)
  "Parameters needed to connect to Presto."
  :type 'sql-login-params
  :group 'SQL)

(defcustom sql-presto-options '("--output-format" "CSV_HEADER")
  "List of options for `sql-presto-program'."
  :type '(repeat string)
  :group 'SQL)

(defun sql-presto-comint (product options &optional buffer-name)
  "Connect to Presto in a comint buffer.

PRODUCT is the sql product (presto). OPTIONS are any additional
options to pass to presto-shell. BUFFER-NAME is what you'd like
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
  "Run Presto as an inferior process.

The buffer with name BUFFER will be used or created."
  (interactive "P")
  (sql-product-interactive 'presto buffer))

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

(provide 'sql-presto)
;;; sql-presto.el ends here
