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

pL1xpos: .word 0x0000000, 0x0000010, 0x0000024, 0x00000E, 0x000001B
pL1ypos: .word 0x0000038, 0x0000030, 0x0000028, 0x00001E, 0x0000011
pL1width: .word 0x0000010, 0x0000012, 0x0000015, 0x000012, 0x0000015
backgroundColours: .space 65536
xposChar: .word 0x0000000
yposChar: .word 0x0000000
addressChar: .word 0x10008090
addressBee: .word 0x10008000


.eqv BASE_ADDRESS 0x10008000
#.eqv LIGHT_GREEN 0x489658
#.eqv DARK_GREEN 0x8df086
.eqv BROWN 0x735032
.eqv LIGHT_BROWN 0xde9557
.eqv BLACK 0x000000
.eqv LIGHT_PURPLE 0xcd96d5
.eqv DARK_PURPLE 0x7861bb
.eqv DARK_GREEN 0x489658
.eqv LIGHT_GREEN 0x8df086
.eqv BLUE 0x86e9f0 
.eqv PINK 0xeb63e4
.eqv YELLOW 0xffdf1a
.eqv DARK_BLUE 0x4e4d59

.eqv P1_XPOS  0x000000010
.eqv P1_YPOS 0x0000034
.eqv P1_COLOR  0x86e9f0
.eqv P1_WIDTH  0x0000000C
.eqv P1_HEIGHT 0x00000002

.eqv SKY_XPOS  0x000000000
.eqv SKY_YPOS 0x00000000
.eqv SKY_COLOR  0x86e9f0
.eqv SKY_WIDTH  0x00000001
.eqv SKY_HEIGHT 0x00000040

.eqv SKY2_XPOS  0x00000003F
.eqv SKY2_YPOS 0x00000000
.eqv SKY2_COLOR  0x86e9f0
.eqv SKY2_WIDTH  0x00000001
.eqv SKY2_HEIGHT 0x00000040

.eqv level1NumPlatform 4

.text

#####################################################

	
	# Draw level 1
	
	jal DRAW_L1
	
	#la $s0, xpos
	#la $s1, ypos
	
	# Draw character
	#lw $s3, 0($s0)		#$s3 = xpos[i]
	#sw $s3, -4($sp) 	# push xpos onto stack
	#lw $s3, 0($s1)		#$s3 = ypos[i]
	#sw $s3, -8($sp) 	# push ypos onto stack
	
	#addi $sp, $sp, -8 	# move pointer to make space
	
	la $a0, addressChar
	lw $a0, 0($a0)
	
	#jal DRAW_CHAR
	
	la $a0, addressChar
	lw $a0, 0($a0)
	
	jal DRAW_CHAR_RIGHT
	
	la $a0, addressBee
	lw $a0, 0($a0)
	
	jal DRAW_BEE
	
	li $v0, 32
	li $a0, 5000 # Wait one second (1000 milliseconds)
	syscall
	
	#keyboard press
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened
	
Final:	#sw $t2, 0($t4)
	li $v0, 10 # terminate the program gracefully
	syscall

keypress_happened:
	lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before
	beq $t2, 0x61, respond_to_a # ASCII code of 'a' is 0x61 or 97 in decimal
	j Final
	
respond_to_a:
	# Prints the end prompt text
	li $v0, 4		      
	la $a0, promptEnd
	syscall  
	
	la $a0, BASE_ADDRESS
	#lw $a0, ($a0)
	
	jal DRAW_CHAR_RIGHT
	
	j Final
	
	
#####################  Painting Functions  ################################


############## Draw background ############################

DRAW_BACKGROUND:            	

	addi $sp, $sp, -4 		# move pointer to make space
	sw $ra, 0($sp) 			# save $ra to the stack

	li $s1, LIGHT_GREEN 			# $t2 stores the green colour code
	li $s3, BLUE					# $t3 stores the blue colour code

	addi $s4, $zero, BASE_ADDRESS
	addi $s5, $s4, 16384 			# Store bottom right unit in s5
	
	la $s6, backgroundColours 		# $t0 stores the base address for display
	
	
IF:	
	bge $s4, $s5, END
	sw $s1, 0($s4)					# paint green background
	addi $s4, $s4, 4
	j IF
END:
	
	jal DRAW_SKY

	lw $s3, 0($sp)		# pop prev $ra from stack
	addi $sp, $sp, 4	# update stacker pointer
	jr $s3				# jump to caller function

############## Draw sky #############################

DRAW_SKY:
	addi $sp, $sp, -4 		# move pointer to make space
	sw $ra, 0($sp) 			# save $ra to the stack

    # Draw left blue rectangle
	
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
	
	# Draw right blue rectangle
	
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

	lw $s3, 0($sp)		# pop prev $ra from stack
	addi $sp, $sp, 4	# update stacker pointer
	jr $s3				# jump to caller function

