#d####################################################################
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
promptA: .asciiz "pressed a"

pL1xpos: .word 0x0000000, 0x0000010, 0x000002B, 0x00000E, 0x000001B
pL1ypos: .word 0x0000038, 0x0000030, 0x0000028, 0x00001E, 0x0000011
pL1width: .word 0x0000010, 0x0000012, 0x0000010, 0x000012, 0x0000015
backgroundColours: .space 65536
xposChar: .word 0x0000000
yposChar: .word 0x0000000
addressChar: .word 0x10008000
addressBee: .word 0x10008000
addressWater: .word 0x10008528
charJumpTimer: .word 10
charHorDir:	.word 1
# 0 - left
# 1 - right
charVerDir: .word 0
# 0 - otherwise
# 1 - jumping up
jumpTimer: .word 0

.eqv BASE_ADDRESS 0x10008000

.eqv ZERO 0
.eqv WIDTH 64
.eqv WIDTH_PIXELS 256
.eqv CHARACTER_WIDTH 5
.eqv CHARACTER_WIDTH_PIXELS 20
.eqv CHARACTER_HEIGHT 9
.eqv UNIT_WIDTH 4

.eqv JUMP_TIME_LENGTH 15

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
.eqv INDIGO 0x1740f5
.eqv BABY_BLUE 0xbdc7f3

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

#s0 is horizontal direction 0 means left 1 means right
# s1 is vertical direction: 0 means on platform 1 means up,-1 means moving down


.text

#####################################################

	la $t3, xposChar		#load char xposition address
	lw $t4, 0($t3)			# loads xposition

	addi $t4, $zero, 0		# set xposition variable to 0

	sw $t4, 0($t3)			# Update xpos variable in memory
	
	jal DRAW_L1			# Draw Level 1
	
	#la $s0, xpos
	#la $s1, ypos
	
	# Draw character
	#lw $s3, 0($s0)		#$s3 = xpos[i]
	#sw $s3, -4($sp) 	# push xpos onto stack
	#lw $s3, 0($s1)		#$s3 = ypos[i]
	#sw $s3, -8($sp) 	# push ypos onto stack
	
	#addi $sp, $sp, -8 	# move pointer to make space
	
	#la $a0, addressChar
	#lw $a0, 0($a0)
	
	#jal DRAW_CHAR
	
	#la $a0, addressChar
	#lw $a0, 0($a0)
	
	#jal DRAW_CHAR_RIGHT
	
	la $a0, addressBee
	lw $a0, 0($a0)
	
	jal DRAW_BEE
	
	la $a0, addressWater
	lw $a0, 0($a0)
	
	jal DRAW_WATER

	
	
	la $a0, BASE_ADDRESS
	#lw $a0, ($a0)
	
	#jal DRAW_CHAR_RIGHT
	
	j MAIN

################## Main Loop #################################
MAIN:
	li $v0, 32
	li $a0, 35 	# Wait one second (1000 milliseconds)
	syscall

	#keyboard press
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened

AFTER_KEYPRESS:

	ble $s1, $zero, ACTIVATE_GRAVITY	# If not jumping then activate gravity
	jal MOVE_UP							# If jumping, then move up
	J MAIN_DRAW_CHAR					# skip gravity

ACTIVATE_GRAVITY:
	jal GRAVITY

MAIN_DRAW_CHAR:

	la $a0, addressChar		#Get character address
	lw $a0, 0($a0)

	beq $s0, $zero, LEFT
RIGHT:
	jal DRAW_CHAR_RIGHT
	J AFTER_CHAR_DRAW
LEFT:
	jal DRAW_CHAR_LEFT		# Draw Character

AFTER_CHAR_DRAW:

	j MAIN
############# Keyboard press ###############################

