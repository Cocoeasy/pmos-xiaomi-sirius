#!/usr/bin/env python3
import struct
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = path.read_bytes()
print("magic", data[0:8])
fields = struct.unpack_from("<9I", data, 8)
names = (
    "kernel_size",
    "kernel_addr",
    "ramdisk_size",
    "ramdisk_addr",
    "second_size",
    "second_addr",
    "tags_addr",
    "page_size",
    "header_version_or_os",
)
for name, value in zip(names, fields):
    if "addr" in name or name.startswith("header"):
        print(f"{name}=0x{value:08x} ({value})")
    else:
        print(f"{name}={value}")
print("name", data[48:64])
print("cmdline", data[64:576].split(b"\x00", 1)[0])
