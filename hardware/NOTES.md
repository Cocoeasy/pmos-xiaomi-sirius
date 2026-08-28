# Hardware notes — Xiaomi Mi 8 SE (`sirius` / `xmsirius`)

**This-unit dump:** not yet. 2026-08-28 开工时电脑上没有授权的 adb/fastboot 设备。  
Windows 里能看到历史「MI 8 SE」节点，当前在位的 USB 不是这台手机。

跑 `scripts/dump-from-phone.ps1` 之后，把「本机值」列填上。没填之前，下面全部来自 **LineageOS `android_kernel_xiaomi_sdm710` lineage-20** 的 GPL 设备树，只能当对照。

参考文件（已镜像到本仓库）：

- `hardware/reference/android-dts/sirius-sdm710.dtsi`
- `hardware/reference/android-dts/xiaomi-sdm710-common.dtsi`
- 上游：https://github.com/LineageOS/android_kernel_xiaomi_sdm710

Wi‑Fi（WCN3990）不在这两份板级 dtsi 里，在 SDM670/710 SoC 公共树 + vendor 固件。

| 项 | 对照值（Lineage，未用本机验证） | 本机值 | 写入 |
|---|---|---|---|
| 对外型号 | Mi 8 SE / M1805E2A | | |
| `ro.product.device` | sirius / xmsirius | | getprop |
| SoC | SDM710 | | |
| 屏幕 | 1080×2244 AMOLED | | deviceinfo 已写 |
| panel | `dsi_ss_fhd_ea8074_cmd`（Samsung EA8074） | | DRM（P4 后） |
| reset / TE | GPIO 75 / GPIO 10 | | |
| 触控 | ST `fts@49`（`st,fts`），IRQ 125，RST 99 | | `modules-initfs` 先别抄 pyxis 的 `edt_ft5x06` |
| 充电 | `&pm660_charger` + `&smb1355`（QC 并联） | | P5 |
| 电量计 | `&pm660_fg`，3120 mAh ATL/Coslight | | P5 |
| USB | `dwc3@a600000`，high-speed | | 调试网；cmdline 里常见 `a600000.dwc3` |
| Wi‑Fi | 预期 WCN3990 / `ath10k_snoc` | | `&wifi` + 本机 `wlanmdsp`/`bdwlan` |
| 音量+ | `pm660l_gpios 7` | | 可选 |
| 指纹 | FPC1020 或 Goodix（GPIO 80/121） | | 非 MVP |

`modules-initfs` 里现在的 `edt_ft5x06` 是抄 pyxis 的，和这台 ST FTS **对不上**。等本机 dump 确认后再改，现在不要为了触控乱加驱动。
