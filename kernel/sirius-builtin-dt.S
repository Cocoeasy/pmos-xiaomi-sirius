/* SPDX-License-Identifier: GPL-2.0-only */
	.section .rodata,"a"
	.balign	8
	.global	__dtb_sdm710_xiaomi_sirius_begin
__dtb_sdm710_xiaomi_sirius_begin:
	.incbin	"arch/arm64/boot/dts/qcom/sdm710-xiaomi-sirius.dtb"
	.global	__dtb_sdm710_xiaomi_sirius_end
__dtb_sdm710_xiaomi_sirius_end:
	.balign	8
