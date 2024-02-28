# Author: Kaden Jessee
# Desc: Basic intro to floats
# Date: 17 Feb 2022

.macro print_str (%string)
	la $a0, %string
	li $v0, 4
	syscall
.end_macro

.data	# your "data"

prompt: .asciiz "Enter a floating point number: "
output: .asciiz "You entered: "

.text	# actual instructions

.globl main
main:

	print_str(prompt)
	li $v0, 6
	syscall
	mov.s $f1, $f0
	print_str(output)
	mov.s $f12, $f1
	li $v0, 2
	syscall

exit:
	# exit program
	li $v0, 10
	syscall
