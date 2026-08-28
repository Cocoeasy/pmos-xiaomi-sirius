# pmos-xiaomi-sirius

Independent **postmarketOS edge** port for **Xiaomi Mi 8 SE** (`xiaomi-sirius`, SDM710).

Public overlay repo. The OS is built by [pmbootstrap](https://gitlab.postmarketos.org/postmarketOS/pmbootstrap) against latest [pmaports](https://gitlab.postmarketos.org/postmarketOS/pmaports).

[![device-package](https://github.com/Cocoeasy/pmos-xiaomi-sirius/actions/workflows/device-package.yml/badge.svg)](https://github.com/Cocoeasy/pmos-xiaomi-sirius/actions/workflows/device-package.yml)

## What CI builds

GitHub Actions (public repo, free minutes) builds **`device-xiaomi-sirius` only**. It does **not** compile `linux-postmarketos-qcom-sdm670` and does **not** produce a flashable `boot.img`.

Download the apk from the workflow **Artifacts** tab after a green run.

Roadmap and exit criteria: [`docs/PLAN.md`](docs/PLAN.md). A green device apk is phase 0 only.

## What “latest” means

- **pmbootstrap**: git `master`
- **pmaports**: `edge`
- **kernel** (later, local or a separate job): shared `linux-postmarketos-qcom-sdm670` ([sdm670-mainline](https://gitlab.com/sdm670-mainline/linux)), same as pyxis

Do not put vendor `*.mbn` / `bdwlan*` in this repository.

## Layout

```text
overlay/device/testing/device-xiaomi-sirius/
overlay/device/testing/firmware-xiaomi-sirius/   # empty on purpose
kernel/sdm710-xiaomi-sirius.dts
.github/workflows/device-package.yml
docs/PLAN.md
docs/BUILD.md
docs/HARDWARE.md
```

Closest device package: `device/testing/device-xiaomi-pyxis` in pmaports.
