EMACS=emacs -batch
EMACS_PKG_FLAGS=--eval "(require 'package)" --eval "(package-initialize)"

.PHONY: package
package : src/.static-analysis src/sql-presto.elc artifacts/LICENSE artifacts/sql-presto.el

artifacts/LICENSE : LICENSE
	cp ./LICENSE artifacts/LICENSE

artifacts/sql-presto.el : src/copy-commentary.el README.org src/sql-presto.el
	$(EMACS) --load src/copy-commentary.el

src/.static-analysis : src/sql-presto.el
	$(EMACS) ${EMACS_PKG_FLAGS} --visit $? --eval "(require 'package-lint)" -f package-lint-buffer
	touch src/.static-analysis

.PHONY: clean
clean :
	rm -rf src/*.elc
	rm -rf artifacts/*

%.elc : %.el
	$(EMACS) --eval "(let ((byte-compile-error-on-warn t)) (batch-byte-compile t))" $<
