VERSION=0.0.0

PACKAGEMAKER=/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker

all:

install:
	install -d $(DESTDIR)/usr/bin
	install \
		bin/doubledown \
		bin/doubledown-fsevents \
		$(DESTDIR)/usr/bin/
	install -d $(DESTDIR)/usr/share/man/man1
	install -m644 \
		man/man1/doubledown.1 \
		man/man1/doubledown-fsevents.1 \
		$(DESTDIR)/usr/share/man/man1/

uninstall:
	rm -f \
		$(DESTDIR)/usr/bin/doubledown \
		$(DESTDIR)/usr/bin/doubledown-fsevents \
		$(DESTDIR)/usr/share/man/man1/doubledown.1 \
		$(DESTDIR)/usr/share/man/man1/doubledown-fsevents.1

package:
ifneq (root, $(shell whoami))
	@echo "Only root can build a package."
	@false
endif
	rm -rf package
	mkdir package
	make install DESTDIR=package
	$(PACKAGEMAKER) -r package \
		-i com.devstructure.doubledown \
		--version $(VERSION) -o doubledown-$(VERSION).pkg
	rm -rf package

man:
	find man -name \*.ronn | xargs -n1 ronn \
		--manual=Doubledown --organization=DevStructure --style=toc

gh-pages:
	mkdir -p gh-pages
	find man -name \*.html | xargs -I__ mv __ gh-pages/
	git checkout -q gh-pages
	mv gh-pages/* ./
	ln -sf doubledown.1.html index.html
	git add *.html
	git commit -m "Rebuilt manual."
	git push origin gh-pages
	git checkout -q master
	rmdir gh-pages

.PHONY: all install uninstall package man gh-pages
