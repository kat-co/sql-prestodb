EMACS=emacs -batch

artifacts/sql-prestodb.el : Makefile artifacts README.org src/sql-prestodb.elc
	echo ";;; sql-prestodb --- Adds Presto support to Emacs's SQLi mode." > $@
	echo "" >> $@
	echo ";;; Commentary:" >> $@
	$(EMACS) \
		--visit README.org\
		--eval "(with-current-buffer \"README.org\" (org-export-to-buffer 'ascii \"*E*\" nil nil nil t nil #'emacs-lisp-mode) (with-current-buffer \"*E*\" (comment-region (point-min) (point-max)) (princ (buffer-string))))" >> $@
	echo "" >> $@
	echo ";;; Code:" >> $@
	cat ./src/sql-prestodb.el >> $@
	echo ";;; $(@F) ends here" >> $@

artifacts:
	mkdir artifacts

clean:
	rm -rf src/*.elc
	rm -rf artifacts/*

%.elc : %.el
	$(EMACS) --eval "(let ((byte-compile-error-on-warn t)) (batch-byte-compile t))" $<
