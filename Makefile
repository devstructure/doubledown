prefix=/usr/local

VERSION=0.0.1

PACKAGEMAKER=/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker

all:

install:
	install -d $(DESTDIR)$(prefix)/bin
	install \
		bin/doubledown \
		bin/doubledown-fsevents \
		$(DESTDIR)$(prefix)/bin/
	install -d $(DESTDIR)$(prefix)/share/man/man1
	install -m644 \
		man/man1/doubledown.1 \
		man/man1/doubledown-fsevents.1 \
		$(DESTDIR)$(prefix)/share/man/man1/

uninstall:
	rm -f \
		$(DESTDIR)$(prefix)/bin/doubledown \
		$(DESTDIR)$(prefix)/bin/doubledown-fsevents \
		$(DESTDIR)$(prefix)/share/man/man1/doubledown.1 \
		$(DESTDIR)$(prefix)/share/man/man1/doubledown-fsevents.1

package:
	sudo rm -rf package
	sudo mkdir package
	sudo make install DESTDIR=package prefix=/usr
	sudo $(PACKAGEMAKER) -r package \
		-i com.devstructure.doubledown \
		--version $(VERSION) -o doubledown.pkg
	tar czf doubledown-$(VERSION).tar.gz doubledown.pkg
	sudo rm -rf package doubledown.pkg

man:
	find man -name \*.ronn | xargs -n1 ronn \
		--manual=Doubledown --organization=DevStructure --style=toc

gh-pages: man
	mkdir -p gh-pages
	find man -name \*.html | xargs -I__ mv __ gh-pages/
	git checkout -q gh-pages
	mv gh-pages/* ./
	git add .
	git commit -m "Rebuilt manual."
	git push origin gh-pages
	git checkout -q master
	rmdir gh-pages

.PHONY: all install uninstall package man docs gh-pages
