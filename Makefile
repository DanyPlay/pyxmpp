VERSION=0.5
SNAPSHOT=

DESTDIR="/"

.PHONY: all version snapshot dist doc cosmetics TODO.pylint pylint ChangeLog www publish

all: version
	umask 022 ; python setup.py build
	-cd examples ; rm -f pyxmpp 2>/dev/null ; ln -s ../build/lib*/pyxmpp .
	-cd examples ; chmod a+x *.py
	-cd tests ; rm -f pyxmpp 2>/dev/null ; ln -s ../build/lib*/pyxmpp .
	-cd tests ; chmod a+x *.py

doc:
	$(MAKE) -C doc

www:
	$(MAKE) -C www

publish:
	$(MAKE) -C publish

pylint:	TODO.pylint

TODO.pylint:
	./auxtools/pylint.sh | tee TODO.pylint

ChangeLog: 
	test -f .svn/entries && make cl-stamp || :
	
cl-stamp: .svn/entries
	TZ=UTC svn log -v --xml \
		| auxtools/svn2log.py -p '/(branches/[^/]+|trunk)' -x ChangeLog -u auxtools/users -F
	touch cl-stamp

cosmetics:
	./auxtools/cosmetics.sh
	
version:
	if test -d ".svn" ; then \
		echo "version='$(VERSION)+svn'" > pyxmpp/version.py ; \
	fi

dist: all ChangeLog
	echo "version='$(VERSION)$(SNAPSHOT)'" > pyxmpp/version.py
	python setup.py sdist

clean:
	python setup.py clean --all

install: all
	umask 022 ; python setup.py install --root $(DESTDIR)