keypress_happened:
	lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before
	beq $t2, 0x71, QUIT # ASCII code of 'q' is 0x71 or 113 in decimal
	beq $t2, 0x61, MOVE_LEFT # ASCII code of 'a' is 0x61 or 97 in decimal
	beq $t2, 0x64, MOVE_RIGHT # ASCII code of 'd' is 0x61 or 100 in decimal
	beq $t2, 0x77, START_JUMP #ASCII code of 'w' is 0x77 or 119 in decimal
	j AFTER_KEYPRESS


################## Quit Game #################################
QUIT:
	# Prints the end prompt text
	li $v0, 4		      
	la $a0, promptEnd
	syscall  

	li $v0, 10 # terminate the program gracefully
	syscall

################## Player Movement ######################################
###### Start jump ##############
START_JUMP:

	bne 	$s1, $zero, END_OF_START_JUMP	# If already jumping or falling, don't jump
	addi 	$s1, $zero, 1					# set jump variable to true

	la 		$t0, jumpTimer					# get address of jump timer

	addi 	$t1, $zero, JUMP_TIME_LENGTH	# get time that jump should last
	sw 		$t1, 0($t0)						# update time length of jump

END_OF_START_JUMP:
	jr 		$ra								# return to caller

############### Move Up ###################################
MOVE_UP:

	addi $sp, $sp, -4	# store $ra on stack
	sw $ra, 0($sp)

	#addi $t0, $zero, CHARACTER_HEIGHT 	# store character height
	#addi $t1, $zero, WIDTH_PIXELS 		# store character height
	#mult $t0, $t1						# get relative address below bottom left of character
	#mflo $t2

	la $t0, addressChar		# get character address
	lw $t1, 0($t0)			# get character position

	addi $t2, $t1, -WIDTH_PIXELS				# store address of nit above top left of character

	addi $t3, $t2, CHARACTER_WIDTH_PIXELS 		# store unit above right corner of character

UP_LOOP:
	bgt $t2, $t3, APPLY_JUMP					# if done checking units above, then move up
	lw $t5, 0($t2)								# load colour at current unit
	beq $t5, DARK_GREEN, DONE_JUMP				# if unit is a platform then move down
	addi $t2, $t2, UNIT_WIDTH					# get address of next unit
	j UP_LOOP									# jump to beginning of loop

APPLY_JUMP:

	addi $t2, $t1, -WIDTH_PIXELS				# move up one row
	sw $t2, 0($t0)								# update character address

	add $a0, $zero, $t1							# store character position in $a0
	jal ERASE_CHAR								# erase Character
	#jal DRAW_SKY								# draw the sky

	la $t3, jumpTimer							# get address of jump timer
	lw $t4, 0($t3)								# load time remaining jump

	addi $t4, $t4, -1							# subtract 1 from timer
	sw $t4, 0($t3)								# supdate time remaining of jump

	ble $t4, $zero, DONE_JUMP					# finish jump if remaining jump time is set to 0
	j END_OF_JUMP_FUNC							# otherwise branch to end of the function

DONE_JUMP:

	addi $s1, $zero, 0							# set jumping variable to false

END_OF_JUMP_FUNC:

	lw $ra, 0($sp)								# pop off prev stored $ra
	addi $sp, $sp, 4							# update stack pointer
	jr $ra

############# Move left ############################

MOVE_LEFT:

	# Prints  prompt text
	li $v0, 4		      
	la $a0, promptA
	syscall  

	la $t2, addressChar		#load address for var
	lw $t1, 0($t2)			# load character address

	add $a0, $t1, $zero		# Store char address in argument register
	
	jal ERASE_CHAR			# Erase Character

	la $t3, xposChar		#load char xposition address
	lw $t4, 0($t3)			# loads xposition

	ble	$t4, $zero, LEFT_UPDATE_DIR	# if xpos is less than 0, don't update the xposition


	addi $t4, $t4, -1		# Update xpos variable (subtract 1)
	sw $t4, 0($t3)			# Update xpos in data

	addi $t1, $t1, -4		# Move character to the left by one unit (4 pixels)

	sw $t1, 0($t2)			# Update char address

	la $a0, addressChar		# Get character address
	lw $a0, 0($a0)

