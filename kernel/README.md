# Kernel work for sirius

Do **not** start a new CAF 4.9 tree. Latest postmarketOS for SDM710 uses:

- package: `linux-postmarketos-qcom-sdm670` in pmaports `device/community/`
- source: https://gitlab.com/sdm670-mainline/linux
- tag example: `sdm670-v6.18.5` (follow whatever pmaports master pins)

pyxis is added as a patch on that shared kernel. Sirius should be the same: one dts + Makefile line, not a fork of the whole kernel package unless you need extra config.

## First kernel compile

On Linux/WSL, after `scripts/sync-overlay.sh`:

```sh
# optional: copy sdm710-xiaomi-sirius.dts into a local clone of
# linux-postmarketos-qcom-sdm670 and add it to the Makefile, then:
pmbootstrap checksum linux-postmarketos-qcom-sdm670
pmbootstrap build linux-postmarketos-qcom-sdm670
```

Until that dtb exists, `pmbootstrap install` cannot produce a correct `boot.img` for this phone. `pmbootstrap build device-xiaomi-sirius` does not need the dtb yet.
