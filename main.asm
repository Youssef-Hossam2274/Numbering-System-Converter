.data
	digits: .asciiz "0123456789ABCDEF"
	otherSystemStorage: .space 40
	
.text

main:
	
	

# number: $a0, base: $a1
decimalToOther:
	### Frame initilization
	# save caller's $fp and change $fp
	addiu $sp, $sp, -4
	sw $fp, ($sp)
	la $fp, ($sp)
	# expand $sp to create new frame
	addiu $sp, $sp, -20
	# store tmps previous values
	sw $t0, -4($fp)
	sw $t1, -8($fp)
	sw $t2, -12($fp)
	sw $t3, -16($fp)
	sw $t4, -20($fp)
	
	### Function logic
	# load registers
	la $t0, otherSystemStorage
	move $t1, $zero	# cur digit
	move $t2, $a0	# number
	la $t3, digits	# digits array reference
	
	# Your code goes here Ya M3ALEM
LP:
	# While (number > 0)
	slt $t4, $zero, $t1
	beqz $t4, LP_END
	
	
	j LP
LP_END:
	# Adding null character at end
	
	# Save result address in $v0
	la $v0, otherSystemStorage

	### Frame closing
	# restore tmps previous values
	lw $t0, -4($fp)
	lw $t1, -8($fp)
	lw $t2, -12($fp)
	lw $t3, -16($fp)
	lw $t4, -20($fp)
	# shrink $sp to close the fram
	addiu $sp, $sp, 20
	# retrieves caller's $fp
	lw $fp, ($sp)
	addiu $sp, $sp, 4
	
	# return
	jr $ra
	
	
	

	
	
	
	
	
	