LEFT_UPDATE_DIR:

	addi $t3, $zero, 0		# Update direction to left (0 means left)
	la $t2, charHorDir		# load address of character horizontal direction
	sw $t3, 0($t2)			# Update direction variable

	addi $s0, $zero, 0		# Update direction to left (0 means left)

	#jal DRAW_SKY			# draw the sky

	j AFTER_KEYPRESS

##################### Move right #########################

MOVE_RIGHT:

	la 		$t2, addressChar		#load address for var
	lw 		$t1, 0($t2)			# load character address

	add 	$a0, $t1, $zero		# Store char address in argument register
	
	jal 	ERASE_CHAR			# erase Character


	la 		$t3, xposChar		# load char xposition address
	lw 		$t4, 0($t3)			# loads xposition

	addi 	$t5, $zero, WIDTH					# store width of screen
	addi 	$t5, $t5, -CHARACTER_WIDTH			# caluclate right most xpos where the character remains on screen
	bge		$t4, $t5, RIGHT_UPDATE_DIR			# if xpos is greater than 64 (the width), don't update the xposition

	addi 	$t7, $zero, CHARACTER_WIDTH_PIXELS		# store characters width in pixels
	add 	$t5, $t7, $t1							# store top unit on right of character

	addi 	$t6, $zero, CHARACTER_HEIGHT	# store character height
	add 	$t7, $zero, $zero				# loop iterator
	
RIGHT_COLLISION:
	bge 	$t7, $t6, UPDATE_XPOS					# check each pixel on the right of the character
	lw 		$t8, 0($t5)								# load colour at current unit
	beq 	$t8, DARK_GREEN, RIGHT_UPDATE_DIR		# Check if pixel is a platform, if it is, do not move right
	addi 	$t5, $t5, WIDTH_PIXELS					# get address of next unit
	addi 	$t7, $t7, 1								# inecrease iterator
	j 		RIGHT_COLLISION							# jump to beginning of loop

UPDATE_XPOS:
	addi 	$t4, $t4, 1			# Update xpos variable (add 1)
	sw 		$t4, 0($t3)			# Update xpos in data

	addi 	$t1, $t1, 4			# Move character to the right by one unit (4 pixels)

	sw 		$t1, 0($t2)			# Update char address

	#la 		$a0, addressChar	# Get character address
	#lw 		$a0, 0($a0)

RIGHT_UPDATE_DIR:

	addi 	$t3, $zero, 1		# Update direction to right (1 means right)
	la 		$t2, charHorDir		# load address of character horizontal direction
	sw 		$t3, 0($t2)			# Update direction variable

	addi 	$s0, $zero, 1		# Update direction to right (1 means right)

	#jal 	DRAW_SKY			# draw the sky

	j 		AFTER_KEYPRESS

############## Gravity ################################
GRAVITY:

	addi $sp, $sp, -4	# store $ra on stack
	sw $ra, 0($sp)

	addi $t0, $zero, CHARACTER_HEIGHT 	# store character height
	addi $t1, $zero, WIDTH_PIXELS 		# store character height
	mult $t0, $t1						# get relative address below bottom left of character
	mflo $t2

	la $t0, addressChar		# get character address
	lw $t1, 0($t0)			# get character position

	add $t2, $t2, $t1		# get address below bottom left of character
	#lw $t3, 0($t2)			# get colour below bottom left of character			

	#beq $t2, DARK_GREEN, MOVE_DOWN_COMPLETE		# Check if bottom left corner is on a platform

	#add $a0, $zero, $t1		# store character position in $a0
	#jal ERASE_CHAR			# erase Character
	#jal DRAW_SKY			# draw the sky

	addi $t3, $zero, CHARACTER_WIDTH 	# store character width
	addi $t4, $zero, UNIT_WIDTH			# store the number of pixels per unit
	mult $t3, $t4						# get numbers of pixels to bottom right corner
	mflo $t3							# store in $t3

	add $t3, $t3, $t2					# store address of unit under bottom right corner

