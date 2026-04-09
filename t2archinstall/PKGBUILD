# Maintainer: Noa Himesaka <himesaka AT noa DOT codes>
pkgname=t2archinstall
pkgrel=1
pkgver=r35.b41407d
pkgdesc="Arch Linux Installer TUI for Intel Macs with the T2 Security Chip"
url="https://github.com/slsrepo/t2archinstall"
arch=('x86_64')
license=('Apache-2.0')
makedepends=('git' 'python')
depends=('python-textual')
conflicts=('t2fand')
replaces=('t2fand')
source=("git+https://github.com/slsrepo/t2archinstall")
sha256sums=('SKIP')

pkgver() {
  cd "$pkgname"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short=7 HEAD)"
}

package() {
	# Install binary
	install -Dm755 "$pkgname/t2archinstall.py" "$pkgdir/usr/bin/t2archinstall"
}
