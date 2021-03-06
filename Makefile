VERSION=5.0
PKGREL=28

PACKAGE=libpve-common-perl

PREFIX=/usr
BINDIR=${PREFIX}/bin
MANDIR=${PREFIX}/share/man
DOCDIR=${PREFIX}/share/doc
MAN1DIR=${MANDIR}/man1/
PERLDIR=${PREFIX}/share/perl5

ARCH=all
GITVERSION:=$(shell git rev-parse HEAD)

DEB=${PACKAGE}_${VERSION}-${PKGREL}_${ARCH}.deb

all: ${DEB}

.PHONY: dinstall
dinstall: deb
	dpkg -i ${DEB}


.PHONY: deb
deb ${DEB}:
	$(MAKE) -C test check
	rm -rf build
	rsync -a src/ build
	rsync -a debian/ build/debian
	echo "git clone git://git.proxmox.com/git/pve-common.git\\ngit checkout ${GITVERSION}" > build/debian/SOURCE
	cd build; dpkg-buildpackage -b -us -uc
	lintian ${DEB}

.PHONY: clean
clean: 	
	rm -rf *~ *.deb *.changes build ${PACKAGE}-*.tar.gz *.buildinfo

.PHONY: distclean
distclean: clean

.PHONY: check
check:
	$(MAKE) -C test check

.PHONY: upload
upload: ${DEB}
	tar cf - ${DEB}|ssh repoman@repo.proxmox.com -- upload --product pve,pmg --dist stretch

