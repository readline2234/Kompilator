.data
	_tmp0: 	.word	0
.text
	li $t0, 2	#type: 	0	add to value
	li $t1, 2
	add $t0, $t0, $t1
	sw $t0, _tmp0

	li $v0, 1
	li $a0, _tmp0
	syscall

