# firmware-xiaomi-sirius

Do not commit `*.mbn`, `bdwlan*`, or vendor dumps.

Closest reference: `device/testing/firmware-xiaomi-pyxis` in pmaports. That package currently **does not ship WCN3990 `board-2.bin`** because Wi-Fi init crashed and powered the phone off. Sirius must use **this phone's** `wlanmdsp` + `bdwlan`, not pyxis files.

After you have a dump under `hardware/firmware/`, wire the files into `APKBUILD` the same way pyxis does (`/lib/firmware/qcom/sdm710/sirius/` and later `ath10k/WCN3990/hw1.0/board-2.bin`).
