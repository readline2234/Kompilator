.data
	x: 	.word	0
	_tmp0: 	.word	0
	_tmp1: 	.word	0
	y: 	.word	0
	_tmp2: 	.word	0
	_tmp3: 	.word	0
.text
	li $t0, 3	#type: 	0	def to value
	sw $t0, x

	li $t0, 5	#type: 	0	add to value
	li $t1, 4	#type: 	0	add to value
	add $t0, $t0, $t1
	sw $t0, _tmp1

	lw $t2, x
	lw $t3, _tmp1
	bge $t2, $t3, LBL5

	li $t0, 2	#type: 	0	def to value
	sw $t0, y

	li $t0, 2	#type: 	0	def to value
	sw $t0, x

