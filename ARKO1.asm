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
	loop_com: .asciiz "loopin\n"
	
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
	
	lw $t0, -12($sp)
	lw $t1, -4($sp)
	mul $t0, $t0, $t1
	addi $t0, $t0, 31
	li $t1, 32
	div $t0, $t1
	mflo $t0
	li $t1, 4
	mul $t0, $t0, $t1 	#row size in bytes
	
	li $v0, 1
	move $a0, $t0
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	#Calculate amount of bytes per pixel:
	li $t1, 8
	lw $t2, -4($sp)		#Get bits/pixel
	div $t2, $t2, $t1	#Divide bits/pixel by 8
	
	li $v0, 1
	move $a0, $t2
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	#Divide row size by amount of bytes/pixel:
	div $t0, $t2
	mflo $t3	#Quotient is the number of pixels in a row
	mfhi $t1	#Remainder is the amount of pixel/padding
	
	li $v0, 1
	move $a0, $t3
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	#push the PIXELS_ROW on stacl
	sw $t3, ($sp)
	addi $sp, $sp, 4
	
	mul $t1, $t1, $t2
	
	li $v0, 1
	move $a0, $t1
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	#push the padding on stack
	sw $t1, ($sp)
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
	
	lb $t4, WHITE
	lb $t5, BLACK
	
	li $v0, 1
	addi $a0, $s1, 0
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	li $v0, 1
	addi $a0, $s6, 0
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	li $v0, 1
	addi $a0, $s4, 0
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	
#test: color red, white, red, white
#todo: add branching: 3 b/pixel or 4b/pixel?
loop:
	lw $s1, PIXELS_ROW
	lw $s6, PADDING
	row_loop:
		sb $t4, ($s3)	#store byte in a buffer
		sb $t4, 1($s3)
		sb $t4, 2($s3)
		addi $s3, $s3, 3
	
		addi $s1, $s1, -1	#one pixel has been saved
	bnez $s1, row_loop
		#add padding
	beqz $s6, no_padding
	add_padding:
		sb $t4, ($s3)	#store byte in a buffer
		sb $t4, 1($s3)
		sb $t4, 2($s3)
		addi $s3, $s3, 3
		
		addi $s6, $s6, -1
	bnez $s6, add_padding
	no_padding:
	addi $s4, $s4, -1
	
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
	

