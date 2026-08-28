// SPDX-License-Identifier: GPL-2.0-only
/*
 * This phone's ABL only accepts the stock Android SoC device tree.
 * Replace it with the mainline Xiaomi Mi 8 SE tree before unflatten.
 */
#define pr_fmt(fmt) "sirius-dt: " fmt

#include <linux/init.h>
#include <linux/libfdt.h>
#include <linux/printk.h>
#include <linux/types.h>

#include <asm/fixmap.h>
#include <asm/memory.h>

extern char __dtb_sdm710_xiaomi_sirius_begin[];

phys_addr_t __init sirius_maybe_replace_fdt(phys_addr_t dt_phys)
{
	int size = 0;
	const void *fw;
	const void *ours = __dtb_sdm710_xiaomi_sirius_begin;
	const char *model;

	if (!dt_phys)
		return dt_phys;

	fw = fixmap_remap_fdt(dt_phys, &size, PAGE_KERNEL);
	if (!fw || fdt_check_header(fw))
		return dt_phys;

	if (!fdt_node_check_compatible(fw, 0, "xiaomi,sirius"))
		return dt_phys;

	if (fdt_node_check_compatible(fw, 0, "qcom,sdm670") &&
	    fdt_node_check_compatible(fw, 0, "qcom,sdm710"))
		return dt_phys;

	if (fdt_check_header(ours))
		return dt_phys;

	model = fdt_getprop(fw, 0, "model", NULL);
	pr_info("replacing firmware dt '%s' with Xiaomi Mi 8 SE board dt\n",
		model ? model : "(no model)");
	return __pa_symbol(__dtb_sdm710_xiaomi_sirius_begin);
}
