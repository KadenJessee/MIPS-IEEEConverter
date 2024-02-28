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

.globl main
main:

	print_str(prompt_cost)
	li $v0, 6
	syscall
	mov.s $f1, $f0
	print_str(prompt_people)
	li $v0, 6
	syscall
	mov.s $f2, $f0
	#Calculate cost per person
	#cost/people
	div.s $f3, $f1, $f2
	print_str(output)
	mov.s $f12, $f3
	li $v0, 2
	syscall

exit:
	# exit program
	li $v0, 10
	syscall
