.data
	programarg:	.asciiz "Program Arguements: \n"
	integers: .asciiz "\n\nInteger Values: \n"
	maxval: .asciiz "\n\nMaximum Value: \n"
.text
#saves address1 to s1, address 1 points to the program arguements in the data
move $s1 $a1
#saves number of arguements to s0
move $s0 $a0

#initializing the following registers, which are used as loop counters
#t8 holds the int version of the program arg
li $t8 0

#t4 is the loop counter, when 0 its the first loop
#and goes up till it matches number of arguements (s0)
li $t4 0
#t5 holds the first value (when t4=0) and
#then is compared against every subsequent value,
#if the val is bigger than t5 it gets saved to t5
#how the max value is found
li $t5 0

#prints initial sentence "Program Arguements: \n"
li $v0, 4
la $a0, programarg
syscall

main:	nop			
	
	#t5 is a counter for the first loop, which is printing
	#string versions of the entered arguements
	#when t5= # of arguements (s0) break to intergerprompt
	beq $t5, $s0,  integerprompt
	
	#print string, which is a program arg. 
	li $v0, 4
	lw $a0, ($s1)
	syscall
	
	#print space
	li $v0, 11
	la $a0, 0x20
	syscall
	
	#increment string loop counter up
	addi $t5, $t5, 1
	
	#shift s1 to next program arguement
	addi $s1, $s1, 4
	
	#loop
	b main

integerprompt:
	#print string "\n\nIntegers: \n"
	li $v0, 4
	la $a0, integers
	syscall
	
	#'resets' s1 to begining of 'address1' which points to program arguements in the data
	move $s1 $a1
	
	#begin new loop for printing int versions of arguements
	b hex

maxvalprompt:
	
	#print string "\n\nMaximum Value:\n"
	li $v0, 4
	la $a0, maxval
	syscall
	#end program
	
	b exit
	
hex: nop
	
	#if $t4 = # of arguements break to final string
	#
	beq $t4, $s0,  maxvalprompt
	
	lw $t0 ($s1)
	
	#counter
	li $t6 1	
	
	addi $t0 $t0 3
	
check_power:	nop

	lb $t2 ($t0)
	#once t2 has cycled through t0 break
	beqz $t2 firstconversion
	
	sll $t6 $t6 4
	#increment t0 up
	add $t0 $t0 1
	
	b check_power 
	
firstconversion: nop

	move $t2 $t6
	
	#load word into t0
	lw $t0 ($s1)
	
	#increment past the 0x
	add $t0 $t0 2		

secondconversion: nop
	
	lb $t1 ($t0)		# loaded (3rd) letter into $t1
	beq $t1 $zero print	# for loop statement: only want to loop 'n' number of
				# times, where 'n' is the number of "letters" in our word
	bgt $t1 0x3A  letter	# handles case if value is "numb" or "letter"
	
int: nop			# handles number
	
	subi $t1 $t1 48		# convert to int value
	b calculate_number

letter: nop			# handles letter
	
	subi $t1 $t1 55		# convert to int value

calculate_number: nop
	
	mul $t3 $t1 $t2		# convert int using base16
	add $t8 $t8 $t3		# add value to the running sum 
	addi $t0 $t0 1		# increment pointer counter
	div $t2 $t2 16		# decrement 16 multiplier
	b secondconversion		# go back to loop

firstnum: nop
	#put first arg in t5
	
	la $t5, ($t8)
	
	#addi $t4, $t4, 1
	li $t8, 0
	addi $t4, $t4, 1
	addi $s1, $s1, 4

	#space
	li $v0, 11
	la $a0, 0x20
	syscall
	
	b hex

changemax:

	#changes t5 to new larger int
	la $t5, ($t8)
	
	#addi $t4, $t4, 1
	li $t8, 0
	addi $t4, $t4, 1
	addi $s1, $s1, 4

	#space
	li $v0, 11
	la $a0, 0x20
	syscall
	
	b hex
							
print: nop
	#print int
	li $v0 1
	la $a0 ($t8)
	syscall
	
	#if it is the first loop store num to t5
	beqz $t4, firstnum
	
	#if next num bigger the current t5
	#put new larger numin t5 
	bgt $t8, $t5, changemax
	
	#reset t8 for loop
	li $t8, 0 

	#increment counter up
	addi $t4, $t4, 1

	#next arguement
	addi $s1, $s1, 4

	#space
	li $v0, 11
	la $a0, 0x20
	syscall
	
	b hex

exit: nop
	#print maxnum
	li $v0 1			
	la $a0 ($t5)
	syscall

	#end
	li $v0 10			
	syscall
