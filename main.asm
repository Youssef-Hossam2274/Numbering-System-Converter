.data
    digits: .asciiz "0123456789ABCDEF"
    otherSystemStorage: .space 40
    prompt1: .asciiz "Enter the current system: "
    prompt2: .asciiz "Enter the number: "
    prompt3: .asciiz "Enter the new system: "
    resultMsg: .asciiz "The number in the new system: "


.text

main:
    # Prompt the user to enter a number in the original base
    la $a0, prompt2         # Load the prompt message
    li $v0, 4               # Print string syscall
    syscall

    # Read the number string
    la $a0, otherSystemStorage  # Address to store the input
    li $a1, 40                 # Max length of the input
    li $v0, 8                  # Read string syscall
    syscall
    # Traverse the string to find the null terminator
    la $t0, otherSystemStorage  # Load the base address of the string
    li $t1, 0                  # Null terminator value
    move $t2, $t0              # Copy the base address for iteration

find_null:
    lb $t3, 0($t2)             # Load the current byte
    beq $t3, $t1, set_last     # If null terminator is found, break loop
    addiu $t2, $t2, 1          # Move to the next character
    j find_null                # Repeat the loop

set_last:
    subiu $t2, $t2, 1          # Move back to the last character
    sb $t1, 0($t2)             # Set the last character to null
    
    la $a0, prompt1         # Load the prompt message
    li $v0, 4               # Print string syscall
    syscall

    # Read the base of the input number
    li $v0, 5               # Read integer syscall
    syscall
    move $a1, $v0           # Move the base into $a1

    # Call the otherToDecimal function
    jal otherToDecimal      # Jump and link to otherToDecimal

    # Print the result
    move $a0, $v0           # Move the result into $a0
    li $v0, 1               # Print integer syscall
    syscall

    # Exit the program
    li $v0, 10              # Exit syscall
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

# number: $a0 , base: $a1
otherToDecimal:

### Frame initialization
    # save caller's $fp and change $fp
    addiu $sp, $sp, -24
    sw $fp, 20($sp)
    move $fp, $sp
    # store tmps previous values
    sw $t0, -4($fp)
    sw $t1, -8($fp)
    sw $t2, -12($fp)
    sw $t3, -16($fp)
    sw $t4, -20($fp)

# Logic
    la $t0, otherSystemStorage  # Load address of otherSystemStorage into $t0
    la $t3, digits              # Load address of digits into $t3
    li $t2, 0                   # Initialize result to 0
    li $t4, 1                   # Initialize multiplier (base power, starts at 1)

Loop:
    lb $t1, ($t0)               # Load byte from otherSystemStorage
    beqz $t1, Loop_end          # If null terminator, end loop

    # Find the value of the digit
    sub $t1, $t1, '0'           # Subtract ASCII value of '0'
    blt $t1, 10, ValidDigit     # If less than 10, it's a valid digit (0-9)
    sub $t1, $t1, 7             # Adjust for 'A'-'F' (i.e., 10-15)
    
ValidDigit:
    # Multiply result by base (power of the base)
    mul $t2, $t2, $a1           # Multiply result by base (current base power)
    add $t2, $t2, $t1           # Add digit value to result

    addiu $t0, $t0, 1           # Move to next character
    j Loop

Loop_end:
    move $v0, $t2               # Store the result in $v0

### Frame cleanup
    # restore tmps previous values
    lw $t0, -4($fp)
    lw $t1, -8($fp)
    lw $t2, -12($fp)
    lw $t3, -16($fp)
    lw $t4, -20($fp)
    # restore caller's $fp and return
    move $sp, $fp
    lw $fp, 20($sp)
    addiu $sp, $sp, 24
    jr $ra
