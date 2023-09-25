	.file	"normal-preflow.c"
	.text
	.local	progname
	.comm	progname,8,8
	.section	.rodata
.LC0:
	.string	"%s: "
.LC1:
	.string	"error: %s\n"
	.text
	.globl	error
	.type	error, @function
error:
.LFB6:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$240, %rsp
	movq	%rdi, -8424(%rbp)
	movq	%rsi, -168(%rbp)
	movq	%rdx, -160(%rbp)
	movq	%rcx, -152(%rbp)
	movq	%r8, -144(%rbp)
	movq	%r9, -136(%rbp)
	testb	%al, %al
	je	.L2
	movaps	%xmm0, -128(%rbp)
	movaps	%xmm1, -112(%rbp)
	movaps	%xmm2, -96(%rbp)
	movaps	%xmm3, -80(%rbp)
	movaps	%xmm4, -64(%rbp)
	movaps	%xmm5, -48(%rbp)
	movaps	%xmm6, -32(%rbp)
	movaps	%xmm7, -16(%rbp)
.L2:
	movq	%fs:40, %rax
	movq	%rax, -184(%rbp)
	xorl	%eax, %eax
	movl	$8, -8408(%rbp)
	movl	$48, -8404(%rbp)
	leaq	16(%rbp), %rax
	movq	%rax, -8400(%rbp)
	leaq	-176(%rbp), %rax
	movq	%rax, -8392(%rbp)
	leaq	-8408(%rbp), %rdx
	movq	-8424(%rbp), %rcx
	leaq	-8384(%rbp), %rax
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	vsprintf@PLT
	movq	progname(%rip), %rax
	testq	%rax, %rax
	je	.L3
	movq	progname(%rip), %rdx
	movq	stderr(%rip), %rax
	leaq	.LC0(%rip), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf@PLT
.L3:
	movq	stderr(%rip), %rax
	leaq	-8384(%rbp), %rdx
	leaq	.LC1(%rip), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf@PLT
	movl	$1, %edi
	call	exit@PLT
	.cfi_endproc
.LFE6:
	.size	error, .-error
	.type	next_int, @function
next_int:
.LFB7:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$24, %rsp
	.cfi_offset 3, -24
	movl	$0, -24(%rbp)
	jmp	.L6
