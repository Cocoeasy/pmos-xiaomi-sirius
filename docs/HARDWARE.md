# Hardware dump (do this while Android still boots)

On Windows, with the phone authorized:

```powershell
powershell -File scripts/dump-from-phone.ps1
```

Put raw dumps in `hardware/dump/` (gitignored). Fill `hardware/NOTES.md` after a successful dump.

```text
/proc/cmdline
/sys/firmware/devicetree/base/     # full DT
dmesg                              # search wcn / ath / smb / bq / panel / dsi
```

Wi-Fi / modem blobs (typical vendor paths; names vary by MIUI):

```text
wlanmdsp.mbn
bdwlan.bin   or bdwlan.b*
mba.mbn / modem.mbn / adsp.mbn     # needed later for remoteproc
```

A public dump exists for reference only: [xiaomi_sirius_dump](https://github.com/SakuraKyuo-open-source/xiaomi_sirius_dump). Prefer files from **this** unit.

Closest mainline board: `sdm710-xiaomi-pyxis` (Mi 9 Lite) in [sdm670-mainline](https://gitlab.com/sdm670-mainline/linux). Do not flash the pyxis image onto sirius.