GRAVITY_LOOP:
	bge $t2, $t3, APPLY_GRAVITY					# if done checking units below
	lw $t5, 0($t2)								# load colour at current unit
	beq $t5, DARK_GREEN, ON_PLATFORM		# Check if pixel is a platform
	addi $t2, $t2, UNIT_WIDTH					# get address of next unit
	j GRAVITY_LOOP								# jump to beginning of loop
	#lw $t3, 0($t2)			# get colour below bottom left of character

	#add $t2, $t2, $t3			# get address below bottom right corner of character
	#lw $t3, 0($t2)			# get colour below bottom left of character

	#beq $t3, DARK_GREEN, MOVE_DOWN_COMPLETE		# Check if bottom right corner is on a platform

	#addi $t2, $t1, WIDTH_PIXELS			# move down one row
	#sw $t2, 0($t0)						# update character address

ON_PLATFORM:
	addi $s1, $zero, 0				# set jump variable to 0 to indicate on platform
	j MOVE_DOWN_COMPLETE			# jump to end of function
	

APPLY_GRAVITY:

	addi $t2, $t1, WIDTH_PIXELS			# move down one row
	sw $t2, 0($t0)						# update character address
	
	addi $s1, $zero, -1					# set jump variable to -1 to indicate moving down

	add $a0, $zero, $t1		# store character position in $a0
	jal ERASE_CHAR			# erase Character
	#jal DRAW_SKY			# draw the sky

MOVE_DOWN_COMPLETE:

	lw $ra, 0($sp)			# pop off prev stored $ra
	addi $sp, $sp, 4		# update stack pointer
	jr $ra

################ Repaint ##################################
	
#####################  Painting Functions  ################################


############## Draw background ############################

DRAW_BACKGROUND:            	

	addi $sp, $sp, -4 		# move pointer to make space
	sw $ra, 0($sp) 			# save $ra to the stack

	li $t1, LIGHT_GREEN 			# $t2 stores the green colour code
	li $t3, BLUE					# $t3 stores the blue colour code

	addi $t4, $zero, BASE_ADDRESS
	addi $t5, $t4, 16384 			# Store bottom right unit in t5
	
	la $t6, backgroundColours 		# $t0 stores the base address for display
	
	
IF:	
	bge $t4, $t5, END
	sw $t1, 0($t4)					# paint green background
	addi $t4, $t4, 4
	j IF
END:
	
	jal DRAW_SKY

	lw $t3, 0($sp)		# pop prev $ra from stack
	addi $sp, $sp, 4	# update stacker pointer
	jr $t3				# jump to caller function

############## Draw sky #############################

