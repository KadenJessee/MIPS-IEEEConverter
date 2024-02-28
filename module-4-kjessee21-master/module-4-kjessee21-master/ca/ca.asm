# Author: Kaden Jessee
# Date: 21 Feb 2022
# Description: Floating point and IEEE 754

.globl parse_sign, parse_exponent, parse_significand, calc_truncated_uint main# Do not remove this line

# Data for the program goes here
.data

prompt: .asciiz "Enter an IEEE 754 floating point number in decimal form: "
num: .space 32 #store up to 31 + newline character
sign: .asciiz "The sign is: "
exp: .asciiz "\nThe exponent is: "
sig_bit: .asciiz "\nThe significand bits as an integer is: "
uns_int: .asciiz "\nThe truncated unsigned integer value is: "
trunc_int: .asciiz "\nThe truncated integer number is: "


.text 				# Code goes here

#Registers
#$f1, contains single point from user
#s0: contains input given from user
#s1: contains parse_sign value
#s2: contains parse_exponent value
#s3: contains parse_significand value
#s4: contains truncated_int value
main:
	
	# Step 1: Read a floating point number
	la $a0, prompt	#print string prompt
	li $v0, 4
	syscall
	li $v0, 6
	syscall
	mov.s $f1, $f0
	# Step 2: setup and call parse_sign
	
	#make a copy from $f1 to $s0
	mfc1 $s0, $f1
	
	move $t0, $s0
	move $a0, $s0
	jal parse_sign	#int parse_signs(float)
	#save value from function to $s1
	move $s1, $v0
	
	la $a0, sign	#print sign string
	li $v0, 4
	syscall
	move $a0, $s1		#print +/- sign
	li $v0, 11
	syscall
	
	
	# Step 3: setup and call parse_exponent
	move $t0, $s0
	move $a0, $s0
	jal parse_exponent
	move $s2, $v0	#save exponent into s2
	
	
	la $a0, exp	#print exponent string
	li $v0, 4
	syscall
	move $a0, $s2
	li $v0, 1
	syscall
	# Step 4: setup and call parse_significand
	
	move $a0, $s0
	jal parse_significand
	move $s3, $v0
	
	la $a0, sig_bit	#print significand string
	li $v0, 4
	syscall
	move $a0, $s3
	li $v0, 35	#print it in binary
	syscall
	
	#step 5: setup and call calc_truncated_uint
	#print truncated unsigned integer value
	move $a0, $s2 		#a0 has exponent
	move $a1, $s3		#a1 has the significand
	jal calc_truncated_uint
	move $s4, $v0
	
	la $a0, uns_int	#print truncated string
	li $v0, 4
	syscall
	move $a0, $s4
	li $v0, 36	#36: print int as unsigned
	syscall
	
	la $a0, trunc_int	#print truncated string
	li $v0, 4
	syscall
	move $a0, $s1
	li $v0, 11		#print sign
	syscall
	move $a0, $s4
	li $v0, 36		#print truncated integer
	syscall
	# Step 6: If you haven't been printing values along the way
	# Print out the appropriate output here.
	
exit_main:
	li    $v0, 10		# 10 is the exit program syscall
	syscall			# execute call

## end of ca.asm

# Gets the sign from an IEEE 754 single precision representation
#
# Argument parameters:
# $a0 - IEEE 754 single precision floating point number (required)
# Return Value:
# $v0 - ascii char for sign (+ or -) (required)
parse_sign:
	#lb $t0, 0($a0)		#load first byte from input
	srl $t0, $a0, 31	#get sign bit to very end on right
	andi $t0, $t0, 1		#AND for far right bit
	beq $t0, 0, positive	#if t0 == 0 then positive sign 2B
	beq $t0, 1, negative	#if t0 == 1 then negative sign 2D
	j end_parse_sign
	
positive:
	li $v0, 0x2B		#set v0 to + character
	j end_parse_sign

negative:
	li $v0, 0x2D		#set v0 to - character
	j end_parse_sign

end_parse_sign:
	#v0 to '+' or '-' from positive or negative
	jr $ra


###############################################################
# Gets the exponent from an IEEE 754 single precision representation
#
# Argument parameters:
# $a0 - IEEE 754 single precision floating point number
# Return Value:
# $v0 - signed integer of exponent value with bias removed
parse_exponent:
	srl $t0, $a0, 23	#shift right 23 to get rid of end bits
	andi $t0, $t0, 0xff	#AND for the 8 bits at end
	subi $t0, $t0, 127	#subtract 127 from t0
	move $v0, $t0
end_parse_exponent:
        jr $ra
        
        
###############################################################
# Gets the significand from an IEEE 754 single precision representation
#
# Argument parameters:
# $a0 - IEEE 754 single precision floating point number
# Return Value:
# $v0 - unsigned int whose low order 24 bits represent the significand of the IEEE 754 number
parse_significand:
	move $t0, $a0		#move a0 to t0
	andi $t0, $t0, 0x007FFFFF	#and t0 with 0x007FFFFF
	ori $t0, $t0, 0x00800000	#or with 0x00800000
	
	move $v0, $t0		#return v0
end_parse_significand:
        jr $ra
        
        
        
###############################################################
# Calculates the truncated unsigned int representation of an
# IEEE 754 single precision floating point number based on the
# unbiased exponent and the significand
#
# Argument parameters:
# $a0 - singed integer representing unbiased exponent of IEEE 754 single precision floating point number
# $a1 - unsigned int whose low order 24 bits match the significand of the IEEE 754 number
calc_truncated_uint:
	move $t0, $a0	#t0 has exponent
	move $t1, $a1	#t1 has significand
	
	#check $t0 if greater than 31
	bgt $t0, 31, max_uint
	#get the difference between exponent and 23
	subi $t0, $t0, 23
	#if exponent is negative, use 0 as int value, shift right
	bltz $t0, shift_right
	#else shift left
	j shift_left
	
max_uint:
	#stores max unsigned int value of 0xFFFFFFFF
	ori $t2, $t0, 0xFFFFFFFF
	j end_calc_truncated_uint

shift_right:
	#Compute right shifts t0 = t0(exponent) - 23 -- computed line 180
	abs $t0, $t0		#gets positive number
	srlv $t2, $t1, $t0	#significand shift right by t0
	
	j end_calc_truncated_uint
shift_left:
	#Compute left shifts t0 = t0(exponent) - 23
	#t2 = shift left logical(t1) by t0
	sllv $t2, $t1, $t0
	
	j end_calc_truncated_uint
end_calc_truncated_uint:
	move $v0, $t2	#return v0
	jr $ra
