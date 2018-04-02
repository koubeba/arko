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
	
	WHITE: .byte 0xFF
	BLACK: .byte 0x00
	
	.eqv WIDTH -92($sp)
	.eqv HEIGHT -88($sp)
	.eqv BITS_PP -84($sp)
	.eqv PIXELS_ROW -76($sp)
	.eqv PADDING -80($sp)
	
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
	
calculate_sizes:
	ulw $t0, 18(BMP) #read the bmp width
	sw $t0, ($sp)
	addi $sp, $sp, 4
	ulw $t0, 22(BMP) #read the bmp height
	sw $t0, ($sp)
	addi $sp, $sp, 4
	ulw $t0, 28(BMP) #read the amount of bits per pixel
	sw $t0, ($sp)
	addi $sp, $sp, 4
	
	#use $t6 and $t7 as temp register
	lw $t1, WIDTH
	lw $t2, BITS_PP
	mul $t6, $t1, $t2
	addi $t6, $t6, 31
	li $t7, 32
	div $t6, $t7
	mflo $t6
	mul $t6, $t6, 4	#t6: length of row in bytes
	lw $t1, WIDTH
	lw $t2, BITS_PP
	mul $t7, $t1, $t2
	li $t8, 8
	div $t7, $t8
	mflo $t7	#t7: how many bytes in row is occupied by pixels
	sub $t0, $t6, $t7
	sw $t0, ($sp)	#store PADDING on stack
	addi $sp, $sp, 4
	lw $t0, BITS_PP
	div $t0, $t8
	mflo $t8
	div $t7, $t8
	mflo $t0	#store PIXELS_ROW on stack
	sw $t0, ($sp)
	addi $sp, $sp, 4
	#move PIXELS_ROW, $t7
	
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
	
	
calc_counter:
	lw $t1, BITS_PP
	li $t2, 8
	div $t0, $t1, $t2
	lw $t1, PIXELS_ROW
	mul $t0, $t0, $t1
	lw $t1, PADDING
	add $s0, $t0, $t1	#s0: bytes in a row
	lw $s1, HEIGHT		#s1: height
	lw $t2, PIXELS_ROW
	lw $t3, BITS_PP
	mul $t2, $t2, $t3
	li $t3, 8
	div $s2, $t2, $t3	#s2: bytes per pixels in a row
	lw $s2, PIXELS_ROW

	#s0, s1, s2- counters
#TEST: draw one triangle
iterate:
	la $t1, (BMP)
	ulh $t0, 10($t1)
	add $t1, $t1, $t0
	ulh $s3, ($t1)	#$s3 is the beginning of pixel array
	li $s4, 0		#s4: x
	li $s5, 0		#s5: y
	
loop:
#test: draw one triangle (1st one)
	#a0- x of current pixel, a1- y of current pixel
	move $a0, $s4
	move $a1, $s5
	jal is_in_t1
	
	bnez $v0, color_red
	color_black:
		lb $t0, BLACK
		sb $t0, ($s3)
		sb $t0, 1($s3)
		sb $t0, 2($s3)
		addi $s3, $s3, 3
		addi $s2, $s2, -1
		bnez $s2, no_padding
		sw $t2, PADDING
	add_padding:
		lb $t0, WHITE
		sb $t0, ($s3)
		addi $t2, $t2, -1
		bnez $t2, add_padding
		lw $s2, PIXELS_ROW
	no_padding:
		addi $s1, $s1, -1
		bnez $s1, loop
	color_red:
		lb $t0, BLACK
		sb $t0, ($s3)
		lb $t0, WHITE
		sb $t0, 1($s3)
		sb $t0, 2($s3)
		addi $s3, $s3, 3
		addi $s2, $s2, -1
		
		li $v0, 34
		move $a0, $s3
		syscall
		
		li $v0, 4
		la $a0, newline
		syscall
		
		
		bnez $s2, no_padding_r
		sw $t2, PADDING
	add_padding_r:
		lb $t0, WHITE
		sb $t0, ($s3)
		addi $t2, $t2, -1
		bnez $t2, add_padding
		lw $s2, PIXELS_ROW
	no_padding_r:
		addi $s1, $s1, -1
		bnez $s1, loop
open_bmp_write:
	li $v0, 13
	la $a0, bmp_path
	li $a1, 1	#open for writing
	li $a2, 0
	syscall
	move BMPH, $v0
	
	blez $v0, exit
	
write_bmp:
	li $v0, 15
	la $a0, (BMPH)
	la $a1, buffer
	li $a2, 61440
	syscall
	
	move BMP, $a1

close_bmp_write:
	li $v0, 16
	move $a0, BMPH
	syscall
	
	li $t0, 18

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
	
	bgez $t7, g_t_z
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
	
	jr $ra
