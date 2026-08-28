#!/usr/bin/env python3
"""Add sdm710-xiaomi-sirius.dts and ABL dt swap to linux-postmarketos-qcom-sdm670."""
from __future__ import annotations

import pathlib
import re
import sys

HOOK = r"""
	# sirius overlay: board dts (stub until board nodes are filled)
	cp "$srcdir/sdm710-xiaomi-sirius.dts" "$builddir/arch/arm64/boot/dts/qcom/"
	if ! grep -q sdm710-xiaomi-sirius.dtb "$builddir/arch/arm64/boot/dts/qcom/Makefile"; then
		printf '%s\n' 'dtb-$(CONFIG_ARCH_QCOM)	+= sdm710-xiaomi-sirius.dtb' >> "$builddir/arch/arm64/boot/dts/qcom/Makefile"
	fi
	# ABL only starts a kernel that still looks like the Android SoC tree.
	# Embed this board's dtb and swap it in before unflatten.
	cp "$srcdir/sirius-force-board-dt.c" "$builddir/arch/arm64/kernel/"
	cp "$srcdir/sirius-builtin-dt.S" "$builddir/arch/arm64/kernel/"
	km="$builddir/arch/arm64/kernel/Makefile"
	if ! grep -q sirius-force-board-dt.o "$km"; then
		printf '%s\n' 'obj-y += sirius-force-board-dt.o sirius-builtin-dt.o' >> "$km"
		printf '%s\n' '$(obj)/sirius-builtin-dt.o: $(objtree)/arch/arm64/boot/dts/qcom/sdm710-xiaomi-sirius.dtb' >> "$km"
	fi
	sc="$builddir/arch/arm64/kernel/setup.c"
	if ! grep -q sirius_maybe_replace_fdt "$sc"; then
		if ! grep -q 'setup_machine_fdt(__fdt_pointer);' "$sc"; then
			echo "setup.c: setup_machine_fdt(__fdt_pointer) not found" >&2
			exit 1
		fi
		sed -i 's/setup_machine_fdt(__fdt_pointer);/setup_machine_fdt(sirius_maybe_replace_fdt(__fdt_pointer));/' "$sc"
		sed -i '/phys_addr_t __fdt_pointer __initdata;/a phys_addr_t sirius_maybe_replace_fdt(phys_addr_t dt_phys);' "$sc"
	fi
"""


def add_source(text: str, filename: str) -> str:
    if filename in text:
        return text
    match = re.search(r'^source="\n', text, re.M)
    if not match:
        raise SystemExit("APKBUILD: no source=\" block")
    end = text.find('\n"', match.end())
    if end < 0:
        raise SystemExit("APKBUILD: source= block is not closed")
    return text[:end] + f"\n\t{filename}" + text[end:]


def add_prepare_hook(text: str) -> str:
    if "sirius-force-board-dt.c" in text and "sirius overlay: board dts" in text:
        return text
    if "sirius overlay: board dts" in text and "sirius-force-board-dt.c" not in text:
        raise SystemExit("APKBUILD already has the old dts hook; refresh pmaports")
    if "default_prepare" in text:
        return text.replace("default_prepare", "default_prepare" + HOOK, 1)
    return text + "\nprepare() {\n\tdefault_prepare" + HOOK + "}\n"


def bump_pkgrel(text: str) -> str:
    """Make this package newer than the official binary so pmbootstrap rebuilds."""
    if "sirius-force-board-dt.c" in text:
        return text

    def repl(match: re.Match[str]) -> str:
        return f"pkgrel={int(match.group(1)) + 100}"

    updated, n = re.subn(r"^pkgrel=(\d+)", repl, text, count=1, flags=re.M)
    if n != 1:
        raise SystemExit("APKBUILD: could not bump pkgrel")
    return updated


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit(f"usage: {sys.argv[0]} APKBUILD")
    path = pathlib.Path(sys.argv[1])
    text = path.read_text(encoding="utf-8")
    text = bump_pkgrel(text)
    text = add_source(text, "sdm710-xiaomi-sirius.dts")
    text = add_source(text, "sirius-force-board-dt.c")
    text = add_source(text, "sirius-builtin-dt.S")
    text = add_prepare_hook(text)
    path.write_text(text, encoding="utf-8")
    print(f"patched {path}")


if __name__ == "__main__":
    main()
