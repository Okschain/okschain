#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

OKSCHAIND=${BITCOIND:-$BINDIR/okschaind}
OKSCHAINCLI=${BITCOINCLI:-$BINDIR/okschain-cli}
OKSCHAINTX=${BITCOINTX:-$BINDIR/okschain-tx}
OKSCHAINQT=${BITCOINQT:-$BINDIR/qt/okschain-qt}

[ ! -x $OKSCHAIND ] && echo "$OKSCHAIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
OKSVER=($($OKSCHAINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$OKSCHAIND --version | sed -n '1!p' >> footer.h2m

for cmd in $OKSCHAIND $OKSCHAINCLI $OKSCHAINTX $OKSCHAINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${OKSVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${OKSVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
