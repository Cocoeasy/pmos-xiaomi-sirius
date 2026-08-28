#!/bin/sh
# Compile sdm710-xiaomi-sirius.dtb against the sdm670-mainline tag that
# pmaports currently pins. Does not build the kernel Image or a boot.img.
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
WORKDIR="${WORKDIR:-$ROOT/.work/linux-dtb}"
DTS="$ROOT/kernel/sdm710-xiaomi-sirius.dts"
PMAPORTS="${PMAPORTS:-$HOME/.local/var/pmbootstrap/cache_git/pmaports}"
APKBUILD="$PMAPORTS/device/community/linux-postmarketos-qcom-sdm670/APKBUILD"
OUT="${OUT:-$ROOT/.work/sdm710-xiaomi-sirius.dtb}"

if [ ! -f "$DTS" ]; then
	echo "missing $DTS" >&2
	exit 1
fi

if [ -z "${KERNEL_TAG:-}" ]; then
	if [ -f "$APKBUILD" ]; then
		pkgver=$(grep '^pkgver=' "$APKBUILD" | head -n1 | cut -d= -f2 | tr -d '"')
		KERNEL_TAG="sdm670-v$pkgver"
	else
		KERNEL_TAG="sdm670-v7.1.3"
		echo "pmaports APKBUILD not found; falling back to $KERNEL_TAG"
	fi
fi

echo "Using kernel tag $KERNEL_TAG"
mkdir -p "$WORKDIR" "$(dirname "$OUT")"

if [ ! -f "$WORKDIR/linux/Makefile" ]; then
	rm -rf "$WORKDIR/linux"
	git clone --depth 1 --branch "$KERNEL_TAG" \
		https://gitlab.com/sdm670-mainline/linux.git "$WORKDIR/linux"
fi

cp "$DTS" "$WORKDIR/linux/arch/arm64/boot/dts/qcom/sdm710-xiaomi-sirius.dts"
mf="$WORKDIR/linux/arch/arm64/boot/dts/qcom/Makefile"
if ! grep -q 'sdm710-xiaomi-sirius.dtb' "$mf"; then
	if grep -q 'sdm710-xiaomi-pyxis.dtb' "$mf"; then
		sed -i '/sdm710-xiaomi-pyxis.dtb/a dtb-$(CONFIG_ARCH_QCOM)	+= sdm710-xiaomi-sirius.dtb' "$mf"
	else
		printf '%s\n' 'dtb-$(CONFIG_ARCH_QCOM)	+= sdm710-xiaomi-sirius.dtb' >> "$mf"
	fi
fi

cd "$WORKDIR/linux"
make ARCH=arm64 defconfig
if [ -f arch/arm64/configs/sdm670.config ]; then
	./scripts/kconfig/merge_config.sh -m .config arch/arm64/configs/sdm670.config
	make ARCH=arm64 olddefconfig
else
	./scripts/config --enable CONFIG_ARCH_QCOM
	make ARCH=arm64 olddefconfig
fi

if ! make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
	qcom/sdm710-xiaomi-sirius.dtb -j"$(nproc)"; then
	make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
		arch/arm64/boot/dts/qcom/sdm710-xiaomi-sirius.dtb -j"$(nproc)"
fi

dtb="$WORKDIR/linux/arch/arm64/boot/dts/qcom/sdm710-xiaomi-sirius.dtb"
if [ ! -f "$dtb" ]; then
	echo "dtb was not produced" >&2
	exit 1
fi
cp "$dtb" "$OUT"
echo "Wrote $OUT"
ls -l "$OUT"