.L7:
	movl	-24(%rbp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	addl	%eax, %eax
	movl	%eax, %edx
	movl	-20(%rbp), %eax
	addl	%edx, %eax
	subl	$48, %eax
	movl	%eax, -24(%rbp)
.L6:
	call	__ctype_b_loc@PLT
	movq	(%rax), %rbx
	call	getchar@PLT
	movl	%eax, -20(%rbp)
	movl	-20(%rbp), %eax
	cltq
	addq	%rax, %rax
	addq	%rbx, %rax
	movzwl	(%rax), %eax
	movzwl	%ax, %eax
	andl	$2048, %eax
	testl	%eax, %eax
	jne	.L7
	movl	-24(%rbp), %eax
	movq	-8(%rbp), %rbx
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	next_int, .-next_int
	.section	.rodata
	.align 8
.LC2:
	.string	"out of memory: malloc(%zu) failed"
	.text
	.type	xmalloc, @function
xmalloc:
.LFB8:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	malloc@PLT
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jne	.L10
	movq	-24(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC2(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	error
.L10:
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	xmalloc, .-xmalloc
	.type	xcalloc, @function
xcalloc:
.LFB9:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	-24(%rbp), %rax
	imulq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	xmalloc
	movq	%rax, -8(%rbp)
	movq	-24(%rbp), %rax
	imulq	-32(%rbp), %rax
	movq	%rax, %rdx
	movq	-8(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	memset@PLT
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	xcalloc, .-xcalloc
	.type	add_edge, @function
add_edge:
.LFB10:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movl	$16, %edi
	call	xmalloc
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	-32(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	-24(%rbp), %rax
	movq	8(%rax), %rdx
	movq	-8(%rbp), %rax
	movq	%rdx, 8(%rax)
	movq	-24(%rbp), %rax
	movq	-8(%rbp), %rdx
	movq	%rdx, 8(%rax)
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	add_edge, .-add_edge
	.type	connect, @function
connect:
.LFB11:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movl	%edx, -20(%rbp)
	movq	%rcx, -32(%rbp)
	movq	-32(%rbp), %rax
	movq	-8(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	-32(%rbp), %rax
	movq	-16(%rbp), %rdx
	movq	%rdx, 8(%rax)
	movq	-32(%rbp), %rax
	movl	-20(%rbp), %edx
	movl	%edx, 20(%rax)
	movq	-32(%rbp), %rdx
	movq	-8(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	add_edge
	movq	-32(%rbp), %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	add_edge
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	connect, .-connect
	.type	new_graph, @function
new_graph:
.LFB12:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movq	%rdi, -56(%rbp)
	movl	%esi, -60(%rbp)
	movl	%edx, -64(%rbp)
	movl	$48, %edi
	call	xmalloc
	movq	%rax, -24(%rbp)
	movq	-24(%rbp), %rax
	movl	-60(%rbp), %edx
	movl	%edx, (%rax)
	movq	-24(%rbp), %rax
	movl	-64(%rbp), %edx
	movl	%edx, 4(%rax)
	movl	-60(%rbp), %eax
	cltq
	movl	$24, %esi
	movq	%rax, %rdi
	call	xcalloc
	movq	-24(%rbp), %rdx
	movq	%rax, 8(%rdx)
	movl	-64(%rbp), %eax
	cltq
	movl	$24, %esi
	movq	%rax, %rdi
	call	xcalloc
	movq	-24(%rbp), %rdx
	movq	%rax, 16(%rdx)
	movq	-24(%rbp), %rax
	movq	8(%rax), %rdx
	movq	-24(%rbp), %rax
	movq	%rdx, 24(%rax)
	movq	-24(%rbp), %rax
	movq	8(%rax), %rcx
	movl	-60(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	subq	$24, %rax
	leaq	(%rcx,%rax), %rdx
	movq	-24(%rbp), %rax
	movq	%rdx, 32(%rax)
	movq	-24(%rbp), %rax
	movq	$0, 40(%rax)
	movl	$0, -40(%rbp)
	jmp	.L17
.L18:
	movl	$0, %eax
	call	next_int
	movl	%eax, -36(%rbp)
	movl	$0, %eax
	call	next_int
	movl	%eax, -32(%rbp)
	movl	$0, %eax
	call	next_int
	movl	%eax, -28(%rbp)
	movq	-24(%rbp), %rax
	movq	8(%rax), %rcx
	movl	-36(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rcx, %rax
	movq	%rax, -16(%rbp)
	movq	-24(%rbp), %rax
	movq	8(%rax), %rcx
	movl	-32(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rcx, %rax
	movq	%rax, -8(%rbp)
	movq	-24(%rbp), %rax
	movq	16(%rax), %rcx
	movl	-40(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rax, %rcx
	movl	-28(%rbp), %edx
	movq	-8(%rbp), %rsi
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	connect
	addl	$1, -40(%rbp)
.L17:
	movl	-40(%rbp), %eax
	cmpl	-64(%rbp), %eax
	jl	.L18
	movq	-24(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	new_graph, .-new_graph
	.type	enter_excess, @function
enter_excess:
.LFB13:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	-8(%rbp), %rax
	movq	32(%rax), %rax
	cmpq	%rax, -16(%rbp)
	je	.L22
	movq	-8(%rbp), %rax
	movq	24(%rax), %rax
	cmpq	%rax, -16(%rbp)
	je	.L22
	movq	-8(%rbp), %rax
	movq	40(%rax), %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, 16(%rax)
	movq	-8(%rbp), %rax
	movq	-16(%rbp), %rdx
	movq	%rdx, 40(%rax)
.L22:
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	enter_excess, .-enter_excess
	.type	leave_excess, @function
leave_excess:
.LFB14:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	movq	-24(%rbp), %rax
	movq	40(%rax), %rax
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je	.L24
	movq	-8(%rbp), %rax
	movq	16(%rax), %rdx
	movq	-24(%rbp), %rax
	movq	%rdx, 40(%rax)
.L24:
	movq	-8(%rbp), %rax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	leave_excess, .-leave_excess
	.section	.rodata
.LC3:
	.string	"normal-preflow.c"
.LC4:
	.string	"d >= 0"
.LC5:
	.string	"u->e >= 0"
.LC6:
	.string	"abs(e->f) <= e->c"
	.text
	.type	push, @function
push:
.LFB15:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	%rdx, -40(%rbp)
	movq	%rcx, -48(%rbp)
	movl	$0, -8(%rbp)
	movq	-48(%rbp), %rax
	movq	(%rax), %rax
	cmpq	%rax, -32(%rbp)
	jne	.L27
	movq	-32(%rbp), %rax
	movl	4(%rax), %eax
	movq	-48(%rbp), %rdx
	movl	20(%rdx), %ecx
	movq	-48(%rbp), %rdx
	movl	16(%rdx), %esi
	subl	%esi, %ecx
	movl	%ecx, %edx
	cmpl	%edx, %eax
	cmovg	%edx, %eax
	movl	%eax, -4(%rbp)
	movq	-48(%rbp), %rax
	movl	16(%rax), %edx
	movl	-4(%rbp), %eax
	addl	%eax, %edx
	movq	-48(%rbp), %rax
	movl	%edx, 16(%rax)
	jmp	.L28
.L27:
	movq	-32(%rbp), %rax
	movl	4(%rax), %eax
	movq	-48(%rbp), %rdx
	movl	20(%rdx), %ecx
	movq	-48(%rbp), %rdx
	movl	16(%rdx), %edx
	addl	%ecx, %edx
	cmpl	%edx, %eax
	cmovg	%edx, %eax
	movl	%eax, -4(%rbp)
	movq	-48(%rbp), %rax
	movl	16(%rax), %eax
	subl	-4(%rbp), %eax
	movl	%eax, %edx
	movq	-48(%rbp), %rax
	movl	%edx, 16(%rax)
.L28:
	movq	-32(%rbp), %rax
	movl	4(%rax), %eax
	subl	-4(%rbp), %eax
	movl	%eax, %edx
	movq	-32(%rbp), %rax
	movl	%edx, 4(%rax)
	movq	-40(%rbp), %rax
	movl	4(%rax), %edx
	movl	-4(%rbp), %eax
	addl	%eax, %edx
	movq	-40(%rbp), %rax
	movl	%edx, 4(%rax)
	cmpl	$0, -4(%rbp)
	jns	.L29
	leaq	__PRETTY_FUNCTION__.0(%rip), %rax
	movq	%rax, %rcx
	movl	$388, %edx
	leaq	.LC3(%rip), %rax
	movq	%rax, %rsi
	leaq	.LC4(%rip), %rax
	movq	%rax, %rdi
	call	__assert_fail@PLT
.L29:
	movq	-32(%rbp), %rax
	movl	4(%rax), %eax
	testl	%eax, %eax
	jns	.L30
	leaq	__PRETTY_FUNCTION__.0(%rip), %rax
	movq	%rax, %rcx
	movl	$389, %edx
	leaq	.LC3(%rip), %rax
	movq	%rax, %rsi
	leaq	.LC5(%rip), %rax
	movq	%rax, %rdi
	call	__assert_fail@PLT
.L30:
	movq	-48(%rbp), %rax
	movl	16(%rax), %eax
	movl	%eax, %edx
	negl	%edx
	cmovs	%eax, %edx
	movq	-48(%rbp), %rax
	movl	20(%rax), %eax
	cmpl	%eax, %edx
	jle	.L31
	leaq	__PRETTY_FUNCTION__.0(%rip), %rax
	movq	%rax, %rcx
	movl	$390, %edx
	leaq	.LC3(%rip), %rax
	movq	%rax, %rsi
	leaq	.LC6(%rip), %rax
	movq	%rax, %rdi
	call	__assert_fail@PLT
.L31:
	movq	-32(%rbp), %rax
	movl	4(%rax), %eax
	testl	%eax, %eax
	jle	.L32
	movq	-32(%rbp), %rdx
	movq	-24(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	enter_excess
.L32:
	movq	-40(%rbp), %rax
	movl	4(%rax), %eax
	cmpl	%eax, -4(%rbp)
	jne	.L34
	movq	-40(%rbp), %rdx
	movq	-24(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	enter_excess
.L34:
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE15:
	.size	push, .-push
	.type	relabel, @function
relabel:
.LFB16:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	-16(%rbp), %rax
	movl	(%rax), %eax
	leal	1(%rax), %edx
	movq	-16(%rbp), %rax
	movl	%edx, (%rax)
	movq	-16(%rbp), %rdx
	movq	-8(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	enter_excess
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE16:
	.size	relabel, .-relabel
	.type	other, @function
other:
.LFB17:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	-16(%rbp), %rax
	movq	(%rax), %rax
	cmpq	%rax, -8(%rbp)
	jne	.L37
	movq	-16(%rbp), %rax
	movq	8(%rax), %rax
	jmp	.L38
.L37:
	movq	-16(%rbp), %rax
	movq	(%rax), %rax
.L38:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE17:
	.size	other, .-other
	.globl	preflow
	.type	preflow, @function
preflow:
.LFB18:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movq	%rdi, -56(%rbp)
	movq	-56(%rbp), %rax
	movq	24(%rax), %rax
	movq	%rax, -16(%rbp)
	movq	-56(%rbp), %rax
	movl	(%rax), %edx
	movq	-16(%rbp), %rax
	movl	%edx, (%rax)
	movq	-16(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, -24(%rbp)
	jmp	.L40
.L41:
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, -32(%rbp)
	movq	-24(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, -24(%rbp)
	movq	-16(%rbp), %rax
	movl	4(%rax), %edx
	movq	-32(%rbp), %rax
	movl	20(%rax), %eax
	addl	%eax, %edx
	movq	-16(%rbp), %rax
	movl	%edx, 4(%rax)
	movq	-32(%rbp), %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	other
	movq	%rax, %rdi
	movq	-32(%rbp), %rdx
	movq	-16(%rbp), %rsi
	movq	-56(%rbp), %rax
	movq	%rdx, %rcx
	movq	%rdi, %rdx
	movq	%rax, %rdi
	call	push
.L40:
	cmpq	$0, -24(%rbp)
	jne	.L41
	jmp	.L42
.L50:
	movq	$0, -40(%rbp)
	movq	-8(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, -24(%rbp)
	jmp	.L43
.L48:
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, -32(%rbp)
	movq	-24(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, -24(%rbp)
	movq	-32(%rbp), %rax
	movq	(%rax), %rax
	cmpq	%rax, -8(%rbp)
	jne	.L44
	movq	-32(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, -40(%rbp)
	movl	$1, -44(%rbp)
	jmp	.L45
.L44:
	movq	-32(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, -40(%rbp)
	movl	$-1, -44(%rbp)
.L45:
	movq	-8(%rbp), %rax
	movl	(%rax), %edx
	movq	-40(%rbp), %rax
	movl	(%rax), %eax
	cmpl	%eax, %edx
	jle	.L46
	movq	-32(%rbp), %rax
	movl	16(%rax), %eax
	imull	-44(%rbp), %eax
	movl	%eax, %edx
	movq	-32(%rbp), %rax
	movl	20(%rax), %eax
	cmpl	%eax, %edx
	jl	.L47
.L46:
	movq	$0, -40(%rbp)
.L43:
	cmpq	$0, -24(%rbp)
	jne	.L48
.L47:
	cmpq	$0, -40(%rbp)
	je	.L49
	movq	-32(%rbp), %rcx
	movq	-40(%rbp), %rdx
	movq	-8(%rbp), %rsi
	movq	-56(%rbp), %rax
	movq	%rax, %rdi
	call	push
	jmp	.L42
.L49:
	movq	-8(%rbp), %rdx
	movq	-56(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	relabel
.L42:
	movq	-56(%rbp), %rax
	movq	%rax, %rdi
	call	leave_excess
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jne	.L50
	movq	-56(%rbp), %rax
	movq	32(%rax), %rax
	movl	4(%rax), %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE18:
	.size	preflow, .-preflow
	.type	free_graph, @function
free_graph:
.LFB19:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	movl	$0, -20(%rbp)
	jmp	.L53
.L56:
	movq	-40(%rbp), %rax
	movq	8(%rax), %rcx
	movl	-20(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rcx, %rax
	movq	8(%rax), %rax
	movq	%rax, -16(%rbp)
	jmp	.L54
.L55:
	movq	-16(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, -8(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	movq	-8(%rbp), %rax
	movq	%rax, -16(%rbp)
.L54:
	cmpq	$0, -16(%rbp)
	jne	.L55
	addl	$1, -20(%rbp)
.L53:
	movq	-40(%rbp), %rax
	movl	(%rax), %eax
	cmpl	%eax, -20(%rbp)
	jl	.L56
	movq	-40(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, %rdi
	call	free@PLT
	movq	-40(%rbp), %rax
	movq	16(%rax), %rax
	movq	%rax, %rdi
	call	free@PLT
	movq	-40(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE19:
	.size	free_graph, .-free_graph
	.section	.rodata
.LC7:
	.string	"f = %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB20:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movl	%edi, -36(%rbp)
	movq	%rsi, -48(%rbp)
	movq	-48(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, progname(%rip)
	movq	stdin(%rip), %rax
	movq	%rax, -16(%rbp)
	movl	$0, %eax
	call	next_int
	movl	%eax, -28(%rbp)
	movl	$0, %eax
	call	next_int
	movl	%eax, -24(%rbp)
	movl	$0, %eax
	call	next_int
	movl	$0, %eax
	call	next_int
	movl	-24(%rbp), %edx
	movl	-28(%rbp), %ecx
	movq	-16(%rbp), %rax
	movl	%ecx, %esi
	movq	%rax, %rdi
	call	new_graph
	movq	%rax, -8(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	fclose@PLT
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	preflow
	movl	%eax, -20(%rbp)
	movl	-20(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC7(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	free_graph
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE20:
	.size	main, .-main
	.section	.rodata
	.type	__PRETTY_FUNCTION__.0, @object
	.size	__PRETTY_FUNCTION__.0, 5
__PRETTY_FUNCTION__.0:
	.string	"push"
	.ident	"GCC: (Ubuntu 11.3.0-1ubuntu1~22.04) 11.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
