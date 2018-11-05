EMACS=emacs -batch

.PHONY: package
package: src/sql-presto.elc artifacts/LICENSE artifacts/sql-presto.el static-analysis

artifacts/LICENSE: artifacts LICENSE
	cp LICENSE artifacts

artifacts/sql-presto.el : Makefile artifacts README.org src/sql-presto.el
	echo ";;; $(@F) --- Adds Presto support to SQLi mode. -*- lexical-binding: t -*-" > $@
	echo >> $@
	echo ";; Copyright (C) since 2018 Katherine Cox-Buday" >> $@
	echo >> $@
	echo ";; Author: Katherine Cox-Buday <cox.katherine.e@gmail.com>"
	echo ";; Version: 1.0.0" >> $@
	echo ";; Keywords: sql presto database" >> $@
	echo ";; Package-Requires: ((emacs \"24.4\"))" >> $@
	echo >> $@
	echo -n ";;; Commentary:" >> $@
	$(EMACS) \
		--visit README.org\
		--eval "(with-current-buffer \"README.org\" (org-export-to-buffer 'ascii \"*E*\" nil nil nil t nil #'emacs-lisp-mode) (with-current-buffer \"*E*\" (comment-region (point-min) (point-max)) (princ (buffer-string))))" >> $@
	echo "" >> $@
	echo ";;; Code:" >> $@
	cat ./src/sql-presto.el >> $@
	echo ";;; $(@F) ends here" >> $@

artifacts:
	mkdir artifacts

.PHONY: static-analysis
static-analysis : artifacts/sql-presto.el
	$(EMACS) \
		--eval "(checkdoc-file \"$?\")" \
		--eval "(package 'package-lint) (package-lint-batch-and-exit)" \
		--visit $?

.PHONY: clean
clean:
	rm -rf src/*.elc
	rm -rf artifacts/*

%.elc : %.el
	$(EMACS) --eval "(let ((byte-compile-error-on-warn t)) (batch-byte-compile t))" $<
