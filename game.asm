#####################################################################
#
# CSCB58 Winter 2024 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Madison Majarais
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

# Bitmap display starter code
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
promptEnd: .asciiz "End of program "

#pL1xpos .word 0x0000030 0x0000028 0x0000010
#pL1ypos .word 0x0000030 0x0000020 0x0000010
#pL1width .word 0x0000010 0x0000012 0x000000B

.eqv BASE_ADDRESS 0x10008000

.eqv DARK_GREEN 0x489658
.eqv P1_XPOS  0x000000010
.eqv P1_YPOS 0x0000034
.eqv P1_COLOR  0x86e9f0
.eqv P1_WIDTH  0x0000000C
.eqv P1_HEIGHT 0x00000002

.eqv SKY_XPOS  0x000000000
.eqv SKY_YPOS 0x00000000
.eqv SKY_COLOR  0x86e9f0
.eqv SKY_WIDTH  0x00000009
.eqv SKY_HEIGHT 0x00000040

.eqv SKY2_XPOS  0x000000037
.eqv SKY2_YPOS 0x00000000
.eqv SKY2_COLOR  0x86e9f0
.eqv SKY2_WIDTH  0x00000009
.eqv SKY2_HEIGHT 0x00000040

.eqv level1NumPlatform 3

.text
	li $s0, BASE_ADDRESS 	# $t0 stores the base address for display
	li $s1, 0x8df086 	# $t2 stores the green colour code
	li $s3, 0x86e9f0 	# $t3 stores the blue colour code

	addi $s4, $zero, BASE_ADDRESS
	addi $s5, $s4, 16384 # Store bottom right unit in s5
	
	#paint green background
IF:	bge $s4, $s5, END
	sw $s1, 0($s4)
	addi $s4, $s4, 4
	j IF
END:

	
	# Draw a rectangle
	
	li $s3, SKY_XPOS # Load platform 1 xpos
	sw $s3, -4($sp) # push xpos onto stack
	li $s3, SKY_YPOS # Load platform 1 ypos
	sw $s3, -8($sp) # push xpos onto stack
	li $s3, SKY_WIDTH # Load platform 1 ypos
	sw $s3, -12($sp) # push xpos onto stack
	li $s3, SKY_HEIGHT # Load platform 1 ypos
	sw $s3, -16($sp) # push xpos onto stack
	li $s3, SKY_COLOR # Load platform 1 ypos
	sw $s3, -20($sp) # push xpos onto stack
	
	addi $sp, $sp, -20 # move pointer to make space
	
	jal DRAW_REC
	
	# Draw a rectangle 2
	
	li $s3, SKY2_XPOS # Load platform 1 xpos
	sw $s3, -4($sp) # push xpos onto stack
	li $s3, SKY2_YPOS # Load platform 1 ypos
	sw $s3, -8($sp) # push xpos onto stack
	li $s3, SKY2_WIDTH # Load platform 1 ypos
	sw $s3, -12($sp) # push xpos onto stack
	li $s3, SKY2_HEIGHT # Load platform 1 ypos
	sw $s3, -16($sp) # push xpos onto stack
	li $s3, SKY2_COLOR # Load platform 1 ypos
	sw $s3, -20($sp) # push xpos onto stack
	
	addi $sp, $sp, -20 # move pointer to make space
	
	jal DRAW_REC
	
	# Draw a rectangle 3
	
	li $s3, P1_XPOS # Load platform 1 xpos
	sw $s3, -4($sp) # push xpos onto stack
	li $s3, P1_YPOS # Load platform 1 ypos
	sw $s3, -8($sp) # push xpos onto stack
	li $s3, P1_WIDTH # Load platform 1 ypos
	sw $s3, -12($sp) # push xpos onto stack
	li $s3, P1_HEIGHT # Load platform 1 ypos
	sw $s3, -16($sp) # push xpos onto stack
	li $s3, DARK_GREEN # Load platform 1 ypos
	sw $s3, -20($sp) # push xpos onto stack
	
	addi $sp, $sp, -20 # move pointer to make space
	
	jal DRAW_REC
	
	# Prints the prompt A text
	li $v0, 4		      
	la $a0, promptEnd
	syscall    
	
	#sw $t2, 0($t4)
	li $v0, 10 # terminate the program gracefully
	syscall
	
	
DRAW_L1:
	# draw level 1 platforms
	add $t8, $zero, $zero 		# define t0 to be platform index
	li $t9, level1NumPlatform	
	bge $t8, $t9, END_DRAW_L1
	
	# Get platform at current index 
	
	
	
	
	# Draw platform rectangle
	
	li $s3, P1_XPOS # Load platform 1 xpos
	sw $s3, -4($sp) # push xpos onto stack
	li $s3, P1_YPOS # Load platform 1 ypos
	sw $s3, -8($sp) # push xpos onto stack
	li $s3, P1_WIDTH # Load platform 1 ypos
	sw $s3, -12($sp) # push xpos onto stack
	li $s3, P1_HEIGHT # Load platform 1 ypos
	sw $s3, -16($sp) # push xpos onto stack
	li $s3, DARK_GREEN # Load platform 1 ypos
	sw $s3, -20($sp) # push xpos onto stack
	
END_DRAW_L1:
	
	
	
DRAW_REC:			# Draw_Rec func takes in arguments: xpos, ypos, width, height, colour
	lw $t0, 0($sp)		# Pop colour off the stack
	lw $t1, 4($sp)		# Pop height off the stack
	lw $t2, 8($sp)		# Pop width off the stack
	lw $t3, 12($sp)		# Pop ypos off the stack
	lw $t4, 16($sp)		# Pop xpos off the stack
	
	addi $sp, $sp, 20	# Updaste stack pointer
	
	# Get address of position
	addi $t5, $zero, 256 	# Store 256 in temp variable
	mult $t5, $t3		# Multiply ypos by 256
	mflo $t3 		# store ypoz * 256
	
	addi $t5, $zero, 4 	# Store 4 in temp variable
	mult $t5, $t4		# Multiply xpos by 4
	mflo $t4 		# store xpos * 4
	
	add $t3, $t3, $t4	# calculate address relative to BASE_ADDRESS
	addi $t3, $t3, BASE_ADDRESS	# Store address of top left corner of rectangle
	
	add $t5, $zero, $zero   # iterator for rows
	add $t6, $zero, $zero   # iterator for column
	
	add $t4, $zero, $t3 	# define t4 to keep track of current address
	
MOVE_ROW: 
	bge $t5, $t1, REC_END	# if completed filling required height number of rows
	
COLOR_ROW:	
	
	bge $t6, $t2, ROW_END	# Check if filled the correct number of columns
	sw $t0, 0($t4)		# Fill current address with correct colour
	
	
	addi $t4, $t4, 4	# Move current address to next unit
	addi $t6, $t6, 1 	# increase col by 1
	
	j COLOR_ROW
	
ROW_END:
	addi $t5, $t5, 1 	# increase row by 1
	addi $t6, $zero, 0 	# reset col to index 0
	addi $t7, $zero, 256 	# temp var to hold 256
	mult $t5, $t7		# mult row num by 256
	mflo $t7		# store product in t7
	
	add $t4, $t3, $t7	# Move current address to next row by adding t7 val to original address

	j MOVE_ROW
REC_END:
	jr $ra
	

sw $t2, 0($t4)
li $v0, 10 # terminate the program gracefully
syscall
