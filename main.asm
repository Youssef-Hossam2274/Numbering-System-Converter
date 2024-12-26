.data
    digits: .asciiz "0123456789ABCDEF"
    otherSystemStorage: .space 40

.text

main:
    # convert 2533 to Base 16
    li $a0, 2533        
    li $a1, 16
    jal decimalToOther  


    li $v0, 4          
    la $a0, otherSystemStorage 
    syscall            


    li $v0, 10       
    syscall

# number: $a0, base: $a1
decimalToOther:
    ### Frame initialization
    # save caller's $fp and change $fp
    addiu $sp, $sp, -28
    sw $fp, 24($sp)
    la $fp, 24($sp)
    # store tmps previous values
    sw $t0, -4($fp)
    sw $t1, -8($fp)
    sw $t2, -12($fp)
    sw $t3, -16($fp)
    sw $t4, -20($fp)
    sw $t5, -24($fp)

    ### Function logic
    la $t0, otherSystemStorage  # Load address of otherSystemStorage into $t0
    la $t3, digits              # Load address of digits into $t3
    move $t2, $a0               # Move number to $t2
	
	# Handling case if a0 = 0
ZERO_ARG_CASE:
	bnez $a0, LP
    # Adding single zero character
    li $t1, 48
    sb $t1, ($t0)
    addiu $t0, $t0, 1
    
    j REV_LP_END
	
LP:
    # While (number > 0)
    slt $t4, $zero, $t2
    beqz $t4, LP_END

    #  remainder = number % base
    div $t2, $a1
    mfhi $t1

    # Store the corresponding digit in the otherSystemStorage array
    add $t1, $t1, $t3
    lb $t1, ($t1)
    sb $t1, ($t0)
    addiu $t0, $t0, 1

    #  number = number / base
    mflo $t2

    j LP
    
LP_END:

	# Reverse the result
	la $t1, otherSystemStorage	# pointer at array start
	addiu $t2, $t0, -1			# pointer at array end
	
REV_LP:
    # While (start < end)
    slt $t4, $t1, $t2
    beqz $t4, REV_LP_END
    
    # load two digits
    lb $t3, ($t1)
    lb $t5, ($t2)
    
    # store back in reverse
    sb $t3, ($t2)
    sb $t5, ($t1)
    
    # increment & decrement
    addiu $t1, $t1, 1
    addiu $t2, $t2, -1
    
    j REV_LP
REV_LP_END:

    # Adding null character at end
    li $t1, 0
    sb $t1, ($t0)

    ### Frame cleanup
    # restore tmps previous values
    lw $t0, -4($fp)
    lw $t1, -8($fp)
    lw $t2, -12($fp)
    lw $t3, -16($fp)
    lw $t4, -20($fp)
    lw $t5, -24($fp)
    
    # restore caller's $fp and return
    lw $fp, ($fp)
    addiu $sp, $sp, 28
    jr $ra
