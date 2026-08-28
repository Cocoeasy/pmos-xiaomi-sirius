#!/system/bin/sh
# Run on-device as root. Prints reserved-memory regs and qusb supplies.
base=/sys/firmware/devicetree/base
echo "==== RESERVED REGS ===="
for d in "$base/reserved-memory"/*; do
	[ -d "$d" ] || continue
	name=$(basename "$d")
	if [ -f "$d/reg" ]; then
		echo -n "$name "
		od -An -tx1 "$d/reg" | tr -s ' ' | head -c 80
		echo
	fi
done
echo "==== QUSB PROPS ===="
ls "$base/soc/qusb@88e2000"
for f in "$base/soc/qusb@88e2000"/*; do
	[ -f "$f" ] || continue
	bn=$(basename "$f")
	echo -n "$bn: "
	od -An -tx1 "$f" | tr -s ' ' | head -c 100
	echo
done
echo "==== SSUSB SUPPLY NAMES ===="
ls "$base/soc/ssusb@a600000" | grep -i supply
echo "==== UART A90000 ===="
find "$base/soc" -maxdepth 2 -iname '*a90000*' -o -iname '*serial@a90000*'
