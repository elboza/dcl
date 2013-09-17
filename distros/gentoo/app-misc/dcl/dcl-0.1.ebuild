# Copyright 1999-2013 Gentoo Foundation
# metar custom ebuild by xnando
# Distributed under the terms of the GNU General Public License v2
# $Header:$
	
# Please note that this file is still experimental !
#
# if you wonder how to use this ebuild :

# su
# 
# 
# mkdir -p /usr/local/portage/app-misc/dcl
# cp dcl-0.1.ebuild /usr/local/portage/app-misc/dcl/
# cd /usr/local/portage/app-misc/dcl
# ebuild  ${P}.ebuild digest
# echo PORTDIR_OVERLAY=/usr/local/portage >> /etc/make.conf
# emerge dcl

DESCRIPTION="D-cleaner (Disk && Directory Cleaner)"
HOMEPAGE="http://github.com/elboza/dcl"
SRC_URI="http://www.autistici.org/0xFE/software/releases/dcl/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="dev-lang/perl"

RDEPEND=""

src_unpack() {
        unpack ${A}
        cd ${S}
}
S=${WORKDIR}/${PN}
src_install() {
    elog "installing ${P}"
	mkdir -p "${D}/usr/bin"
	cp "${S}"/dcl.pl "${D}"/usr/bin/dcl
}

