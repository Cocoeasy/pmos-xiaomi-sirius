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
| 屏幕 | **Samsung EA8074** 命令模式，本机 `wm size` **1080×2244**（`dsi_ss_ea8074_fhd_cmd_display:config2`） | 复位 GPIO 75，TE GPIO 10。共享内核有 EA8076 驱动、没有 EA8074，不能拿 EA8076 来绑 | 简易帧缓冲在 `0x9c000000`；显示子系统未开 |
| 触控 | **ST FTS** `st,fts` @ `i2c 0xa84000`（主线 `i2c9`）addr 0x49，中断 GPIO 125，复位 GPIO 99，固件 `st_fts_v521.ftb` | 不要用对照机的 `edt_ft5x06`。IO 供电 GPIO 26，模拟供电 PM660L L6 | 设备树已写 |
| 充电 | PM660 `qpnp-smb2` + 并联 **SMB1355**（`a88000.i2c` = 主线 `i2c10`）+ `qpnp,fg` | 本机 2026-08-28：`charge_full_design=3120000`，`voltage_max=4400000`，`bms` 类型 `e2_atl`，电量计截止 3400 mV，`parallel` 的 `model_name=smb1355`。主线只开 `&pm660_charger` / `&pm660_fg` / `&pm660_rradc`；共享内核没有 SMB1355 驱动，设备树里不编造该芯片节点 | 设备树已写 PM660；SMB1355 仍不能用 |
| USB | **`a600000.dwc3`**，安卓限 USB2（`maximum-speed = high-speed`），Type-C | **没有** pyxis 那种 TLMM GPIO 38 USB-ID | `&usb_1` / `&usb_1_dwc3` `dr_mode = peripheral`，未接 extcon，也未开 `usb-role-switch`（没有 PM660 Type-C 驱动时会卡住从设备枚举） |
| Type-C / 供电检测 | 本机 `qcom,usb-pdphy@1700`（`qcom,qpnp-pdphy`）+ `qpnp-smb2` 的 `usb-chgpth@1300`（中断名 `type-c-change`） | 供电脚：`vdd-pdphy` = PM660L L7（已有 `vreg_l7b_3p125`），`vbus`/`vconn` = `smb2-vbus`/`smb2-vconn`。本机默认接收能力 5 伏 3 安、9 伏 3 安。共享内核 `TYPEC_QCOM_PMIC` 只认 `pm8150b`，不能拿来绑 PM660 | 设备树写了 `usb-c-connector`；硅片节点不编造 |
| 串口 | `ttyMSM0,115200n8`，earlycon `msm_geni_serial,0xA90000` | 主线节点是 `uart12`（`serial@a90000`），不是 pyxis 的 uart6@898000 | `&uart12` + cmdline |
| 闪存 | 本机 `ufshc@1d84000` 已 ok；现场设备树**没有**复位 GPIO | 供电：PHY L1B+L1A，VCC=PM660L L4 2.96 伏，VCCQ2=**PM660 L8 1.8 伏**（不是对照机的 PM660L L8 3.3 伏） | `&ufs_mem_phy` / `&ufs_mem_hc` 已开 |
| 音量加 | PM660L GPIO 7，低电平有效 | 与对照机相同 | `gpio-keys` 已写 |
| Wi‑Fi 驱动上报 | **`HW:WCN3998`** `FW:2.0.1.13.149.0` | 节点名仍是 `wcn3990`。供电已写入；`&wifi` 和远程处理器保持关闭，等 USB 在真机上枚举 | 供电已写，节点关闭 |
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
