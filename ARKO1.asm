.globl main
.data 
	testprompt: .asciiz "width: "
	prompt: .asciiz "\tHello there! Enter coordinates for vertices A, B, C for 2 triangles.\n\tEach coordinate consists of x, y, z.\n"
	
	promptA: .asciiz "Enter coordinates of the A vertex "
	promptB: .asciiz "Enter coordinates of the B vertex "
	promptC: .asciiz "Enter coordinates of the C vertex "
	
	prompt1: .asciiz "of the 1st triangle.\n"
	prompt2: .asciiz "of the 2nd triangle.\n"
	
	promptx: .asciiz "Enter x coordinate: "
	prompty: .asciiz "Enter y coordinate: "
	promptz: .asciiz "Enter z coordinate: "
	newline: .asciiz "\n"
	
	buffer: .space 1257682
	
	maskz: .word 511
	masky: .word 1048064
	maskx: .word 536346624
	maskcolor: .word 2147483648
	
	.eqv A1 $s0
	.eqv B1 $s1
	.eqv C1 $s2
	
	.eqv A2 $s3
	.eqv B2 $s4
	.eqv C2 $s5
	
	.eqv BMPH $s6
	.eqv BMP $s7
	
	.eqv WHITE 0xFFFFFF
	.eqv BLACK 0x000000
	
	.eqv WIDTH $t0
	.eqv HEIGHT $t1
	.eqv BITS_PP $t3
	.eqv PIXELS_ROW $t4
	.eqv PADDING $t5
	.eqv BMP_BUFFER $t6
	
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
	

input_A1:
	li $v0, 4	#print instructions
	la $a0, promptA
	syscall 
	li $v0, 4	
	la $a0, prompt1
	syscall 
	
	#addi A1, A1, 2147483648
	
	li $v0, 4	#print string: ask for x coordinate
	la $a0, promptx
	syscall
	
	li $v0, 5	#read the x coordinate as integer
	syscall
	sll $t0, $v0, 20	#shift the x on the right position
	add A1, A1, $t0		#place the shifted x value in the correct register
	
	li $v0, 4	#print string: ask for y coordinate
	la $a0, prompty
	syscall
	
	li $v0, 5	#read the y coordinate as integer
	syscall
	sll $t0, $v0, 9		#shift the y on the right position
	add A1, A1, $t0		#place the shifted y value in the correct register	
	
	li $v0, 4	#print string: ask for z coordinate
	la $a0, promptz
	syscall
	
	li $v0, 5	#read the z coordinate as integer
	syscall
	addi $t0, $v0, 0	#shift the z on the right position
	add A1, A1, $t0		#place the shifted z value in the correct register
	
input_B1:
	li $v0, 4	#print instructions
	la $a0, promptB
	syscall 
	li $v0, 4	
	la $a0, prompt1
	syscall 
	
	#addi A1, A1, 2147483648
	
	li $v0, 4	#print string: ask for x coordinate
	la $a0, promptx
	syscall
	
	li $v0, 5	#read the x coordinate as integer
	syscall
	sll $t0, $v0, 20	#shift the x on the right position
	add B1, B1, $t0		#place the shifted x value in the correct register
	
	li $v0, 4	#print string: ask for y coordinate
	la $a0, prompty
	syscall
	
	li $v0, 5	#read the y coordinate as integer
	syscall
	sll $t0, $v0, 9		#shift the y on the right position
	add B1, B1, $t0		#place the shifted y value in the correct register	
	
	li $v0, 4	#print string: ask for z coordinate
	la $a0, promptz
	syscall
	
	li $v0, 5	#read the z coordinate as integer
	syscall
	addi $t0, $v0, 0	#shift the z on the right position
	add B1, B1, $t0		#place the shifted z value in the correct register
	
