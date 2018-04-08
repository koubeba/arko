.globl main
.data
	prompt1: .asciiz "It's in"
	prompt2: .asciiz "It's not."
	newline: .asciiz "\n"
.text
main:
	#li $v0, 5
	#syscall
	#move $s0, $v0
	
	#li $v0, 5
	#syscall
	#move $s1, $v0
	
	li $a1, 2
	li $a2, 2
	
	jal is_point_in
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall
	
	beqz $v0, zero
	one:
		li $v0, 4
		la $a0, prompt1
		syscall
		
		li $v0, 10
		syscall
	zero:
		li $v0, 4
		la $a0, prompt2
		syscall
		
		li $v0, 10
		syscall


is_point_in:

	#bnez $a0, triangle2
	#triangle1:
		li $t0, 1	#x1
		li $t1, 1	#y1
		li $t2, 8	#x2
		li $t3, 1	#y2
		li $t4, 1	#x3
		li $t5, 6	#y3
		
		#Calculate the 2*triangle area.
		sub $t6, $t3, $t5	#y2- y3
		mul $t6, $t6, $t0	#(y2-y3)*x1
		
		sub $t7, $t5, $t1	#y3 - y1
		mul $t7, $t7, $t2	#(y3-y1)*x2
		
		sub $t8, $t1, $t3	#y1-y2
		mul $t8, $t8, $t4	#(y1-y2)*x3
		
		add $t9, $t6, $t7
		add $t9, $t6, $t8
		
		#Calculate the 2*ABP area.
		#use $a1 instead of $t4 and $a2 instead of $t5
		sub $t6, $t3, $a2	#y2- y3
		mul $t6, $t6, $t0	#(y2-y3)*x1
		
		sub $t7, $a2, $t1	#y3 - y1
		mul $t7, $t7, $t2	#(y3-y1)*x2
		
		sub $t8, $t1, $t3	#y1-y2
		mul $t8, $t8, $a1	#(y1-y2)*x3
		
		add $s5, $t6, $t7
		add $s5, $s5, $t8
		abs $s5, $s5
		
		#Calculate the 2*PBC area.
		#use $a1 instead of $t0 and $a2 instead of $t1
		sub $t6, $t3, $t5	#y2- y3
		mul $t6, $t6, $a1	#(y2-y3)*x1
		
		sub $t7, $t5, $a2	#y3 - y1
		mul $t7, $t7, $t2	#(y3-y1)*x2
		
		sub $t8, $a2, $t3	#y1-y2
		mul $t8, $t8, $t4	#(y1-y2)*x3
		
		add $s6, $t6, $t7
		add $s6, $s6, $t8
		abs $s6, $s6
		
		#Calculate the 2*APC area.
		#use $a1 instead of $t2 and $a2 instead of $t3
		sub $t6, $a2, $t5	#y2- y3
		mul $t6, $t6, $t0	#(y2-y3)*x1
		
		sub $t7, $t5, $t1	#y3 - y1
		mul $t7, $t7, $a1	#(y3-y1)*x2
		
		sub $t8, $t1, $a2	#y1-y2
		mul $t8, $t8, $t4	#(y1-y2)*x3
		
		add $s7, $t6, $t7
		add $s7, $s7, $t8
		abs $s7, $s7
		
		add $s3, $s5, $s6
		add $s3, $s3, $s7
		
		li $v0, 1
		move $a0, $s5
		syscall
		
		li $v0, 4
		la $a0, newline
		syscall
		li $v0, 1
		move $a0, $s6
		syscall
		
		li $v0, 4
		la $a0, newline
		syscall
		li $v0, 1
		move $a0, $s7
		syscall
		
		li $v0, 4
		la $a0, newline
		syscall
		
		move $v0, $s3
		jr $ra
		
		#Check if $t6 = $t7 and store the result in $v0
		beq $t6, $t7, true
		false:
		li $v0, 0
		jr $ra
		
		true:
		li $v0, 1
		jr $ra
	#triangle2:
	
	#jr $ra