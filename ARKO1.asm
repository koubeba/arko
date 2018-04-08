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
	#loop_com: .asciiz "loopin\n"
	
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
	
	WHITE: .byte 255
	BLACK: .byte 0
	
	.eqv WIDTH -92($sp)
	.eqv HEIGHT -88($sp)
	.eqv BITS_PP -84($sp)
	.eqv PIXELS_ROW -80($sp)
	.eqv PADDING -76($sp)
	
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
	li $a2, 1257682
	syscall
	
	move BMP, $a1

close_bmp:
	li $v0, 16
	move $a0, BMPH
	syscall
	
	li $t0, 18
	
calculate_sizes:
	ulw $t0, 18(BMP) #read the bmp width
	sw $t0, ($sp)	#save bmp width on stack
	addi $sp, $sp, 4
	ulw $t0, 22(BMP) #read the bmp height
	sw $t0, ($sp)	#save bmp height on stack
	addi $sp, $sp, 4
	ulw $t0, 28(BMP) #read the amount of bits per pixel
	sw $t0, ($sp)	#save bits/pixel on the stack
	addi $sp, $sp, 4
	#.eqv PIXELS_ROW -80($sp)
	#.eqv PADDING -76($sp)
	
	ulw $t0, -12($sp)
	li $t1, 3
	mul $t0, $t0, $t1
	li $t1, 4
	div $t0, $t1
	mfhi $t0	#padding in bytes
	
	ulw $t1, -12($sp)
	sub $t1, $t1, $t0	#pixels/row
	
	sw $t1, ($sp)		#save pixels/row on stack
	addi $sp, $sp, 4
	
	sw $t0, ($sp)		#save padding on stack
	addi $sp, $sp, 4
	
	
	

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


loop_prep:
	addi $t1, BMP, 10
	ulw $t2, ($t1)		#read the offset beginning of pixel array
	add $s3, BMP, $t2	#s3 is the address of the beginning of the pixel array
	lw $s4, HEIGHT		#s4 holds the current y
	li $s5, 0		#s5 holds the current x
	
	lw $s0, BITS_PP		#s0 hold the amount of bits per pixel
	lw $s1, PIXELS_ROW	#s1 holds the amount of pixels per row
	lw $s6, PADDING		#s6 holds the amount of padding
	
	lbu $t4, WHITE
	lbu $t5, BLACK
	
	
#test: color red, white, red, white
#todo: add branching: 3 b/pixel or 4b/pixel?
loop:
	lw $s1, PIXELS_ROW
	lw $s6, PADDING
	row_loop:
		#------------------------------------#
		#---Color the triangle pixels--------#
		#------------------------------------#
		
		#Place the current x in $a1, y in $a2
		li $a0, 1	#second triangle only, for now
		or $a1, $s5, $zero
		or $a2, $s4, $zero
		
		jal is_point_in_triangle
		move $s7, $v0
		
		li $a0, 0
		or $a1, $s5, $zero
		or $a2, $s4, $zero
		jal is_point_in_triangle 
		
		lbu $t4, WHITE
		lbu $t5, BLACK
		
		bnez $v0, is_in_1st
		bnez $s7, red
		b white
		
		is_in_1st:
		beqz $s7, black
		
		li $a0, 1
		or $a1, $s5, $zero
		or $a2, $s4, $zero
		
		jal calculate_z
		move $s7, $v0
		
		li $a0, 0
		or $a1, $s5, $zero
		or $a2, $s4, $zero
		jal calculate_z
		move $t9, $v0
		
		lbu $t4, WHITE
		lbu $t5, BLACK
		
		bge $s7, 10, red
		b black
		
		
		black:
		sb $t5,($s3)	#store byte in a buffer
		sb $t5,1($s3)
		sb $t5,2($s3)
		addi $s3, $s3, 3
		b increment
		red:
		sb $t5, ($s3)
		sb $t5, 1($s3)
		sb $t4, 2($s3)
		addi $s3, $s3, 3
		b increment
		white:
		sb $t4, ($s3)	#store byte in a buffer
		sb $t4, 1($s3)
		sb $t4, 2($s3)
		addi $s3, $s3, 3
		
		increment:
		addi $s1, $s1, -1	#one pixel has been saved
		addi $s5, $s5, 1
	bnez $s1, row_loop
		#add padding
	beqz $s6, no_padding
	add_padding:
		sb $t5, ($s3)	#store byte in a buffer
		sb $t5, 1($s3)	#store byte in a buffer
		sb $t5, 2($s3)	#store byte in a buffer
		addi $s3, $s3, 3
		
		addi $s6, $s6, -1
	bnez $s6, add_padding
	no_padding:
	addi $s4, $s4, -1
	li $s5, 0
	
	bnez $s4, loop		#when all rows were iterated through, stop.

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
	li $a2, 1257682
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



