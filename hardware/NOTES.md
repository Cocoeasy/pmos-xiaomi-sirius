# Hardware notes — Xiaomi Mi 8 SE (`sirius` / `xmsirius`)

**This-unit dump:** 2026-08-28, adb `device:sirius` (unlocked, `verifiedbootstate=orange`).  
Raw files: `hardware/dump/20260828-145534/` (gitignored). No root (`su` missing): `/proc/cmdline` and `/vendor/firmware_mnt` unreadable; cmdline recovered from live DT `chosen/bootargs`.

Do not commit dump files. They include radio identifiers.

| 项 | 本机值（这台） | 对照 / 备注 | 写入 |
|---|---|---|---|
| `ro.product.device` | `sirius` | 不是 xmsirius 字符串 | deviceinfo 已用 `xiaomi-sirius` |
| SoC in DT | `qcom,sdm670-mtp` / model 写 SDM670 + Sirius | 710 在安卓树里常跟 670 一套 | 主线仍用 `sdm710` / `sdm710.dtsi` |
| `qcom,msm-id` | `0x00000168` (360) | SDM670 编号 | |
| `qcom,board-id` | `0x00000020` | | |
| 屏幕 | **Samsung EA8074**（`msm_drm.dsi_display0=dsi_ss_ea8074_fhd_cmd_display:config2`） | DT 里还有 EA8076 等未激活节点 | DRM |
| 触控 | **ST FTS** `st,fts` @ `i2c 0xa84000` addr 0x49，固件 `st_fts_v521.ftb` | 不要用 pyxis 的 `edt_ft5x06` | `modules-initfs` |
| 充电 | PM660 `qpnp-smb2` + **SMB1355** + `qpnp,fg` | dmesg：满电可充，`charge_done` | P5 |
| USB | **`a600000.dwc3`** | 与 getprop / bootargs 一致 | 调试网 |
| 串口 | `ttyMSM0,115200n8`，earlycon `msm_geni_serial,0xA90000` | 2020 帖写的 0xA84000 以本机为准 | deviceinfo / cmdline |
| Wi‑Fi 驱动上报 | **`HW:WCN3998`** `FW:2.0.1.13.149.0` `vendor.wlan.driver.version=5.2.03.32Z` | DT 节点名叫 `bt_wcn3990` / `wcn3990`（399x 一族） | `&wifi` + ath10k_snoc |
| Wi‑Fi 用户态文件 | `/vendor/etc/wifi/WCNSS_qcom_cfg.ini` | `wlan_mac.bin` 链接的 persist 文件不存在 | |
| `wlanmdsp` / `bdwlan` | **未导出**（`firmware_mnt` 无权限） | 公开 dump 指纹同系列：`V12.5.1.0.QEBCNXM` | 有 root 或从 fastboot 包再抽 |
| SELinux | permissive | 已解锁 | |
| 系统 | Android 13 / MIUI V140 移植味；boot 指纹仍带 `QKQ1.190828.002` | 不影响硬件 | |

Live `chosen/bootargs`（本机，已去掉隐私字段后的骨架）：

```text
console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0xA90000
androidboot.hardware=qcom androidboot.console=ttyMSM0
androidboot.usbcontroller=a600000.dwc3
msm_drm.dsi_display0=dsi_ss_ea8074_fhd_cmd_display:config2
androidboot.hwc=CN androidboot.hwversion=2.3.0
```

参考安卓树（GPL，非本机 live 展开）：`hardware/reference/android-dts/`。
