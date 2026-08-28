# Kernel work for sirius

Do **not** start a new CAF 4.9 tree. Latest postmarketOS for SDM710 uses:

- package: `linux-postmarketos-qcom-sdm670` in pmaports `device/community/`
- source: https://gitlab.com/sdm670-mainline/linux
- tag example: `sdm670-v6.18.5` (follow whatever pmaports master pins)

pyxis is added as a patch on that shared kernel. Sirius should be the same: one dts + Makefile line, not a fork of the whole kernel package unless you need extra config.

## GitHub compile (no WSL)

- **sirius-dtb**: `scripts/build-sirius-dtb.sh` against the tag pinned by pmaports. Artifact is `sdm710-xiaomi-sirius.dtb`.
- **kernel**: `scripts/inject-sirius-dts.sh` copies the dts into `linux-postmarketos-qcom-sdm670`, then `pmbootstrap build` that package.

`sdm710-xiaomi-sirius.dts` now has reserved-memory, UART, USB2 gadget, PM660 charger, USB-C connector, simple-framebuffer, keys, UFS, PM660 haptics, a disabled ST FTS node, and a disabled Samsung EA8074 panel (1080×2244, this phone's init). The first kernel job injects the device-tree source only. The EA8074 and TAS2557 C files stay local until USB enumerates. Wi-Fi, remoteproc, MDSS, and DSI stay off. Do not re-add Android's coarse `removed@85fc0000` hole on top of cmd-db/smem. Android boot backup: `scripts/backup-android-boot.ps1`. Flash Linux with `scripts/flash-linux-boot.ps1`. Roll back with `scripts/restore-android-boot.ps1`. Do not enable the panel or flip `deviceinfo_drm` until USB enumerates.

## Local compile (WSL / Linux)

After `scripts/sync-overlay.sh` and, only when building the full kernel package, `scripts/inject-sirius-dts.sh`:

```sh
pmbootstrap checksum linux-postmarketos-qcom-sdm670
pmbootstrap build linux-postmarketos-qcom-sdm670
```

Until board nodes exist, do not `pmbootstrap install` / flash. `pmbootstrap build device-xiaomi-sirius` does not need the dtb.
