#
# Test ca.asm floating point parser with some examples
#
# s0 - num of tests left to run
# s1 - position of floats
# s2 - position of bytes
# s3 - expected output
#
#
# all procedures of ca.asm must:
# - be named as specified and declared as global
# - read parameters from a0 and a1
# - follow the convention of using the t0-9 registers for temporary storage
# - (if it uses s0-7 then it is responsible for pushing existing values to the stack then popping them back off before returning)
# - write the return value to v0

.data

# number of test cases
n: .word 10
# input values (null terminated) & expected output values (word sized ints)
ins:  .float 5.25, 1.0, 3.125, -5.25, -1.0, 127.825, 0.75, .0125, 4294967167, 4294967295, -4294967167
exponents: .word 2, 0, 1, 2, 0, 6, -1, -7, 31, 32, 31
significands: .word 0xa80000, 0x800000, 0xc80000, 0xa80000, 0x800000, 0xffa666, 0xc00000, 0xcccccd, 0xffffff, 0x800000, 0xffffff
uints: .word 5, 1, 3, 5, 1, 127, 0, 0, 4294967040, 4294967295, 4294967040
signs: .ascii     "+++--+++++-"

failedtest: .asciiz "failed test number: "
failmsg: .asciiz "\nfailed for test input: "
okmsg: .asciiz "all tests passed"


.text

runner:
        lw      $s0, n
        li      $s1, 0
        li      $s2, 0
        li      $s3, 0

run_test:
        lw      $a0, ins($s1)           # get input
        jal     parse_sign              # call subroutine under test
        move    $v1, $v0                # move return value in v0 to v1 because we need v0 for syscall

        lb      $s3, signs($s2)         # read expected output from memory
        bne     $v1, $s3, exit_fail     # if expected doesn't match actual, jump to fail

        lw      $a0, ins($s1)           # get input
        jal     parse_exponent          # call subroutine under test
        move    $v1, $v0                # move return value in v0 to v1 because we need v0 for syscall

        lw      $s3, exponents($s1)     # read expected output from memory
        bne     $v1, $s3, exit_fail     # if expected doesn't match actual, jump to fail

        lw      $a0, ins($s1)           # get input
        jal     parse_significand      # call subroutine under test
        move    $v1, $v0                # move return value in v0 to v1 because we need v0 for syscall

        lw      $s3, significands($s1)  # read expected output from memory
        bne     $v1, $s3, exit_fail     # if expected doesn't match actual, jump to fail

        lw      $a0, exponents($s1)     # get inputs
        lw      $a1, significands($s1)  #
        jal     calc_truncated_uint     # call subroutine under test
        move    $v1, $v0                # move return value in v0 to v1 because we need v0 for syscall

        lw      $s3, uints($s1)         # read expected output from memory
        bne     $v1, $s3, exit_fail     # if expected doesn't match actual, jump to fail

        addi    $s1, $s1, 4             # move to next inputs/outputs
        addi    $s2, $s2, 1             # move to next signs
        sub     $s0, $s0, 1             # decrement num of tests left to run
        bgt     $s0, $zero, run_test    # if more than zero tests to run, jump to run_test

exit_ok:
        la      $a0, okmsg              # put address of okmsg into a0
        li      $v0, 4                  # 4 is print string
        syscall

        li      $v0, 10                 # 10 is exit with zero status (clean exit)
        syscall

exit_fail:
        la      $a0, failedtest        # put address of failmsg into a0
        li      $v0, 4                  # 4 is print string
        syscall

        move    $a0, $s2
        li      $v0, 1
        syscall
        
        la      $a0, failmsg            # put address of failmsg into a0
        li      $v0, 4                  # 4 is print string
        syscall

        lwc1    $f12, ins($s1)          # print input that failed on
        li      $v0, 2
        syscall

        li      $a0, 1                  # set error code to 1
        li      $v0, 17                 # 17 is exit with error
        syscall

# # Include your implementation here if you wish to run this from the MARS GUI.
 .include "ca.asm"