#a0: 1 or 2 triangle (0 for first, 1 for second)
#a1...a2 coords of the given point	
is_point_in_triangle:

	sw $s3, ($sp)
	sw $s4, 4($sp)
	sw $s5, 8($sp)
	sw $s6, 12($sp)
	sw $s7, 16($sp)
	addi $sp, $sp, 20
	
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0

	bnez $a0, triangle2
	triangle1:
		lw $t0, -92($sp)	#ax
		lw $t1, -88($sp)	#ay
		lw $t2, -80($sp)	#bx
		lw $t3, -76($sp)	#by
		lw $t4, -68($sp)	#cx
		lw $t5, -64($sp)	#cy
		b calculate
	triangle2:
		lw $t0, -56($sp)
		lw $t1, -52($sp)
		lw $t2, -44($sp)
		lw $t3, -40($sp)
		lw $t4, -32($sp)
		lw $t5, -28($sp)
	calculate:
		sub $t6, $a1, $t2	#x-Bx
		sub $t7, $t1, $t3	#Ay-By
		
		mul $t6, $t6, $t7
		
		sub $t7, $t0, $t2
		sub $t8, $a2, $t3
		
		mul $t7, $t7, $t8
		
		sub $t6, $t6, $t7
		
		
		
		sub $t7, $a1, $t4
		sub $t8, $t3, $t5
		
		mul $t7, $t7, $t8
		
		sub $t8, $t2, $t4
		sub $t9, $a2, $t5
		
		mul $t8, $t8, $t9
		
		sub $t7, $t7, $t8
		
		
		sub $t8, $a1, $t0
		sub $t9, $t5, $t1
		
		mul $t8, $t8, $t9
		
		sub $t9, $t4, $t0
		sub $s3, $a2, $t1
		
		mul $t9, $t9, $s3
		
		sub $t8, $t8, $t9
		
		sge $t1, $t6, 0
		sge $t2, $t7, 0
		sge $t3, $t8, 0
		
		bne $t1, $t2, false
		bne $t2, $t3, false
		b true
		
	
		
		false:
		li $v0, 0
		b return
		
		true:
		li $v0, 1
		b return
	
	return:
	lw $s3, -20($sp)
	lw $s4, -16($sp)
	lw $s5, -12($sp)
	lw $s6, -8($sp)
	lw $s7, -4($sp)
	addi $sp, $sp, -20
	jr $ra

