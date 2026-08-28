#!/system/bin/sh
# Run on-device as root. Copies Wi-Fi / mba blobs to a world-readable tar.
set -e
DST=/data/local/tmp/fw-wifi
rm -rf "$DST" /data/local/tmp/fw-wifi.tgz
mkdir -p "$DST"
cp /vendor/firmware_mnt/image/wlanmdsp.mbn "$DST/"
cp /vendor/firmware_mnt/image/mba.mbn "$DST/"
cp /vendor/firmware_mnt/verinfo/ver_info.txt "$DST/"
cp /vendor/etc/wifi/WCNSS_qcom_cfg.ini "$DST/"
cp /vendor/firmware_mnt/image/bdwlan* "$DST/"
cp /vendor/firmware_mnt/image/bdf_* "$DST/"
ls -la /vendor/firmware_mnt/image > "$DST/firmware_mnt-image.ls.txt"
chmod -R a+r "$DST"
tar czf /data/local/tmp/fw-wifi.tgz -C /data/local/tmp fw-wifi
ls -la /data/local/tmp/fw-wifi.tgz
ls -la "$DST"
