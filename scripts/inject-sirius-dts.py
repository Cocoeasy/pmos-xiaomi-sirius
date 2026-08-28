#!/usr/bin/env python3
"""Add sdm710-xiaomi-sirius.dts to linux-postmarketos-qcom-sdm670 APKBUILD."""
from __future__ import annotations

import pathlib
import re
import sys

HOOK = """
	# sirius overlay: board dts (stub until board nodes are filled)
	cp "$srcdir/sdm710-xiaomi-sirius.dts" "$builddir/arch/arm64/boot/dts/qcom/"
	if ! grep -q sdm710-xiaomi-sirius.dtb "$builddir/arch/arm64/boot/dts/qcom/Makefile"; then
		printf '%s\\n' 'dtb-$(CONFIG_ARCH_QCOM)	+= sdm710-xiaomi-sirius.dtb' >> "$builddir/arch/arm64/boot/dts/qcom/Makefile"
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
    if "sirius overlay: board dts" in text:
        return text
    if "default_prepare" in text:
        return text.replace("default_prepare", "default_prepare" + HOOK, 1)
    return text + "\nprepare() {\n\tdefault_prepare" + HOOK + "}\n"


def bump_pkgrel(text: str) -> str:
    """Make this package newer than the official binary so pmbootstrap rebuilds."""
    if "sirius overlay: board dts" in text:
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
    text = add_prepare_hook(text)
    path.write_text(text, encoding="utf-8")
    print(f"patched {path}")


if __name__ == "__main__":
    main()
