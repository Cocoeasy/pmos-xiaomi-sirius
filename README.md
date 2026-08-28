# pmos-xiaomi-sirius

Independent **postmarketOS edge** port for **Xiaomi Mi 8 SE** (`xiaomi-sirius`, SDM710).

Public overlay repo. The OS is built by [pmbootstrap](https://gitlab.postmarketos.org/postmarketOS/pmbootstrap) against latest [pmaports](https://gitlab.postmarketos.org/postmarketOS/pmaports).

[![device-package](https://github.com/Cocoeasy/pmos-xiaomi-sirius/actions/workflows/device-package.yml/badge.svg)](https://github.com/Cocoeasy/pmos-xiaomi-sirius/actions/workflows/device-package.yml)

## What CI builds

| Workflow | What you get | Flashable? |
|---|---|---|
| **device-package** | `device-xiaomi-sirius` apk (~3 KB deviceinfo) | No |
| **sirius-dtb** | `sdm710-xiaomi-sirius.dtb` from the stub dts | No |
| **kernel** | 整颗 `linux-postmarketos-qcom-sdm670` 软件包（手动点 Run workflow） | 否（没有可刷写的启动镜像） |

Download artifacts from the workflow **Artifacts** tab. The dtb/kernel jobs exist so you do not need WSL just to compile. Do **not** flash them until USB and charger nodes are filled.

Roadmap: [`docs/PLAN.md`](docs/PLAN.md).

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
