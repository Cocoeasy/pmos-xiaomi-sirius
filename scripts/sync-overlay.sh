#!/bin/sh
# Copy this repo's device packages into the pmaports tree used by pmbootstrap.
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
PMAPORTS="${PMAPORTS:-$HOME/.local/var/pmbootstrap/cache_git/pmaports}"

if [ ! -d "$PMAPORTS/device" ]; then
	echo "pmaports not found at $PMAPORTS" >&2
	echo "Run pmbootstrap init first, or set PMAPORTS=." >&2
	exit 1
fi

mkdir -p "$PMAPORTS/device/testing"
cp -a "$ROOT/overlay/device/testing/device-xiaomi-sirius" "$PMAPORTS/device/testing/"
cp -a "$ROOT/overlay/device/testing/firmware-xiaomi-sirius" "$PMAPORTS/device/testing/"

# If init created a downstream linux-xiaomi-sirius, keep it out of the first build.
if [ -d "$PMAPORTS/device/testing/linux-xiaomi-sirius" ]; then
	echo "Note: leftover linux-xiaomi-sirius from pmbootstrap init — unused."
	echo "This port uses linux-postmarketos-qcom-sdm670 plus kernel/sdm710-xiaomi-sirius.dts"
fi

# Do not inject the dts here. Injection bumps the kernel package
# version and makes a device-package build compile the whole kernel.
# Use scripts/inject-sirius-dts.sh only for a full kernel package build.

echo "Synced overlay into $PMAPORTS"
echo "Next:"
echo "  pmbootstrap checksum device-xiaomi-sirius"
echo "  pmbootstrap build device-xiaomi-sirius"
echo "  (kernel, only when needed) scripts/inject-sirius-dts.sh"
echo "  (kernel, only when needed) pmbootstrap checksum linux-postmarketos-qcom-sdm670"
echo "  (kernel, only when needed) pmbootstrap build linux-postmarketos-qcom-sdm670"
