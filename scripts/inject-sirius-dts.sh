#!/bin/sh
# Copy the sirius dts into the shared sdm670 kernel package and patch APKBUILD.
# Run after pmaports exists (pmbootstrap init or CI).
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
PMAPORTS="${PMAPORTS:-$HOME/.local/var/pmbootstrap/cache_git/pmaports}"
PKG="$PMAPORTS/device/community/linux-postmarketos-qcom-sdm670"
DTS="$ROOT/kernel/sdm710-xiaomi-sirius.dts"

if [ ! -f "$PKG/APKBUILD" ]; then
	echo "kernel package not found: $PKG" >&2
	echo "Run pmbootstrap init first, or set PMAPORTS=." >&2
	exit 1
fi
if [ ! -f "$DTS" ]; then
	echo "missing $DTS" >&2
	exit 1
fi
if [ ! -f "$ROOT/kernel/sirius-force-board-dt.c" ]; then
	echo "missing $ROOT/kernel/sirius-force-board-dt.c" >&2
	exit 1
fi
if [ ! -f "$ROOT/kernel/sirius-builtin-dt.S" ]; then
	echo "missing $ROOT/kernel/sirius-builtin-dt.S" >&2
	exit 1
fi

cp "$DTS" "$PKG/sdm710-xiaomi-sirius.dts"
cp "$ROOT/kernel/sirius-force-board-dt.c" "$PKG/sirius-force-board-dt.c"
cp "$ROOT/kernel/sirius-builtin-dt.S" "$PKG/sirius-builtin-dt.S"
python3 "$ROOT/scripts/inject-sirius-dts.py" "$PKG/APKBUILD"
echo "Injected sirius dts and ABL device-tree swap into $PKG"
echo "Next: pmbootstrap checksum linux-postmarketos-qcom-sdm670"