#a0: 1 or 2 triangle (0 for first, 1 for second)
#a1...a2 coords of the given point	
#v0: result
calculate_z:
	sw $s3, ($sp)
	sw $s4, 4($sp)
	sw $s5, 8($sp)
	sw $s6, 12($sp)
	sw $s7, 16($sp)
	addi $sp, $sp, 20
	
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	
	bnez $a0, triangle22
	triangle11:
		lw $t0, -92($sp)	#x1
		lw $t1, -88($sp)	#y1
		lw $t2, -84($sp)	#z1
		
		lw $t3, -80($sp)	#x2
		lw $t4, -76($sp)	#y2
		lw $t5, -72($sp)	#z2
		
		lw $t6, -68($sp)	#x3
		lw $t7, -64($sp)	#y3
		lw $t8, -60($sp)	#z3
		b calculatee
	triangle22:
		lw $t0, -56($sp)	#ax
		lw $t1, -52($sp)	#ay
		lw $t2, -48($sp)	#az
		
		lw $t3, -44($sp)	#bx
		lw $t4, -40($sp)	#by
		lw $t5, -36($sp)	#bz
		
		lw $t6, -32($sp)	#cx
		lw $t7, -28($sp)	#cy
		lw $t8, -24($sp)	#cz
	calculatee:
		sub $t9, $t3, $t0	#Bx - Ax
		sub $s3, $t7, $t1	#Cy - Ay
		mul $s4, $s3, $t9	#(Bx-Ax)(Cy-Ay)
		
		sub $t9, $t6, $t0	#Cx - Ax
		sub $s3, $t4, $t1	#By - Ay
		mul $s5, $s3, $t9	#(Cx-Ax)(By-Ay)
		
		sub $s4, $s4, $s5	#(Bx-Ax)(Cy-Ay) - (Cx-Ax)(By-Ay)
		
		#$s4- det
		
		#-----------------------------------------------------------------------------------------------------#
		#-- z = Az + {[(Bx-Ax)-(Cx-Ax)(Bz-Az)](y-Ay) - [(By-Ay)(Cz-Az) - (Cy-Ay)(Bz-Az)](x-Ax)}/det-----------#
		#-----------------------------------------------------------------------------------------------------#
		
		sub $t9, $t3, $t0	#Bx - Ax
		sub $s3, $t8, $t2	#Cz - Az
		mul $s5, $t9, $s3	#(Bx-Ax)(Cz-Az)
		
		sub $t9, $t6, $t0	#Cx-Ax
		sub $s3, $t5, $t2	#bz-az
		mul $s6, $t9, $s3	#(Cx-Ax)(Bz-Az)
		
		sub $s5, $s5, $s6	#(Bx-Ax)(Cz-Az) - (Cx-Ax)(Bz-Az)
		sub $t9, $a2, $t1	#y - Ay
		mul $s5, $s5, $t9	#[(Bx-Ax)(Cz-Az) - (Cx-Ax)(Bz-Az)](y-Ay)
		
		
		sub $t9, $t4, $t1	#By - Ay
		sub $s3, $t8, $t2	#Cz-Az
		mul $s6, $t9, $s6	#(By-Ay)(Cz-Az)
		
		sub $t9, $t7, $t1	#Cy-Ay
		sub $s3, $t5, $t2	#Bz-Az
		mul $s7, $t9, $s3 	#(Cy-Ay)(Bz-Az)
		
		sub $s6, $s6, $s7	#(By-Ay)(Cz-Az) - (Cy-Ay)(Bz-Az)
		sub $t9, $a1, $t0	#x-Ax
		mul $s6, $s6, $t9	#[(By-Ay)(Cz-Az) - (Cy-Ay)(Bz-Az)](x - Ax)
		
		#-------------------------------------------------#
		#---TODO: implement a fixed point arithmetic------#
		#-------------------------------------------------#
		
		sub $s5, $s5, $s6 	#[(Bx-Ax)(Cz-Az) - (Cx-Ax)(Bz-Az)](y-Ay) - [(By-Ay)(Cz-Az) - (Cy-Ay)(Bz-Az)](x - Ax)
		div $s5, $s5, $s4	#{[(Bx-Ax)(Cz-Az) - (Cx-Ax)(Bz-Az)](y-Ay) - [(By-Ay)(Cz-Az) - (Cy-Ay)(Bz-Az)](x - Ax)}/det
		
		add $v0, $s5, $t2	#result
	returnn:
	lw $s3, -20($sp)
	lw $s4, -16($sp)
	lw $s5, -12($sp)
	lw $s6, -8($sp)
	lw $s7, -4($sp)
	addi $sp, $sp, -20
	jr $ra
