.globl main
.data 
	testprompt: .asciiz "width: "
	prompt: .asciiz "\tHello there! Enter coordinates for vertices A, B, C for 2 triangles.\n\tEach coordinate consists of x, y, z.\n"
	
	promptA: .asciiz "Enter coordinates of the A vertex "
	promptB: .asciiz "Enter coordinates of the B vertex "
	promptC: .asciiz "Enter coordinates of the C vertex "
	
	prompt1: .asciiz "of the 1st triangle.\n"
	prompt2: .asciiz "of the 2nd triangle.\n"
	
	promptc: .asciiz "Enter coordinate:\n"
	prompty: .asciiz "Enter y coordinate: "
	promptz: .asciiz "Enter z coordinate: "
	newline: .asciiz "\n"
	
	buffer: .space 1257682
	
	maskz: .word 511
	masky: .word 1048064
	maskx: .word 536346624
	maskcolor: .word 2147483648
	
	.eqv A1.x -72($sp)
	.eqv A1.y -68($sp)
	.eqv A1.z -64($sp)
	
	.eqv B1.x -60($sp)
	.eqv B1.y -56($sp)
	.eqv B1.z -52($sp)
	
	.eqv C1.x -48($sp)
	.eqv C1.y -44($sp)
	.eqv C1.z -40($sp)
	
	.eqv A2.x -36($sp)
	.eqv A2.y -32($sp)
	.eqv A2.z -28($sp)
	
	.eqv B2.x -24($sp)
	.eqv B2.y -20($sp)
	.eqv B2.z -16($sp)
	
	.eqv C2.x -12($sp)
	.eqv C2.y -8($sp)
	.eqv C2.z -4($sp)
	
	.eqv BMPH $s6
	.eqv BMP $s7
	
	.eqv WHITE 0xFFFFFF
	.eqv BLACK 0x000000
	
	.eqv WIDTH $s0
	.eqv HEIGHT $s1
	.eqv BITS_PP $s2
	.eqv PIXELS_ROW $s3
	.eqv PADDING $s4
	.eqv BMP_BUFFER $s5
	
	bmp_path: .asciiz "in.bmp"

#Assumpions: 3 bytes/pixel in the BMP

.text

main:
	li $v0, 4	#print Hello
	la $a0, prompt
	syscall 

open_bmp:
	li $v0, 13
	la $a0, bmp_path
	li $a1, 0	#open for writing
	li $a2, 0
	syscall
	move BMPH, $v0
	
	blez $v0, exit
	
read_bmp:
	li $v0, 14
	la $a0, (BMPH)
	la $a1, buffer
	li $a2, 61440
	syscall
	
	move BMP, $a1

close_bmp:
	li $v0, 16
	move $a0, BMPH
	syscall
	
	li $t0, 18
	
get_coord_input:
	li $v0, 4	#ask for coordinate
	la $a0, promptc
	syscall
	
	li $v0, 5	#read the coordinate as integer
	syscall
	
	
	sw $v0, 0($sp)	#push the coordinate on stack
	addi $sp, $sp, 4
	
	addi $t0, $t0, -1 #decrement the counter
	
	bnez $t0, get_coord_input
	
	
calculate_sizes:
	ulw WIDTH, 18(BMP) #read the bmp width
	ulw HEIGHT, 22(BMP) #read the bmp height
	ulw BITS_PP, 28(BMP) #read the amount of bits per pixel
	
	#use $t6 and $t7 as temp register
	mul $t6, WIDTH, BITS_PP
	addi $t6, $t6, 31
	li $t7, 32
	div $t6, $t7
	mflo $t6
	mul $t6, $t6, 4	#t6: length of row in bytes
	mul $t7, BITS_PP, WIDTH
	li $t8, 8
	div $t7, $t8
	mflo $t7	#t7: how many bytes in row is occupied by pixels
	sub PADDING, $t6, $t7
	div BITS_PP, $t8
	mflo $t8
	div $t7, $t8
	mflo PIXELS_ROW
	#move PIXELS_ROW, $t7
	
#TEST: draw one triangle
iterate:
	
	la BMP_BUFFER, (BMP)
	ulh $t1, 10(BMP_BUFFER)
	add BMP_BUFFER, BMP_BUFFER, $t1
	ulh $t0, (BMP_BUFFER)	#$t0 has the beginning of pixel array
	
#test: draw one triangle (1st one)
	


	

exit:
	li $v0, 10
	syscall


#$a0, $a1, $a2- x function arguments (type: vertices)
#$t1, $t2, $t3- y function arguments
#$a0, $a1- x and y of given point
#result in $v0
#$v0- result (1- true, 0 otherwise)
is_in_t1:
	
	sw $ra, 0($sp)
	addi $sp, $sp, 4
	#Calc sign for A1 and B1
	move $t0, $a1
	lw $a1, A1.x
	lw $a2, B1.x
	lw $t1, A1.y
	lw $t2, B1.y
	jal calc_sign
	move $t9, $v0
	
	#Calc sign for A1 and C1
	lw $a1, A1.x
	lw $a2, C1.x
	lw $t1, A1.y
	lw $t2, C1.y
	jal calc_sign
	move $t8, $v0
	
	#Calc sign for B1 and C1
	lw $a1, B1.x
	lw $a2, C1.x
	lw $t1, B1.y
	lw $t2, C1.y
	jal calc_sign
	move $t7, $v0
	
	#1 z 3 i 2 z 3
	mul $t9, $t9, $t7
	mul $t8, $t8, $t7
	mul $t7, $t8, $t9
	
	lw $ra, -4($sp)
	addi $sp, $sp, -4
	
	bgez g_t_z
		li $v0, 0
		jr $ra
	g_t_z:
		li $v0, 1
		jr $ra

#TOCONSIDER: store both values as halfwords?

#return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
calc_sign:
	sub $t4, $a0, $a2
	sub $t5, $t2, $t3
	mul $t4, $t4, $t5
	
	sub $t5, $a1, $a2
	sub $t6, $t1, $t3
	mul $t5, $t5, $t6
	
	sub $v0, $t4, $t5
	
	jr $ra`
