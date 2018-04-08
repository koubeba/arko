.data
	newline: .asciiz "\n"
	prompt: .asciiz "Enter coord"
.text

main:
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 5
	syscall
	
	move $a1, $v0
	
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 5
	syscall
	
	move $a2, $v0
	
	jal calculate_z
	
	move $s0, $v0
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 4
	la $a0, newline
	
	li $v0, 10
	syscall

calculate_z:
		li $t0, 1	#Ax
		li $t1, 1	#Ay
		li $t2, 1	#Az
		
		li $t3, 1	#Bx
		li $t4, 100	#By
		li $t5, 100	#Bz
		
		li $t6, 100	#Cx
		li $t7, 1	#cy
		li $t8, 100	#Cz
		
	calculate:
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
		
		#------------------------------------------------------------------#
		#--Caclulate the [(Bx-Ax)(Cz-Az)-(Cx-Ax)(Bz-Az)](y-Ay)-------------#
		#------------------------------------------------------------------#
		
		sub $t9, $t3, $t0	#Bx - Ax
		sub $s5, $t8, $t2	#Cz-Az
		mul $t9, $t9, $s5	#(Bx-ax)(Cz-Az)
		
		sub $s5, $t6, $t0	#Cx-Ax
		sub $s6, $t5, $t2	#Bz - Az
		mul $s5, $s5, $s6	#(Cx-Ax)(Bz-Az)
		
		sub $t9, $t9, $s5	#(Bx-Ax)(Cz-AZ) - (Cx-Ax)(Bz-Az)
		
		sub $s5, $a2, $t1	#(y-Ay)
		
		#----------------#
		mul $t9, $t9, $s5	#(y-Ay)[(Bx-Ax)(Cz-AZ) - (Cx-Ax)(Bz-Az)]
		#----------------#
		
		#------------------------------------------------------------------#
		#--Calculate the [(By-Ay)(Cz-Az) - (Cy-Ay)(Bz-Az)](x-Ax)-----------#
		#------------------------------------------------------------------#
		
		sub $s5, $t4, $t1	#By-Ay
		sub $s6, $t8, $t2	#Cz-Az
		mul $s5, $s5, $s6	#(By-Ay)(Cz-Az)
		
		sub $s6, $t7, $t1	#Cy-Ay
		sub $s7, $t5, $t2	#Bz-Az
		mul $s6, $s6, $s7	#(Cy-Ay)(Bz-AZ)
		
		sub $s5, $s5, $s6	#(By-Ay)(Cz-Az) - (Cy-ay)(Bz-Az)
		
		sub $s7, $a1, $t0	#(x-Ax)
		
		#----------------#
		mul $s5, $s5, $s7	#(x-Ax)[(By-Ay)(Cz-Az) - (Cy-ay)(Bz-Az)]
		#----------------#
		
		sub $t9, $t9, $s5	#(y-Ay)[(Bx-Ax)(Cz-AZ) - (Cx-Ax)(Bz-Az)] - (x-Ax)[(By-Ay)(Cz-Az) - (Cy-ay)(Bz-Az)]
		div $t9, $t9, $s4	#.../det
		
		add $v0, $t9, $t2	#...+Az
	returnn:
	jr $ra
