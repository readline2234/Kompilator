.data
	x: 	.word	0
	_tmp0: 	.word	0
	_tmp1: 	.word	0
.text
	li $t0, 5	#type: 	0	add to value
	li $t1, 2	#type: 	0	add to value
	add $t0, $t0, $t1
	sw $t0, _tmp0

	lw $t0, _tmp0	#type: 	2	def to variable
	sw $t0, x

