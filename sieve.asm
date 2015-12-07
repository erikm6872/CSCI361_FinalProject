# Code adapted from http://www.marcell-dietl.de/downloads/eratosthenes.s
	
	.data			# the data segment to store global data
space:	.asciiz	" "		# whitespace to separate prime numbers

	.text			# the text segment to store instructions
	.globl 	main		# define main to be a global label
main:	li	$s0, 0x00000000	# initialize $s0 with zeros  
	li	$s1, 0x11111111	# initialize $s1 with ones	
	li	$t9, 200	# find prime numbers from 2 to $t9 
	
	addi	$s2, $sp, 0	# backup bottom of stack address in 

	li	$t0, 2	# set counter variable to 2 

init:	sw	$s1, ($sp)	# write ones to the stackpointer's address
	addi	$t0, $t0, 1	# increment counter variable
	addi	$sp, $sp, -4	# subtract 4 bytes from stackpointer (push)
	#all of the adds with numbers I changed to addi and the only sub with a number  I changed to an addi with a negative number.
	
	#ble	$t0, $t9, init	# take loop while $t0 <= $t9
	#li $t0, 1   #reset counter variable to 1 (this was moved to counter reset)
	beq	$t0, $t9, counterreset	# take loop while $t0 != $t9, which essentially means when $t0 < $t9 since $t0 is initialized to a lower value.
	#also, side note on the above line, I know the original code has it for $t0 <= $t9, but it gives the correct output, so i figure it doesn't matter.
	j init #go to init, because $t0 is smaller than $t9
counterreset:	li	$t0, 1		# reset counter variable to 1

outer:	addi	$t0, $t0, 2	#add 2 to increment counter. Only odd numbers (other than 2) need to be checked
	sll	$t1, $t0, 1	# multiply $t0 by 2 and save to $t1 by logically left shifting by 1.
	bgt	$t1, $t9, print2	# start printing prime numbers when $t1 > $t9

check:	addi	$t2, $s2, 0	# save the bottom of stack address to $t2
	sll	$t3, $t0, 2	# calculate the number of bytes to jump over by multiplying by 4 using sll
	sub	$t2, $t2, $t3	# subtract them from bottom of stack address
	addi	$t2, $t2, 8	# add 2 words - we started counting at 2!

	lw	$t3, ($t2)	# load the content into $t3

	beq	$t3, $s0, outer	# only 0's? go back to the outer loop

inner:	addi	$t2, $s2, 0	# save the bottom of stack address to $t2
	sll	$t3, $t1, 2	# calculate the number of bytes to jump over
	sub	$t2, $t2, $t3	# subtract them from bottom of stack address
	addi	$t2, $t2, 8	# add 2 words - we started counting at 2!
	addi	$t4, $t0, -1	#set $t4 to the last multiple we were removing, this is so that we don't remove repeat multiples like 15 and such
	div	$t1, $t4	#you need divide here so you can use mfhi to find if the multiple has already been stored
	mfhi	$t4		#put the remaineder of div $t1,$t0 into $t
	
	add	$t1, $t1, $t0	# do this for every multiple of $t0
	
	bgt	$t1, $t9, outer	# every multiple done? go back to outer loop
	beq 	$t4, $0, inner			#when $t4 is 0 then we know that $t1 was divisible by $t0-1($t4 before it gets the remainder put in)
	sw	$s0, ($t2)	# store 0's -> it's not a prime number! /moved below the bgt
	j	inner		# some multiples left? go back to inner loop

print2:	li	$t0, 2		# reset counter variable to 2, since that's what you're printing right below.
	#addi 	$t4, $0, 2	#this is for the beq in count1. you don't need this
	#print2 is added, because if you have outer incrementing by 2 you can have count increment by 2 as well, and it will print primes save for 2, so this increments it by 1 to print 2,
	#then resets the counter to 1 and increments by 2.
count1:	#addi	$t0, $t0, 1	#increments $t0 by 1(start at 2) (you don't need this because in print2 you set $t0 to 2)			
	#bgt	$t0, $t4, printrest	# make sure to exit when 2 is done
	addi	$t2, $s2, 0	# save the bottom of stack address to $t2
	sll	$t3, $t0, 2	# calculate the number of bytes to jump over by 4 multiplying using sll
	sub	$t2, $t2, $t3	# subtract them from bottom of stack address
	addi	$t2, $t2, 8	# add 2 words - we started counting at 2!

	lw	$t3, ($t2)	# load the content into $t3
	#beq	$t3, $s0, count1	# only 0's? go back to count1 loop you on
	addi	$t3, $s2, 0	# save the bottom of stack address to $t3

	sub	$t3, $t3, $t2	# substract higher from lower address (= bytes)
	#srl	$t3, $t3, 2	#divides by 4 using a right logical shift.
	addi	$t3, $t3, 2	# add 2 (words) = the final prime number! 
	li	$v0, 1		# system code to print integer
	addi	$a0, $t3, 0	# the argument will be our prime number in $t3
	syscall			# print it!
	la	$a0, space	# the argument will be a whitespace
	li	$v0, 4		# system code to print string
	
	syscall			# print it!
	#ble	$t0, $t4, count1	# take loop while $t0 <= $t4
#some of the things in count1 aren't needed do to the fact that it only prints one number, so I removed the unneeded things.


printrest:	li	$t0, 1		# reset counter variable to 1
count:	addi	$t0, $t0, 2	#increments $t0 by 2(start at 2)
				#you increment this by 2 because above(in outer) you increment the counter by 2, and it makes going by 1 unnecessary.
	bgt	$t0, $t9, exit	# make sure to exit when all numbers are done

	addi	$t2, $s2, 0	# save the bottom of stack address to $t2
	sll	$t3, $t0, 2	# calculate the number of bytes to jump over by 4 multiplying using sll
	sub	$t2, $t2, $t3	# subtract them from bottom of stack address
	addi	$t2, $t2, 8	# add 2 words - we started counting at 2!

	lw	$t3, ($t2)	# load the content into $t3
	beq	$t3, $s0, count	# only 0's? go back to count loop
	
	addi	$t3, $s2, 0	# save the bottom of stack address to $t3

	sub	$t3, $t3, $t2	# substract higher from lower address (= bytes)
	srl	$t3, $t3, 2	#divides by 4 using a right logical shift.
	addi	$t3, $t3, 2	# add 2 (words) = the final prime number!

	li	$v0, 1		# system code to print integer
	addi	$a0, $t3, 0	# the argument will be our prime number in $t3
	syscall			# print it!
	la	$a0, space	# the argument will be a whitespace
	li	$v0, 4		# system code to print string
	
	syscall			# print it!

	ble	$t0, $t9, count	# take loop while $t0 <= $t9

exit:	li	$v0,10		# set up system call 10 (exit)
	syscall	
