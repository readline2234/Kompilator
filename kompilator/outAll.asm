.data
	x: 	.word	0
	_tmp0: 	.word	0
	_tmp1: 	.word	0
	_tmp2: 	.word	0
	_tmp3: 	.word	0
.text
	li $t0, 2	#type: 	0	mul to value
	li $t1, 2	#type: 	0	mul to value
	mul $t0, $t0, $t1
	sw $t0, _tmp0

	li $t0, 2	#type: 	0	add to value
	lw $t1, _tmp0	#type: 	2	add to variable
	add $t0, $t0, $t1
	sw $t0, _tmp1

	lw $t0, _tmp1	#type: 	2	sub to variable
	li $t1, 1	#type: 	0	sub to value
	sub $t0, $t0, $t1
	sw $t0, _tmp2

	lw $t0, _tmp2	#type: 	2	def to variable
	sw $t0, x

	li $v0, 1
	lw $a0, x	#type: 	2	print - variable
syscall

