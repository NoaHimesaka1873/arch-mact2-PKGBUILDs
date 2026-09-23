#!/bin/bash
# Bumps every PKGBUILD that has a pkgver() function to its upstream HEAD.
# Runs as root in an archlinux:base-devel container with the repo at /repo
# and an output directory at /out (changes.md, failed.txt).
set -euo pipefail

cd /repo
pacman -Syu --noconfirm --needed git nodejs

# makepkg refuses root; match the checkout's owner so the runner can commit afterwards
useradd -m -u "$(stat -c %u .)" builduser
# Shared SRCDEST so the KaiT2en-Fedora monorepo is cloned once, not once per package
install -d -o builduser /srcdest /builddir

: > /out/changes.md
: > /out/failed.txt

for pkgbuild in */PKGBUILD; do
  grep -q '^pkgver()' "$pkgbuild" || continue
  pkg=${pkgbuild%/PKGBUILD}
  old=$(grep -m1 '^pkgver=' "$pkgbuild" | cut -d= -f2)

  echo "::group::$pkg"
  # -o fetches sources and runs pkgver(), which rewrites pkgver= and resets pkgrel=1
  if ! (cd "$pkg" && runuser -u builduser -- env SRCDEST=/srcdest BUILDDIR=/builddir \
      makepkg --nobuild --nodeps --noprepare --skippgpcheck); then
    echo "$pkg" >> /out/failed.txt
    echo "::endgroup::"
    echo "::error::pkgver() failed for $pkg"
    continue
  fi
  echo "::endgroup::"

  new=$(grep -m1 '^pkgver=' "$pkgbuild" | cut -d= -f2)
  if [ "$old" != "$new" ]; then
    echo "- \`$pkg\`: \`$old\` → \`$new\`" >> /out/changes.md
  fi
done
