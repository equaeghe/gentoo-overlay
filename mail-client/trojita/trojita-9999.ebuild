# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN=trojita

if [[ ${PV} = *9999* ]]; then
	EGIT_REPO_URI="https://invent.kde.org/equaeghe/${MY_PN}.git"
	EGIT_BRANCH="live"
	inherit git-r3
fi
inherit cmake virtualx xdg

DESCRIPTION="A Qt IMAP e-mail client"
HOMEPAGE="http://trojita.flaska.net/"

LICENSE="|| ( GPL-2 GPL-3 )"
SLOT="0"
IUSE="abook +crypt +dbus debug +password pim +spell test +zlib"

REQUIRED_USE="password? ( dbus )"
RESTRICT="!test? ( test )"

BDEPEND="
	dev-qt/linguist-tools:5
	<=dev-util/ragel-7.0.0.9
	zlib? ( virtual/pkgconfig )
"
RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5[ssl]
	dev-qt/qtsql:5[sqlite]
	dev-qt/qtsvg:5
	dev-qt/qtwebkit:5
	dev-qt/qtwidgets:5
	crypt? (
		>=app-crypt/gpgme-1.8.0[cxx,qt5]
		dev-libs/mimetic
	)
	dbus? ( dev-qt/qtdbus:5 )
	password? ( dev-libs/qtkeychain[qt5(+)] )
	pim? ( kde-apps/akonadi-contacts:5 )
	spell? ( kde-frameworks/sonnet:5 )
	zlib? ( sys-libs/zlib )
"
DEPEND="${RDEPEND}
	test? ( dev-qt/qttest:5 )
"

DOCS=( README LICENSE )

src_prepare() {
	cmake_src_prepare

	# the build system is taking a look at `git describe ... --dirty` and
	# gentoo's modifications to CMakeLists.txt break these
	sed -e "s/--dirty//" -i cmake/TrojitaVersion.cmake || die "Cannot fix the version check"
}

src_configure() {
	local mycmakeargs=(
		-DWITH_ABOOKADDRESSBOOK_PLUGIN=$(usex abook)
		-DWITH_CRYPTO_MESSAGES=$(usex crypt)
		-DWITH_GPGMEPP=$(usex crypt)
		-DWITH_MIMETIC=$(usex crypt)
		-DWITH_DBUS=$(usex dbus)
		-DWITH_QTKEYCHAIN_PLUGIN=$(usex password)
		-DWITH_AKONADIADDRESSBOOK_PLUGIN=$(usex pim)
		-DWITH_SONNET_PLUGIN=$(usex spell)
		-DBUILD_TESTING=$(usex test)
		-DWITH_ZLIB=$(usex zlib)
	)

	cmake_src_configure
}

src_test() {
	virtx cmake_src_test
}
