.data
	x: 	.word	0
	_tmp0: 	.word	0
	_tmp1: 	.word	0
	_tmp2: 	.word	0
	_tmp3: 	.word	0
	_tmp4: 	.word	0
.text
	li $t0, 5	#type: 	0	def to value
	sw $t0, x

	li $t0, 3	#type: 	0	add to value
	li $t1, 4	#type: 	0	add to value
	add $t0, $t0, $t1
	sw $t0, _tmp1

	li $t0, 2	#type: 	0	add to value
	li $t1, 2	#type: 	0	add to value
	add $t0, $t0, $t1
	sw $t0, _tmp2

	li $t0, 2	#type: 	0	add to value
	li $t1, 2	#type: 	0	add to value
	add $t0, $t0, $t1
	sw $t0, _tmp3

	li $t0, 4	#type: 	0	add to value
	li $t1, 4	#type: 	0	add to value
	add $t0, $t0, $t1
	sw $t0, _tmp4

