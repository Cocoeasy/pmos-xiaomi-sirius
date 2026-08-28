# 小米 8 SE × 最新 postmarketOS — 详细计划

仓库：<https://github.com/Cocoeasy/pmos-xiaomi-sirius>  
设备代号：`xiaomi-sirius`（安卓侧也叫 `xmsirius`）  
SoC：Qualcomm SDM710  
对照机：`xiaomi-pyxis`（Mi 9 Lite），内核包 `linux-postmarketos-qcom-sdm670`

本文是执行计划，不是刷机教程。没写进某阶段「退出标准」的东西，不要当已经做成。

---

## 0. 一句话

在 **postmarketOS edge + 主线 SDM670/710 内核** 上，为这台闲置 8 SE 做整机适配。第一可用目标是：**能反复开机、能充电、能上网**，再谈桌面和授权服。

已经做完的只有：**设备包能在 GitHub Actions 里编过**。还没有内核 dtb，没有 `boot.img`，不能刷。

---

## 1. 目标与非目标

### 要做成（按优先级）

| 优先级 | 目标 | 为什么排这里 |
|---|---|---|
| P0 | 构建链可复现（edge、公开 CI、本机可重编） | 没有这条，后面全是手工垃圾 |
| P1 | 本机硬件档案（DT、cmdline、充电 IC、Wi‑Fi 芯片、本机固件） | 一擦安卓就难对 GPIO |
| P2 | `sdm710-xiaomi-sirius.dtb` 编进共享内核 | 没有它就没有合法 `boot.img` |
| P3 | fastboot 能进系统或至少 USB gadget / 串口有日志 | 否则无法迭代 |
| P4 | 充电稳定（插电 24h 不掉、不烫到关机） | 没充电不能当盒子 |
| P5 | `wlan0` 能连家用 Wi‑Fi，或 USB 共享网可稳定当备用 | 没网就没有隧道 |
| P6 | 无桌面最小用户态，能跑静态二进制 | 授权服是附属，不是适配本身 |

### 明确不做（本计划范围外）

- 不刷 2020 年 thinhx2 的 CAF 4.9 / 实验 zip 当「最新 pmOS」
- 不把 pyxis / 别的 710 机镜像直接刷进 8 SE
- 不在公开仓库提交 `*.mbn`、`bdwlan*`、vendor 分区
- 不把授权服仓库 `proxy_wtsapi32` 和本仓库混在一起
- 不把「设备 apk 编过」写成「整机适配完成」
- 第一阶段不上 GNOME / Phosh；UI 用 `none`
- 相机、扬声器、基带电话不是 MVP

### 和「挂授权服」的关系

授权服要的是 **24h + 出网 + Cloudflare Tunnel**。  
安卓 + Termux 现在就能做。本计划是整机 Linux 移植。两件事可以并行，**不要等 Linux 好了再挂服**。Linux 侧 MVP 达到 P5 之后，再把已编好的 `linux/arm64` `seer-check-server` 拷进去。

---

## 2. 现在已经完成了什么

截止 2026-08-28：

