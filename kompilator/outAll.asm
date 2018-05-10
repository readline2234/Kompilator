.data
	x: 	.word	0
	_tmp0: 	.word	0
	_tmp1: 	.word	0
.text
	li $t0, 4
	li $t1, 2
	add $t0, $t0, $t1
	sw $t0, _tmp0

	lw $t0, _tmp0	#type: 	2
	sw $t0, x

