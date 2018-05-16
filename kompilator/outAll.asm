.data
	x: 	.word	0
	_tmp0: 	.word	0
.text
	li $t0, 10	#type: 	0	def to value
	sw $t0, x

	lw $t2, x	#on variable type
	li $t3, 5	#on value type
	bgt $t2, $t3, LBL1

	li $v0, 1
	li $a0, 1	#type: 	0	print - value
	syscall

	LBL1:

	li $v0, 1
	li $a0, 2	#type: 	0	print - value
	syscall

