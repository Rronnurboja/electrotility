# Maintainer: Rron Nurboja <rronnurboja@gmail.com>
pkgname=electrotility
pkgver=2.0.0
pkgrel=1
pkgdesc="Ultimate Linux Power Utility Tool"
arch=('any')
url="https://github.com/yourusername/electrotility"
license=('GPL3')
depends=('bash')
optdepends=(
    'curl: for downloading components'
    'wget: alternative download tool'
    'git: for some development features'
)
source=("$pkgname-$pkgver.tar.gz::https://github.com/yourusername/electrotility/archive/refs/tags/v$pkgver.tar.gz")
md5sums=('SKIP')  # We'll update this after creating the release

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 electrotility.sh "$pkgdir/usr/bin/electro"
}
