# Kernel work for sirius

Do **not** start a new CAF 4.9 tree. Latest postmarketOS for SDM710 uses:

- package: `linux-postmarketos-qcom-sdm670` in pmaports `device/community/`
- source: https://gitlab.com/sdm670-mainline/linux
- tag example: `sdm670-v6.18.5` (follow whatever pmaports master pins)

pyxis is added as a patch on that shared kernel. Sirius should be the same: one dts + Makefile line, not a fork of the whole kernel package unless you need extra config.

## GitHub compile (no WSL)

- **sirius-dtb**: `scripts/build-sirius-dtb.sh` against the tag pinned by pmaports. Artifact is `sdm710-xiaomi-sirius.dtb`.
- **kernel**: `scripts/inject-sirius-dts.sh` copies the dts into `linux-postmarketos-qcom-sdm670`, then `pmbootstrap build` that package.

`sdm710-xiaomi-sirius.dts` now has reserved-memory, UART, USB2 gadget, PM660 charger, USB-C connector, simple-framebuffer, keys, ST FTS touch, and UFS. Wi-Fi supplies are written; `&wifi` and remoteproc stay disabled. EA8074 / SMB1355 / PM660 PD PHY still have no matching mainline driver. Next step that needs the phone: full kernel package + flashable boot image, boot partition only.

## Local compile (WSL / Linux)

After `scripts/sync-overlay.sh` and, only when building the full kernel package, `scripts/inject-sirius-dts.sh`:

```sh
pmbootstrap checksum linux-postmarketos-qcom-sdm670
pmbootstrap build linux-postmarketos-qcom-sdm670
```

Until board nodes exist, do not `pmbootstrap install` / flash. `pmbootstrap build device-xiaomi-sirius` does not need the dtb.
