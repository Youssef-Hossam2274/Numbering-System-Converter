.data
    digits: .asciiz "0123456789ABCDEF"
    otherSystemStorage: .space 40

.text

main:
    # convert 2533 to Base 16
    li $a0, 3516        
    li $a1, 13         
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
    addiu $sp, $sp, -24
    sw $fp, 20($sp)
    la $fp, 20($sp)
    # store tmps previous values
    sw $t0, -4($fp)
    sw $t1, -8($fp)
    sw $t2, -12($fp)
    sw $t3, -16($fp)
    sw $t4, -20($fp)

    ### Function logic
    la $t0, otherSystemStorage  # Load address of otherSystemStorage into $t0
    la $t3, digits              # Load address of digits into $t3
    move $t2, $a0               # Move number to $t2

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
    # restore caller's $fp and return
    lw $fp, ($fp)
    addiu $sp, $sp, 24
    jr $ra
