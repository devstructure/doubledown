prefix=/usr/local

VERSION=0.0.2
BUILD=1

PACKAGEMAKER=/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker

all:

install:
	install -d $(DESTDIR)$(prefix)/bin
	install bin/doubledown $(DESTDIR)$(prefix)/bin/
	install -d $(DESTDIR)$(prefix)/share/man/man1
	install -m644 man/man1/doubledown.1 \
		$(DESTDIR)$(prefix)/share/man/man1/
	make install-$(shell uname -s)

install-Darwin:
	install bin/doubledown-fsevents $(DESTDIR)$(prefix)/bin/
	install -m644 man/man1/doubledown-fsevents.1 \
		$(DESTDIR)$(prefix)/share/man/man1/

install-Linux:
	install bin/doubledown-inotify $(DESTDIR)$(prefix)/bin/
	install -m644 man/man1/doubledown-inotify.1 \
		$(DESTDIR)$(prefix)/share/man/man1/

uninstall:
	rm -f \
		$(DESTDIR)$(prefix)/bin/doubledown \
		$(DESTDIR)$(prefix)/bin/doubledown-fsevents \
		$(DESTDIR)$(prefix)/bin/doubledown-inotify \
		$(DESTDIR)$(prefix)/share/man/man1/doubledown.1 \
		$(DESTDIR)$(prefix)/share/man/man1/doubledown-fsevents.1 \
		$(DESTDIR)$(prefix)/share/man/man1/doubledown-inotify.1
	rmdir -p --ignore-fail-on-non-empty \
		$(DESTDIR)$(prefix)/bin \
		$(DESTDIR)$(prefix)/share/man/man1

package:
	make package-$(shell uname -s)

package-Darwin:
	sudo rm -rf package
	sudo mkdir package
	sudo make install DESTDIR=package prefix=/usr
	sudo $(PACKAGEMAKER) -r package \
		-i com.devstructure.doubledown \
		--version $(VERSION) -o doubledown.pkg
	tar czf doubledown-$(VERSION).tar.gz doubledown.pkg
	sudo rm -rf package doubledown.pkg

package-Linux: deb

deb:
	[ "$$(whoami)" = "root" ] || false
	m4 -D__VERSION__=$(VERSION)-$(BUILD) control.m4 >control
	debra create debian control
	make install DESTDIR=debian prefix=/usr
	chown -R root:root debian
	debra build debian doubledown_$(VERSION)-$(BUILD)_all.deb
	debra destroy debian

deploy:
	scp -i ~/production.pem doubledown_$(VERSION)-$(BUILD)_all.deb ubuntu@packages.devstructure.com:
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "sudo freight add doubledown_$(VERSION)-$(BUILD)_all.deb apt/lenny apt/squeeze apt/lucid apt/maverick apt/natty && rm doubledown_$(VERSION)-$(BUILD)_all.deb && sudo freight cache apt/lenny apt/squeeze apt/lucid apt/maverick apt/natty"

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

.PHONY: all install install-Darwin install-Linux uninstall package package-Darwin package-Linux deb man docs gh-pages