############# Draw Level 1 #############################

DRAW_L1:

	# Draw background

	addi $sp, $sp, -4 		# move pointer to make space
	sw $ra, 0($sp) 			# save $ra to the stack

	jal DRAW_BACKGROUND  	# Draw background


	# draw level 1 platforms
	add $t8, $zero, $zero 		# define t8 to be platform index
	li $t9, level1NumPlatform	# store num of platforms in level 1
	
	add $t7, $t7, 4			# store 4 in t7
	mult $t9, $t7			# mult num of platforms by 4
	mflo $t9				# store num platforms * 4 in $t9
	
	addi $sp, $sp, -4 		# move pointer to make space
	sw $ra, 0($sp) 			# save $ra to the stack

	
	
DRAW_PFORM_LOOP:

	 
	# Draw platforms for the level
	bge $t8, $t9, END_DRAW_L1  	# continue loop until index = num of platforms
	
	# Get platform at current index 
	
	la $s0, pL1xpos
	la $s1, pL1ypos
	la $s2, pL1width
	
	# Draw platform rectangle
	
	add $s0, $s0, $t8	# t3 = addr(xpos) + i
	add $s1, $s1, $t8	# t3 = addr(ypos) + i
	add $s2, $s2, $t8	# t3 = addr(width) + i
	
	
	# push arguments onto stack
	lw $s3, 0($s0)		#$s3 = xpos[i]
	sw $s3, -4($sp) 	# push xpos onto stack
	lw $s3, 0($s1)		#$s3 = ypos[i]
	sw $s3, -8($sp) 	# push ypos onto stack
	lw $s3, 0($s2)		#$s3 = width[i]
	sw $s3, -12($sp) 	# push width onto stack
	addi $s3, $zero, 2 	# set height of platform to 2
	sw $s3, -16($sp) 	# push height onto stack
	li $s3, DARK_GREEN 	# make platforms dark green
	sw $s3, -20($sp) 	# push colour onto stack
	
	addi $sp, $sp, -20 	# move pointer to make space
	
	jal DRAW_REC
	
	addi $t8, $t8, 4	# update index
	j DRAW_PFORM_LOOP	# jump to beginning of loop
	
	
END_DRAW_L1:
	lw $s3, 0($sp)		# pop prev $ra from stack
	addi $sp, $sp, 4	# update stacker pointer
	jr $s3				# jump to prev function
	
################### Draw a rectangle ##################################

# Draw_Rec func takes in arguments: xpos, ypos, width, height, colour

DRAW_REC:				
	lw $t0, 0($sp)		# Pop colour off the stack
	lw $t1, 4($sp)		# Pop height off the stack
	lw $t2, 8($sp)		# Pop width off the stack
	lw $t3, 12($sp)		# Pop ypos off the stack
	lw $t4, 16($sp)		# Pop xpos off the stack
	
	addi $sp, $sp, 20	# Update stack pointer
	
	# Get address of position
	addi $t5, $zero, 256 	# Store 256 in temp variable
	mult $t5, $t3			# Multiply ypos by 256
	mflo $t3 				# store ypoz * 256
	
	addi $t5, $zero, 4 		# Store 4 in temp variable
	mult $t5, $t4			# Multiply xpos by 4
	mflo $t4 				# store xpos * 4
	
	add $t3, $t3, $t4				# calculate address relative to BASE_ADDRESS
	addi $t3, $t3, BASE_ADDRESS		# Store address of top left corner of rectangle
	
	add $t5, $zero, $zero   # iterator for rows
	add $t6, $zero, $zero   # iterator for column
	
	add $t4, $zero, $t3 	# define t4 to keep track of current address
	
MOVE_ROW: 
	bge $t5, $t1, REC_END	# if completed filling required height number of rows
	
COLOR_ROW:	
	
	bge $t6, $t2, ROW_END	# Check if filled the correct number of columns
	sw $t0, 0($t4)			# Fill current address with correct colour
	
	
	addi $t4, $t4, 4	# Move current address to next unit
	addi $t6, $t6, 1 	# increase col by 1
	
	j COLOR_ROW
	
ROW_END:
	addi $t5, $t5, 1 		# increase row by 1
	addi $t6, $zero, 0 		# reset col to index 0
	addi $t7, $zero, 256 	# temp var to hold 256
	mult $t5, $t7			# mult row num by 256
	mflo $t7				# store product in t7
	
	add $t4, $t3, $t7		# Move current address to next row by adding t7 val to original address

	j MOVE_ROW
REC_END:
	jr $ra
	
################# Draw character facing left #############################