| 项 | 状态 | 证据 |
|---|---|---|
| 独立公开仓库 | 完成 | https://github.com/Cocoeasy/pmos-xiaomi-sirius |
| 设备 overlay | 完成（骨架） | `overlay/device/testing/device-xiaomi-sirius/` |
| 固件包 | 只有空壳 | `firmware-xiaomi-sirius`，无 blob |
| DTS | 只有 stub | `kernel/sdm710-xiaomi-sirius.dts`（`#include "sdm710.dtsi"` + model） |
| CI 编设备包 | **绿** | [run 33148694679](https://github.com/Cocoeasy/pmos-xiaomi-sirius/actions/runs/33148694679)，3m42s |
| 产物 | `device-xiaomi-sirius-0-r0.apk` ≈ 2.8 KB | 只有 deviceinfo / cmdline / mkinitfs 列表 |
| 内核编过 | **未做** | CI 故意不编 `linux-postmarketos-qcom-sdm670` |
| `boot.img` / rootfs | **未做** | `pmbootstrap install` 未跑 |
| 本机 DT / 固件转储 | **部分完成** 2026-08-28 | live DT + dmesg + cmdline(bootargs)；`firmware_mnt` 无 root 未抽 |
| WSL / 本机 Linux | **未装** | 编内核、出镜像必须有 |

CI 里的 Node 20 提示来自旧版 `actions/*@v4`，与 apk 能否编过无关。已改为 `@v5`。

设备包 `depends` 已挂上共享内核和 `soc-qcom`，但 **依赖存在 ≠ 这台机的 dtb 存在**。`deviceinfo_dtb="qcom/sdm710-xiaomi-sirius"` 指向一个内核里还没有的文件。

---

## 3. 约束（做计划时已经算进去）

1. **编译环境必须是 Linux。** Windows 上的 GitHub Actions 只能当「设备包回归」；内核、镜像、刷机在 WSL2 Ubuntu 或真机 Linux。
2. **公开仓库 = Actions 分钟数免费。** 固件 blob 不能进 git。内核 job 单次常 1–3 小时，GitHub 单 job 上限约 6 小时，磁盘紧。
3. **共享内核，不新开 CAF 树。** 上游写法是给 `linux-postmarketos-qcom-sdm670` 加 dts patch（pyxis 就是这样）。
4. **WCN3990 不是 PCI 网卡。** 要 remoteproc（MPSS）+ 本机 `wlanmdsp` + 本机 `bdwlan` + 供电时序。pyxis 的 firmware 包里 **`board-2.bin` 被注释掉**，注释写明：Wi‑Fi init 成功后会崩并导致关机。8 SE 修网至少不比 pyxis 容易。
5. **机器可以砖，但没网仍不是服务器。** 闲置只放开「别当唯一机」。
6. **支付：** 不依赖要 Visa 的云主机。本地 WSL + 公开 Actions 足够走完本计划。

---

## 4. 总路线（一张图）

```text
[安卓还在] 导出 DT / 固件 / dmesg
        │
        ▼
[P0 已完成] 公开仓 + 设备 apk CI
        │
        ▼
[P1] 硬件档案齐  ──►  没有档案不准全盘 format
        │
        ▼
[P2] WSL/Linux + pmbootstrap edge
        │
        ▼
[P3] dts 从 stub → 能编出 sdm710-xiaomi-sirius.dtb
        │
        ▼
[P4] boot.img：能亮或至少 USB/串口有日志
        │
        ├── 失败：改 dts / cmdline / 偏移，只刷 boot，不碰 userdata 直到稳定
        ▼
[P5] 充电
        │
        ▼
[P6] 网络：先 USB 网当调试，再 ath10k_snoc
        │
        ▼
[P7] 最小用户态；可选拷 seer-check-server + cloudflared
        │
        ▼
[P8] 补丁往 sdm670-mainline / pmaports 提，避免内核一升就烂
```

后面阶段可以重叠（例如 P5/P6 交叉），但 **P1 必须在擦机之前**，**P3 必须在 `pmbootstrap install` 之前**。

---

## 5. 分阶段（每阶段都有进入 / 退出标准）

### 阶段 0 — 构建骨架（已完成）

**做了什么**

- 独立仓库，不进 `proxy_wtsapi32`
- overlay 设备包 + 空固件包 + stub dts
- Actions 只编设备包，证明跟得上 edge

**退出标准（已满足）**

- [x] `pmbootstrap build device-xiaomi-sirius` 在 CI 成功
- [x] artifact 为 aarch64 apk，内含 deviceinfo

**不要在这阶段做：** 刷机、编整核、公开固件。

---

### 阶段 1 — 硬件档案（下一件该做的，还不需要 Linux）

**进入标准：** 手机还能进安卓，`adb devices` 能看到。

**要收集（放到 `hardware/dump/`，gitignore）**

1. 整份设备树  
   `/sys/firmware/devicetree/base/` 打 tar，或从 `boot.img` 拆 dtb 再 `dtc -I dtb -O dts`。
2. `/proc/cmdline`、`getprop ro.product.device`、`getprop ro.boot.hardware`
3. `dmesg` 全文；至少检索：`wcn` `ath` `wifi` `wlan` `smb` `bq` `fg` `pmi` `panel` `dsi` `nt36` `ft5` `goodix`
4. 本机固件（路径因 MIUI 而异，按文件名搜）：  
   `wlanmdsp*`、`bdwlan*`、`mba.mbn`、`modem.mbn`、`adsp.mbn`、`cdsp.mbn`
5. 一块「对照表」手填（见第 7 节），以后写 dts 只许改表里对过的节点

**参考（不能代替本机文件）**

- [xiaomi_sirius_dump](https://github.com/SakuraKyuo-open-source/xiaomi_sirius_dump)
- Lineage / SDM710-Development 的 `xmsirius` 安卓树
- pmaports：`device/testing/device-xiaomi-pyxis`、`firmware-xiaomi-pyxis`
- 内核：[sdm670-mainline](https://gitlab.com/sdm670-mainline/linux) 的 `sdm710.dtsi`、`sdm710-xiaomi-pyxis.dts`

**退出标准**

- [ ] `hardware/dump/` 里有完整 dt + cmdline + dmesg
- [ ] 至少能指出：Wi‑Fi 芯片（预期 WCN3990）、充电 IC 名字、panel / 触控名字
- [ ] `wlanmdsp` 与 `bdwlan` 已拷到 `hardware/firmware/`（仍不提交 git）

**失败形态：** 只抄 pyxis 节点开写 dts。结果是假进度，Wi‑Fi/充电必炸。

---

### 阶段 2 — 本机 Linux 编译环境

**进入标准：** 阶段 1 档案已开始拷（不必 100% 齐，但 dt 必须在）。

**要做**

1. 管理员 PowerShell：`wsl --install -d Ubuntu-24.04`，重启
2. 把本仓库放到 Linux 路径（建议 `~/src/pmos-xiaomi-sirius`，避免 `/mnt/h` 又慢又容易 CRLF）
3. `./scripts/bootstrap-wsl.sh`
4. `pmbootstrap init`：channel **edge**，UI **none**，设备先选已有的 `xiaomi-pyxis` 把 pmaports 拉下来
5. `./scripts/sync-overlay.sh`
6. 本机再跑一遍：`pmbootstrap checksum device-xiaomi-sirius && pmbootstrap build device-xiaomi-sirius`  
   与 CI 对上，才说明环境没问题

**退出标准**

- [ ] `pmbootstrap --version` 来自 git，不是 Debian 旧包
- [ ] 本机也能编出 `device-xiaomi-sirius-0-r0.apk`
- [ ] pmaports 在 `~/.local/var/pmbootstrap/cache_git/pmaports`，channel 为 edge

**不要在这阶段做：** 还没 dts 就 `pmbootstrap install`。

---

### 阶段 3 — 内核：让 `sdm710-xiaomi-sirius.dtb` 真实存在

**进入标准：** 阶段 2 通过；手上有安卓 dt 或至少 pyxis dts 全文。

**做法（官方风格，不要新开 `linux-xiaomi-sirius` CAF 包）**

1. 读 pmaports 里 `device/community/linux-postmarketos-qcom-sdm670/APKBUILD` 钉死的 tag（立项时是 `sdm670-v6.18.5`，以当时 master 为准）。
2. 以 `sdm710-xiaomi-pyxis.dts` 为底，按 **本机 dt** 改板级：  
   调节器、GPIO/pinctrl、保留内存、USB、充电、`&wifi` 供电。  
   SoC 公共部分用 `sdm710.dtsi`，不要复制一份 710。
3. 在 `arch/arm64/boot/dts/qcom/Makefile` 加上 `sdm710-xiaomi-sirius.dtb`。
4. 生成 `add-xiaomi-sirius.patch`，放进本仓库 `kernel/patches/`，再同步进本地那份 `linux-postmarketos-qcom-sdm670` 包。
5. 本机：

   ```sh
   pmbootstrap checksum linux-postmarketos-qcom-sdm670
   pmbootstrap build linux-postmarketos-qcom-sdm670
   ```

   预期数小时。第一次不要丢给 GitHub（磁盘和 6 小时上限都紧）。CI 内核 job 等 **本机已经编出 dtb** 再加。

**第一版 dts 允许残缺，但不允许瞎编供电。** 建议节点开关顺序：

1. 空板 + model/compatible（stub 已有）
2. USB gadget / DWC3（调试通道）
3. 充电 / fuel gauge
4. framebuffer 或 DRM panel（可后做，允许无头）
5. `&wifi` + WCN3990 supplies
6. 触控、键、声卡

**退出标准**

- [ ] 内核包里存在 `/boot/dtbs/qcom/sdm710-xiaomi-sirius.dtb`
- [ ] `deviceinfo_dtb` 与这个文件名一致
- [ ] 本仓库能用脚本复现「pmaports 内核包 + sirius patch」

**失败形态：** `pmbootstrap install` 报找不到 dtb；或 dtb 是 pyxis 改名（能装进 boot.img，8 SE 上黑砖）。

---

### 阶段 4 — 第一次出镜像、只刷 boot

**进入标准：** 阶段 3 的 dtb 在本机内核包里。

**要做**

```sh
pmbootstrap config device xiaomi-sirius
pmbootstrap config ui none
pmbootstrap install
pmbootstrap export
```

得到 `boot.img` 和 rootfs 镜像。

刷机原则（闲置机也遵守，减少「不知道卡在哪」）：

- 先只刷 **boot**，root 可以先 USB / 已有分区策略按 pyxis 文档对齐后再动
- 记下 `deviceinfo` 里的 pagesize/offset；与 thinhx2 旧值不一致时，以 **本机安卓 boot 头** 为准，不是以 2020 帖为准
- 每次改 dts 只刷 boot，看有没有：
  - 振动 / 指示灯
  - USB 出网（RNDIS / usbnet）
  - `dmesg`（USB 或 UART）

**退出标准**

- [ ] 至少一种调试通道稳定（USB 网或 serial）
- [ ] 能看到内核日志里 `Machine model: Xiaomi Mi 8 SE`
- [ ] 重启 3 次现象一致

**尚未算成功：** 亮屏、触控、Wi‑Fi。

**失败形态与对策**

| 现象 | 先查 |
|---|---|
| fastboot 成功但立刻回 fastboot | cmdline、dtb 没 append、偏移错 |
| 黑屏无 USB | DWC3 / phy / 调节器 |
| 进内核后 reboot 循环 | 充电/PMIC 写错、看门狗、oops |

---

### 阶段 5 — 充电

**进入标准：** 阶段 4 有日志。

**要做**

- 从本机 dt 对充电 IC、fuel gauge、USB-C 角色切换
- 插电看 `dmesg` 和 `/sys/class/power_supply/`
- 目标：插电电压上升或至少不掉；过热策略不关机

**退出标准**

- [ ] 关机/开机插电都能充
- [ ] 连续插电 2h 不因温度或 PMIC 复位而重启

没有这条，不要进入「挂 24h 服务」。

---

### 阶段 6 — 网络（核心难度）

分两层，不要混在一次提交里。

#### 6A. 调试网（必须先有）

USB 共享电脑网，或暂时保留「电脑 adb/fastboot + 另一台机查资料」。  
没有 6A 就去修 Wi‑Fi，等于盲改。

#### 6B. Wi‑Fi（WCN3990 + `ath10k_snoc`）

按日志往下打勾，不要跳：

| 顺序 | 工作 | 成功时 `dmesg` 大致长这样 |
|---|---|---|
| 1 | dts `&wifi` status okay，四路 supply 对本机 LDO | 不再立刻 `-EPROBE_DEFER` / regulator 失败 |
| 2 | 电源时序（先 VDD_IO）。新内核走 `qcom-wcn` / pwrseq | probe 继续往下走 |
| 3 | MPSS remoteproc + `wlanmdsp`（**本机**文件） | remoteproc 起来后才有 `ath10k_snoc 18800000.wifi` |
| 4 | `board-2.bin` 按 QMI `chip_id` / `board_id` / `qcom,calibration-variant`（例如 `Xiaomi_sirius`）匹配 **本机** `bdwlan` | 不再 `failed to fetch board data` |
| 5 | 出现 `wlan0` | `ip link` 看得到 |
| 6 | iwd 或 wpa_supplicant 连上 AP | 能 ping 网关 |

**禁止：** 把 pyxis 的 `board-2.bin` / `wlanmdsp` 当终态。pyxis 自己都把 Wi‑Fi 校准文件注释掉了。

**固件包**

- 在 `firmware-xiaomi-sirius` 里按 pyxis 的目录习惯安装到  
  `/lib/firmware/qcom/sdm710/sirius/`  
  以及（校准稳定之后）`/lib/firmware/ath10k/WCN3990/hw1.0/`
- blob 用本机文件或你自己的私有盘；公开 CI 只编「无 blob 也能过」的设备包，或用 GitHub secret 私有存储（默认不做，免得把固件传上公网）

**退出标准**

- [ ] `wlan0` 关联家用 AP，重启后还能起来  
  **或** 明确记录「Wi‑Fi 卡在第几步 + 完整 dmesg」，USB 网可稳定当 MVP 出网

**失败形态**

- firmware crash / caldb assert：用了错的 `bdwlan` 或错的 `wlanmdsp`
- 起来后关机：与 pyxis 相同的坑，先别上 24h
- 有网卡扫不到 AP：天线/校准，不是「再装一个 NetworkManager」

---

### 阶段 7 — 最小用户态（可选挂授权服）

**进入标准：** P4 稳定；P5 通过；P6 至少有一种出网。

**要做**

- 继续 UI `none`，不要上桌面
- OpenRC/systemd 只跑你需要的：ssh、iwd 或 usbnet、以后的 tunnel
- 交叉编译已有：`GOOS=linux GOARCH=arm64 CGO_ENABLED=0` 的 `seer-check-server`
- 听 `127.0.0.1:18080`；公网走 Cloudflare Tunnel（token 不进 git）
- 本机 SQLite，路径在家目录，不要抄 CentOS 的 `/opt`

**退出标准**

- [ ] 重启后进程还在，隧道还在（或有明确的开机脚本）
- [ ] `GET /health` 经隧道可访问
- [ ] 管理后台密码已改；Access 保护 `/admin`，放行三个 patch API

这一阶段才回到 `proxy_wtsapi32` 的 DLL / `SEER_SERVER_HOST`。隧道不稳之前不要改 DLL。

---

### 阶段 8 — 上游化

**进入标准：** dts 在这台机上开机 + 充电可用；Wi‑Fi 至少不导致关机。

**要做**

- dts 往 [sdm670-mainline](https://gitlab.com/sdm670-mainline/linux) 提
- 设备包 / 固件包（无 blob 或按 pmOS 固件政策）往 pmaports `device/testing/` 提
- 共享内核包加 `add-xiaomi-sirius.patch`，与 pyxis 并列

**退出标准：** 别人只 `pmbootstrap init` 选 `xiaomi-sirius` 就能编，不必再 git clone 本 overlay。

2020 年帖子死掉，就是因为没走完这一步。

---

## 6. CI 和本机怎么分工

| 工作 | 在哪跑 | 原因 |
|---|---|---|
| `device-xiaomi-sirius` apk | GitHub Actions（已有） | 快、免费、验证 overlay 没跟丢 edge |
| 内核 + dtb | **GitHub Actions**（`sirius-dtb` / `kernel`） | 无 WSL；dtb 每次 push；整核手动或改 `kernel/` 才跑 |
| `pmbootstrap install` | 本机或以后再加 job | CI 做出内核 apk ≠ 可刷 `boot.img` |
| 刷机、dmesg、修网 | 实机 | Actions 没有这台 8 SE |

公开仓库继续禁止 blob。CI 红了先看是 pmaports 接口变了，还是 overlay 写错。

---

## 7. 硬件对照表（阶段 1 填，阶段 3/6 用）

把结果记在 `hardware/NOTES.md`（可以提交；blob 路径只写文件名不写内容）。

| 项 | 本机值 | 来源 | 写入 dts / 固件的位置 |
|---|---|---|---|
| `ro.product.device` | | getprop | 确认是 sirius / xmsirius |
| cmdline | | /proc/cmdline | 与 deviceinfo / boot 头交叉 |
| boot pagesize / offsets | | 拆本机 boot.img | `deviceinfo_flash_*` |
| panel | | dt / dmesg | DRM 节点（P4 后） |
| 触控 | | dt / dmesg | `modules-initfs` |
| 充电 IC | | dt / dmesg | 充电节点（P5） |
| fuel gauge | | dt | 电量（P5） |
| Wi‑Fi | 预期 WCN3990 | dt / dmesg | `&wifi` |
| Wi‑Fi LDO 四路 | | 安卓 dt regulator | vdd-0.8-cx-mx 等 |
| QMI board_id / chip_id | 等 ath10k probe 后 | dmesg | `board-2.bin` 条目 |
| `wlanmdsp` 文件名 | | vendor | firmware 包 |
| `bdwlan*` 文件名 | | vendor | firmware 包 |
| USB DWC3 基址 | | dt / 710 公共 | 调试网 |

---

## 8. 风险

| 风险 | 影响 | 对策 |
|---|---|---|
| 没导出 dt 就 format | 后面全靠猜 | 阶段 1 卡死 |
| 用 pyxis dtb 改名 | 黑屏/损坏外设 | 文件名可以先占位，内容必须是 sirius |
| 公开仓误传固件 | 许可 / 仓库被打 | `.gitignore`；CI 不打包 `hardware/firmware` |
| pyxis 同款 Wi‑Fi 关机 | 不能 24h | 先 USB 网；校准文件不上线直到稳定 |
| 内核 CI 超时 | 假失败 | 本机先绿再加 job |
| `deviceinfo` 偏移抄错 | 只进 fastboot | 对 **本机** boot 头 |
| 把设备 apk 当系统 | 预期错乱 | apk ≠ 镜像 |
| 授权服和移植绑死 | 两边都完不成 | Termux 先挂服 |

---

## 9. 时间（有对照、机器可砖、每天能摸几小时）

粗估，不是承诺：

| 阶段 | 量级 |
|---|---|
| P1 档案 | 半天（卡在没 root / 没 adb 就更久） |
| P2 环境 | 半天（含 WSL 重启） |
| P3 第一颗 dtb | 数天（含一次完整内核编译） |
| P4 第一次有日志 | 数天到两周 |
| P5 充电 | 数天 |
| P6 Wi‑Fi | 一周到数周，可能长期停在「USB 网可用」 |
| P7 用户态 + 隧道 | 有网之后 1–2 天 |
| P8 上游 | 并行，不挡自己用 |

---

## 10. 现在立刻做的三件事（按顺序）

1. **安卓还在：导出 DT + cmdline + dmesg + wlan/充电相关固件** 到 `hardware/dump/`（见 `docs/HARDWARE.md`）。  
   不需要 WSL，不需要再等 CI。
2. **装 WSL2 Ubuntu 24.04**，本机复现设备包构建（阶段 2）。
3. **对照 pyxis dts + 本机 dt，开始改 `kernel/sdm710-xiaomi-sirius.dts`**（阶段 3）。  
   在 dtb 编出来之前，不要 `pmbootstrap install`，不要刷机。

编译走 GitHub Actions：`sirius-dtb` 每次 push；整核用 Actions → **kernel** → Run workflow。做出的是 stub dtb / 内核 apk，不要刷。

---

## 11. 文档怎么读

| 文件 | 用途 |
|---|---|
| 本文件 `docs/PLAN.md` | 阶段、验收、顺序 |
| `docs/BUILD.md` | 怎么编 |
| `docs/HARDWARE.md` | 从手机拷什么 |
| `kernel/README.md` | 内核补丁怎么挂 |
| `overlay/.../firmware-xiaomi-sirius/README.md` | 为什么不能抄 pyxis 校准文件 |
