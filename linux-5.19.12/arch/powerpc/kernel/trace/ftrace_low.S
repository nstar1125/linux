/* SPDX-License-Identifier: GPL-2.0-or-later */
/*
 * Split from entry_64.S
 */

#include <linux/magic.h>
#include <asm/ppc_asm.h>
#include <asm/asm-offsets.h>
#include <asm/ftrace.h>
#include <asm/ppc-opcode.h>
#include <asm/export.h>

#ifdef CONFIG_PPC64
.pushsection ".tramp.ftrace.text","aw",@progbits;
.globl ftrace_tramp_text
ftrace_tramp_text:
	.space 64
.popsection

.pushsection ".tramp.ftrace.init","aw",@progbits;
.globl ftrace_tramp_init
ftrace_tramp_init:
	.space 64
.popsection
#endif

_GLOBAL(mcount)
_GLOBAL(_mcount)
EXPORT_SYMBOL(_mcount)
	mflr	r12
	mtctr	r12
	mtlr	r0
	bctr

#ifdef CONFIG_FUNCTION_GRAPH_TRACER
_GLOBAL(return_to_handler)
	/* need to save return values */
#ifdef CONFIG_PPC64
	std	r4,  -32(r1)
	std	r3,  -24(r1)
	/* save TOC */
	std	r2,  -16(r1)
	std	r31, -8(r1)
	mr	r31, r1
	stdu	r1, -112(r1)

	/*
	 * We might be called from a module.
	 * Switch to our TOC to run inside the core kernel.
	 */
	ld	r2, PACATOC(r13)
#else
	stwu	r1, -16(r1)
	stw	r3, 8(r1)
	stw	r4, 12(r1)
#endif

	bl	ftrace_return_to_handler
	nop

	/* return value has real return address */
	mtlr	r3

#ifdef CONFIG_PPC64
	ld	r1, 0(r1)
	ld	r4,  -32(r1)
	ld	r3,  -24(r1)
	ld	r2,  -16(r1)
	ld	r31, -8(r1)
#else
	lwz	r3, 8(r1)
	lwz	r4, 12(r1)
	addi	r1, r1, 16
#endif

	/* Jump back to real return address */
	blr
#endif /* CONFIG_FUNCTION_GRAPH_TRACER */