DRAW_CHAR:
	add $t0, $zero, BROWN   # Store brown
	sw $t0, 0($a0)			# Colour specified pixels brown
	sw $t0, 4($a0)
	sw $t0, 8($a0)
	sw $t0, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 256($a0)
	sw $t0, 260($a0)
	sw $t0, 512($a0)
	sw $t0, 516($a0)
	sw $t0, 768($a0)
	sw $t0, 772($a0)
	sw $t0, 776($a0)
	sw $t0, 780($a0)
	
	add $t0, $zero, LIGHT_BROWN   # Paint pixels light brown
	sw $t0, 264($a0)
	sw $t0, 268($a0)
	sw $t0, 272($a0)
	sw $t0, 520($a0)
	sw $t0, 524($a0)
	sw $t0, 528($a0)
	sw $t0, 1792($a0)
	sw $t0, 1796($a0)
	sw $t0, 1804($a0)
	sw $t0, 1808($a0)
	
	add $t0, $zero, DARK_PURPLE   # Paint pixels dark purple
	sw $t0, 784($a0)
	sw $t0, 1024($a0)
	sw $t0, 1028($a0)
	sw $t0, 1032($a0)
	sw $t0, 1036($a0)
	sw $t0, 1040($a0)
	
	add $t0, $zero, LIGHT_PURPLE   # Paint pixels light purple
	sw $t0, 1280($a0)
	sw $t0, 1284($a0)
	sw $t0, 1288($a0)
	sw $t0, 1292($a0)
	sw $t0, 1296($a0)
	sw $t0, 1536($a0)
	sw $t0, 1540($a0)
	sw $t0, 1544($a0)
	sw $t0, 1548($a0)
	sw $t0, 1552($a0)

	add $t0, $zero, BLACK   # Paint pixels light purple
	sw $t0, 2048($a0)
	sw $t0, 2052($a0)
	sw $t0, 2060($a0)
	sw $t0, 2064($a0)
	jr $ra

############ Draw character facing right ########################

DRAW_CHAR_RIGHT:
	add $t0, $zero, BROWN   # Store brown
	sw $t0, 0($a0)			# Colour specified pixels brown
	sw $t0, 4($a0)
	sw $t0, 8($a0)
	sw $t0, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 272($a0)
	sw $t0, 528($a0)
	sw $t0, 768($a0)
	sw $t0, 772($a0)
	sw $t0, 776($a0)
	sw $t0, 780($a0)
	sw $t0, 784($a0)
	
	add $t0, $zero, LIGHT_BROWN   # Paint pixels light brown
	sw $t0, 256($a0)
	sw $t0, 260($a0)
	sw $t0, 512($a0)
	sw $t0, 516($a0)
	sw $t0, 264($a0)
	sw $t0, 268($a0)
	sw $t0, 520($a0)
	sw $t0, 524($a0)
	sw $t0, 1792($a0)
	sw $t0, 1796($a0)
	sw $t0, 1804($a0)
	sw $t0, 1808($a0)
	
	add $t0, $zero, DARK_PURPLE   # Paint pixels dark purple
	sw $t0, 768($a0)
	sw $t0, 1024($a0)
	sw $t0, 1028($a0)
	sw $t0, 1032($a0)
	sw $t0, 1036($a0)
	sw $t0, 1040($a0)
	
	add $t0, $zero, LIGHT_PURPLE   # Paint pixels light purple
	sw $t0, 1280($a0)
	sw $t0, 1284($a0)
	sw $t0, 1288($a0)
	sw $t0, 1292($a0)
	sw $t0, 1296($a0)
	sw $t0, 1536($a0)
	sw $t0, 1540($a0)
	sw $t0, 1544($a0)
	sw $t0, 1548($a0)
	sw $t0, 1552($a0)

	add $t0, $zero, BLACK   # Paint pixels light purple
	sw $t0, 2048($a0)
	sw $t0, 2052($a0)
	sw $t0, 2060($a0)
	sw $t0, 2064($a0)
	jr $ra
		
########## Draw bee #####################	

DRAW_BEE:
	add $t0, $zero, YELLOW   # Store yellow
	sw $t0, 0($a0)			# Colour specified pixels yellow
	sw $t0, 8($a0)
	sw $t0, 16($a0)
	sw $t0, 256($a0)
	sw $t0, 264($a0)
	sw $t0, 272($a0)
	sw $t0, 512($a0)
	sw $t0, 520($a0)
	sw $t0, 528($a0)
	
	add $t0, $zero, DARK_BLUE   # Store dark blue
	sw $t0, 4($a0)				# Colour specified pixels blue
	sw $t0, 12($a0)
	sw $t0, 260($a0)
	sw $t0, 268($a0)
	sw $t0, 516($a0)
	sw $t0, 524($a0)
	
	jr $ra
	

sw $t2, 0($t4)
li $v0, 10 # terminate the program gracefully
syscall
