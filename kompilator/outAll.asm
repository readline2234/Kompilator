.data
	x: 	.word	0
	_tmp0: 	.word	0
	z: 	.word	0
	_tmp1: 	.word	0
	_tmp2: 	.word	0
	_tmp3: 	.word	0
.text
	li $t0, 3
	sw $t0, x

	lw $t0, x
	li $t1, 2
	mul $t0, $t0, $t1
	sw $t0, _tmp1

	li $t0, 5
	lw $t1, _tmp1
	add $t0, $t0, $t1
	sw $t0, _tmp2

	li $t0, _tmp2
	sw $t0, z

