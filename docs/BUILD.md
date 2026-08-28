# Build latest postmarketOS for xiaomi-sirius

## Public GitHub Actions

No WSL required for compile. Three workflows:

| Workflow | Trigger | Time |
|---|---|---|
| **device-package** | every push | ~1–4 min |
| **sirius-dtb** | every push | ~10–20 min |
| **kernel** | Actions → kernel → Run workflow only | 1–3 h, 6 h cap |

Artifacts: Actions run → **Artifacts**. The dtb is real but from a **stub** dts. There is no `boot.img`. See `.github/workflows/`.

## Local Linux / WSL

Windows cannot run [pmbootstrap](https://docs.postmarketos.org/pmbootstrap/main/installation.html) itself. Use WSL2 Ubuntu 24.04 or a real Linux box when you need a kernel/`boot.img`.

This machine did not have a WSL distro when the project was created. In an **admin** PowerShell:

```powershell
wsl --install -d Ubuntu-24.04
```

Reboot if asked, then open Ubuntu and clone/copy this repo to a Linux path (not `H:\` if I/O is painful — `~/src/pmos-xiaomi-sirius` is fine).

## Track edge (latest)

1. `./scripts/bootstrap-wsl.sh` — installs pmbootstrap **from git**, not Debian's frozen package.
2. `pmbootstrap init` — channel **edge**, vendor `xiaomi`, device `sirius`, UI **none**.
3. `./scripts/sync-overlay.sh` — overlays our packages onto pmaports.
4. `pmbootstrap checksum device-xiaomi-sirius`
5. `pmbootstrap build device-xiaomi-sirius`

That is milestone 1: the **device package** compiles against current pmaports.

Full phase list, exit criteria, and Wi-Fi order: [`PLAN.md`](PLAN.md).

## Later milestones

| Step | Command / work |
|---|---|
| Kernel + sirius dtb | Patch `linux-postmarketos-qcom-sdm670`, then `pmbootstrap build linux-postmarketos-qcom-sdm670` (hours) |
| Rootfs image | `pmbootstrap install` after the dtb exists |
| Firmware | Fill `firmware-xiaomi-sirius` from `hardware/firmware/` |
| Wi-Fi | `ath10k_snoc` + this phone's `wlanmdsp`/`bdwlan` (pyxis still has board-2.bin commented out) |

Do not treat `pmbootstrap install` as done until `qcom/sdm710-xiaomi-sirius.dtb` is in the kernel package.
