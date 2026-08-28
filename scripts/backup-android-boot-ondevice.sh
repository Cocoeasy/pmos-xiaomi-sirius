#!/system/bin/sh
# Optional on-device helper. Root on this phone cannot write
# /data/local/tmp or /sdcard; use /data/adb then stream out:
#   adb exec-out su -c 'cat /data/adb/android-boot-backup.tgz'
set -e
DST=/data/adb/android-boot-backup
rm -rf "$DST" /data/adb/android-boot-backup.tgz
mkdir -p "$DST"
for name in boot recovery dtbo; do
	if [ -e "/dev/block/by-name/$name" ]; then
		src=$(readlink -f "/dev/block/by-name/$name")
		echo "$name $src" >> "$DST/map.txt"
		dd if="$src" of="$DST/$name.img" bs=4096
	fi
done
ls -la "$DST" >> "$DST/map.txt"
tar czf /data/adb/android-boot-backup.tgz -C /data/adb android-boot-backup
ls -la /data/adb/android-boot-backup.tgz