DRAW_SKY:
	addi $sp, $sp, -4 		# move pointer to make space
	sw $ra, 0($sp) 			# save $ra to the stack

    # Draw left blue rectangle
	
	li $t3, SKY_XPOS # Load platform 1 xpos
	sw $t3, -4($sp) # push xpos onto stack
	li $t3, SKY_YPOS # Load platform 1 ypos
	sw $t3, -8($sp) # push xpos onto stack
	li $t3, SKY_WIDTH # Load platform 1 ypos
	sw $t3, -12($sp) # push xpos onto stack
	li $t3, SKY_HEIGHT # Load platform 1 ypos
	sw $t3, -16($sp) # push xpos onto stack
	li $t3, SKY_COLOR # Load platform 1 ypos
	sw $t3, -20($sp) # push xpos onto stack
	
	addi $sp, $sp, -20 # move pointer to make space
	
	jal DRAW_REC
	
	# Draw right blue rectangle
	
	li $t3, SKY2_XPOS # Load platform 1 xpos
	sw $t3, -4($sp) # push xpos onto stack
	li $t3, SKY2_YPOS # Load platform 1 ypos
	sw $t3, -8($sp) # push xpos onto stack
	li $t3, SKY2_WIDTH # Load platform 1 ypos
	sw $t3, -12($sp) # push xpos onto stack
	li $t3, SKY2_HEIGHT # Load platform 1 ypos
	sw $t3, -16($sp) # push xpos onto stack
	li $t3, SKY2_COLOR # Load platform 1 ypos
	sw $t3, -20($sp) # push xpos onto stack
	
	addi $sp, $sp, -20 # move pointer to make space
	
	jal DRAW_REC

	lw $t3, 0($sp)		# pop prev $ra from stack
	addi $sp, $sp, 4	# update stacker pointer
	jr $t3				# jump to caller function

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
	
	la $t0, pL1xpos
	la $t1, pL1ypos
	la $t2, pL1width
	
	# Draw platform rectangle
	
	add $t0, $t0, $t8	# t3 = addr(xpos) + i
	add $t1, $t1, $t8	# t3 = addr(ypos) + i
	add $t2, $t2, $t8	# t3 = addr(width) + i
	
	
	# push arguments onto stack
	lw $t3, 0($t0)		#$t3 = xpos[i]
	sw $t3, -4($sp) 	# push xpos onto stack
	lw $t3, 0($t1)		#$t3 = ypos[i]
	sw $t3, -8($sp) 	# push ypos onto stack
	lw $t3, 0($t2)		#$t3 = width[i]
	sw $t3, -12($sp) 	# push width onto stack
	addi $t3, $zero, 2 	# set height of platform to 2
	sw $t3, -16($sp) 	# push height onto stack
	li $t3, DARK_GREEN 	# make platforms dark green
	sw $t3, -20($sp) 	# push colour onto stack
	
	addi $sp, $sp, -20 	# move pointer to make space
	
	jal DRAW_REC
	
	addi $t8, $t8, 4	# update index
	j DRAW_PFORM_LOOP	# jump to beginning of loop
	
	
END_DRAW_L1:
	lw $t3, 0($sp)		# pop prev $ra from stack
	addi $sp, $sp, 4	# update stacker pointer
	jr $t3				# jump to prev function
	
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

################# Draw character #################################

#DRAW_CHAR:

	#addi $sp, $sp, -4		# move stack pointer
	#sw $ra, 0($sp)			#store caller address

	#la $to, $s0		# get address of char direction 
	#lw $t0, 0($t0)			# get value of direction
	#beq $s0, $zero, DRAW_LEFT

################# Draw character facing RIGHT #############################

DRAW_CHAR_RIGHT:
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

############ Draw character facing LEFT ########################

DRAW_CHAR_LEFT:
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

############ Repaint character green ########################

ERASE_CHAR:
	add $t0, $zero, LIGHT_GREEN   # Store light green
	sw $t0, 0($a0)			
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
	sw $t0, 768($a0)
	sw $t0, 1024($a0)
	sw $t0, 1028($a0)
	sw $t0, 1032($a0)
	sw $t0, 1036($a0)
	sw $t0, 1040($a0)
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
	
DRAW_WATER:
	add $t0, $zero, INDIGO   	# Store Indigo
	sw $t0, 0($a0)			# Colour specified pixels yellow
	sw $t0, 4($a0)
	sw $t0, 8($a0)
	sw $t0, 12($a0)
	sw $t0, 256($a0)
	sw $t0, 260($a0)
	sw $t0, 264($a0)
	sw $t0, 268($a0)
	sw $t0, 512($a0)
	sw $t0, 516($a0)
	sw $t0, 520($a0)
	sw $t0, 524($a0)
	sw $t0, 768($a0)
	sw $t0, 772($a0)
	sw $t0, 776($a0)
	sw $t0, 780($a0)
	sw $t0, 1024($a0)
	sw $t0, 1028($a0)
	sw $t0, 1032($a0)
	sw $t0, 1036($a0)
	
	add $t0, $zero, BABY_BLUE   	# Store baby blue
	sw $t0, 264($a0)			# Colour specified pixels baby
	sw $t0, 520($a0)
	
	jr $ra
	

sw $t2, 0($t4)
li $v0, 10 # terminate the program gracefully
syscall