input_C1:
	li $v0, 4	#print instructions
	la $a0, promptC
	syscall 
	li $v0, 4	
	la $a0, prompt1
	syscall 
	
	#addi A1, A1, 2147483648
	
	li $v0, 4	#print string: ask for x coordinate
	la $a0, promptx
	syscall
	
	li $v0, 5	#read the x coordinate as integer
	syscall
	sll $t0, $v0, 20	#shift the x on the right position
	add C1, C1, $t0		#place the shifted x value in the correct register
	
	li $v0, 4	#print string: ask for y coordinate
	la $a0, prompty
	syscall
	
	li $v0, 5	#read the y coordinate as integer
	syscall
	sll $t0, $v0, 9		#shift the y on the right position
	add C1, C1, $t0		#place the shifted y value in the correct register	
	
	li $v0, 4	#print string: ask for z coordinate
	la $a0, promptz
	syscall
	
	li $v0, 5	#read the z coordinate as integer
	syscall
	addi $t0, $v0, 0	#shift the z on the right position
	add C1, C1, $t0		#place the shifted z value in the correct register
	
	
	
input_A2:
	li $v0, 4	#print instructions
	la $a0, promptA
	syscall 
	li $v0, 4	
	la $a0, prompt2
	syscall 
	
	#addi A1, A1, 2147483648
	
	li $v0, 4	#print string: ask for x coordinate
	la $a0, promptx
	syscall
	
	li $v0, 5	#read the x coordinate as integer
	syscall
	sll $t0, $v0, 20	#shift the x on the right position
	add A2, A2, $t0		#place the shifted x value in the correct register
	
	li $v0, 4	#print string: ask for y coordinate
	la $a0, prompty
	syscall
	
	li $v0, 5	#read the y coordinate as integer
	syscall
	sll $t0, $v0, 9		#shift the y on the right position
	add A2, A2, $t0		#place the shifted y value in the correct register	
	
	li $v0, 4	#print string: ask for z coordinate
	la $a0, promptz
	syscall
	
	li $v0, 5	#read the z coordinate as integer
	syscall
	addi $t0, $v0, 0	#shift the z on the right position
	add A2, A2, $t0		#place the shifted z value in the correct register
	
input_B2:
	li $v0, 4	#print instructions
	la $a0, promptB
	syscall 
	li $v0, 4	
	la $a0, prompt2
	syscall 
	
	#addi A1, A1, 2147483648
	
	li $v0, 4	#print string: ask for x coordinate
	la $a0, promptx
	syscall
	
	li $v0, 5	#read the x coordinate as integer
	syscall
	sll $t0, $v0, 20	#shift the x on the right position
	add B2, B2, $t0		#place the shifted x value in the correct register
	
	li $v0, 4	#print string: ask for y coordinate
	la $a0, prompty
	syscall
	
	li $v0, 5	#read the y coordinate as integer
	syscall
	sll $t0, $v0, 9		#shift the y on the right position
	add B2, B2, $t0		#place the shifted y value in the correct register	
	
	li $v0, 4	#print string: ask for z coordinate
	la $a0, promptz
	syscall
	
	li $v0, 5	#read the z coordinate as integer
	syscall
	addi $t0, $v0, 0	#shift the z on the right position
	add B2, B2, $t0		#place the shifted z value in the correct register
	
input_C2:
	li $v0, 4	#print instructions
	la $a0, promptC
	syscall 
	li $v0, 4	
	la $a0, prompt2
	syscall 
	
	#addi A1, A1, 2147483648
	
	li $v0, 4	#print string: ask for x coordinate
	la $a0, promptx
	syscall
	
	li $v0, 5	#read the x coordinate as integer
	syscall
	sll $t0, $v0, 20	#shift the x on the right position
	add C2, C2, $t0		#place the shifted x value in the correct register
	
	li $v0, 4	#print string: ask for y coordinate
	la $a0, prompty
	syscall
	
	li $v0, 5	#read the y coordinate as integer
	syscall
	sll $t0, $v0, 9		#shift the y on the right position
	add C2, C2, $t0		#place the shifted y value in the correct register	
	
	li $v0, 4	#print string: ask for z coordinate
	la $a0, promptz
	syscall
	
	li $v0, 5	#read the z coordinate as integer
	syscall
	addi $t0, $v0, 0	#shift the z on the right position
	add C2, C2, $t0		#place the shifted z value in the correct register
	
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
iterate:
	la BMP_BUFFER, (BMP)
	ulh $t7, 10(BMP_BUFFER)
	add BMP_BUFFER, BMP_BUFFER, $t7
	addi BMP_BUFFER, BMP_BUFFER, -1
	ulh $t8, (BMP_BUFFER)

exit:
	li $v0, 10
	syscall

