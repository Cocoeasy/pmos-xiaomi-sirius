# Hardware notes — Xiaomi Mi 8 SE (`sirius` / `xmsirius`)

**This-unit dump:** 2026-08-28, adb `device:sirius` (unlocked, `verifiedbootstate=orange`).  
Raw files: `hardware/dump/20260828-145534/` (DT/dmesg) and `hardware/dump/20260828-152607-firmware/` + `hardware/firmware/` (gitignored). Root via SukiSU (`su` uid=0). `/proc/cmdline` readable; do not paste serial/cpuid from it.

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
| USB | **`a600000.dwc3`**，安卓限 USB2（`maximum-speed = high-speed`），Type-C + PM660 `usb-pdphy@1700` | **没有** pyxis 那种 TLMM GPIO 38 USB-ID | `&usb_1` / `&usb_1_dwc3` `dr_mode = peripheral`，未接 extcon |
| 串口 | `ttyMSM0,115200n8`，earlycon `msm_geni_serial,0xA90000` | 主线节点是 `uart12`（`serial@a90000`），不是 pyxis 的 uart6@898000 | `&uart12` + cmdline |
| Wi‑Fi 驱动上报 | **`HW:WCN3998`** `FW:2.0.1.13.149.0` `vendor.wlan.driver.version=5.2.03.32Z` | DT 节点名叫 `bt_wcn3990` / `wcn3990`（399x 一族） | `&wifi` + ath10k_snoc |
| Wi‑Fi 用户态文件 | `/vendor/etc/wifi/WCNSS_qcom_cfg.ini` | `wlan_mac.bin` 链接的 persist 文件不存在 | |
| `wlanmdsp` / `bdwlan` | 已从本机 `/vendor/firmware_mnt/image` 导出：`wlanmdsp.mbn` 3044628 B（SHA256 `2289BEB1…E9DE1BD8`）；`bdwlan.bin` 26328 B + 30 个 `bdwlan.*`；`mba.mbn` 238304 B | 元信息 `WLAN.HL.2.0.1-00831-QCAHLSWMTPLZ-1`，modem `MPSS.AT.4.0.2-00572-SDM710_GEN_PACK-1`（2021-04-22）。`wlan_mac.bin` 仍不存在 | `hardware/firmware/`（勿提交）。modem/adsp 分段未整包拉 |
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

本机安卓 `boot` 文件头（`mmcblk0p70`，2026-08-28）：`page_size=4096`，`kernel_addr=0x00008000`，`ramdisk_addr=0x01000000`，`tags_addr=0x00000100`。与现有 `deviceinfo_flash_*` 一致，刷第一版启动镜像前不必改偏移。

保留内存与 pyxis **不完全相同**（例如 `removed_region` 长度 `0x2f40000`，mba/adsp/ipa 基址不同）。设备树必须用本机 live 值，见 `kernel/sdm710-xiaomi-sirius.dts`。

参考安卓树（GPL，非本机 live 展开）：`hardware/reference/android-dts/`。
