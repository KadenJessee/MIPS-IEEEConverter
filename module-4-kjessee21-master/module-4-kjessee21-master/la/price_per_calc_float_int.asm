# Author: Kaden Jessee
# Desc: Basic calculator of sharing costs
# Date: 17 Feb 2022

.macro print_str (%string)
	la $a0, %string
	li $v0, 4
	syscall
.end_macro

.data	# your "data"

prompt_cost: .asciiz "Enter the total cost: "
prompt_people: .asciiz "Enter the number of people: "
output: .asciiz "Each individual owes: "

.text	# actual instructions

#Registers used:
# $v0 for syscalls
# $a0 for string addresses to print
# $f1 for total cost
# $f2 for number of people
# $f3 for the cost_per_person
# $t0 for the int number of people
# $t1 for the int cost per person

.globl main
main:

	print_str(prompt_cost)
	li $v0, 6			#read float cost
	syscall
	mov.s $f1, $f0
	print_str(prompt_people)
	li $v0, 5			#read int people
	syscall
	move $t0, $v0
	mtc1 $t0, $f2			#convert int to float
	cvt.s.w $f2, $f2
	#Calculate cost per person
	#cost/people
	div.s $f3, $f1, $f2
	ceil.w.s $f3, $f3		#round cost per person up
	mfc1 $t1, $f3				#convert to Integer
	print_str(output)
	move $a0, $t1
	li $v0, 1
	syscall

exit:
	# exit program
	li $v0, 10
	syscall
