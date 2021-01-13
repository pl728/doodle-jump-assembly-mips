######################################################################
# CSC258H5S Fall 2020 Assembly Final Project
# University of Toronto, St. George
#
# Student: Patrick, 1005804872
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# --> MILESTONE 5 <--
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. M4: Scoreboard
# 2. M4: Game Over/ retry
# 3. M5: Music / Sound effects 
# 4. M5: Oppoonents / lethal creatures
# 5. M5: Fancier graphics - monster design, game over, scoreboard design
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
.data
screenWidth: 	.word   32
screenHeight:	.word   32

doodleColor: 	.word	0xe35349 # red
lightgreen:     .word   0x008000 # Light green, for vaccinated state
darkGreen:      .word   0x00a862 # dark green, for vaccinated state
darkRedColor:   .word   0x8b0000 # dark red
platformColor: 	.word 	0x263780 # dark blue
backgroundColor:.word	0xffffff # white
blackColor:     .word   0x000000
vaccineBlue:    .word   0x03c4ff # light blue 

platformColor1: .word 0x03fcd3
platformColor2: .word 0x0d5eff
platformColor3: .word 0xb300ff
platformColor4: .word 0xff0059
platformColor5: .word 0x00ff6a
platformColor6: .word 0x80ff00
platformColor7: .word 0xffcc00
platformColor8: .word 0xcf4f00


coronaPinkDark: .word   0xd622d6 # dark pink
coronaPinkLight:.word   0xfa8cfa # light pink
maskBlue:       .word   0x33bee8 # light blue
gray:           .word   0x7d7d7d # gray

doodleX:        .word   3214
doodleY:        .word   31
direction:      .word   1     # initial direction up

platform1X:  .word 0
platform2X:  .word 0
platform3X:  .word 0
platform4X:  .word 0
platform5X:  .word 0
platform6X:  .word 0
platform7X:  .word 0
platform8X:  .word 0
platform1Y:  .word 0
platform2Y:  .word 0
platform3Y:  .word 0
platform4Y:  .word 0
platform5Y:  .word 0
platform6Y:  .word 0
platform7Y:  .word 0
platform8Y:  .word 0

coronaX:     .word 0
coronaY:     .word 0
vaccineX:    .word 0
vaccineY:    .word 0
vaccineTaken:.word 0    # 0 if not taken, 1 if taken

jumpCounter:.word 0
jumpHeight: .word 16
gameSpeed:  .word 40

lostMessage:	.asciiz "You have died.... Your score was: "
replayMessage:	.asciiz "Would you like to replay?"
score:          .word 0

.text
main:
# - Initialize all variables
# - Randomly generate three platforms
Init: 
    # initial doodle (x, y)
    # li $t0, 14
    li $t0, 12814
    sw $t0, doodleX
    li $t0, 30
    sw $t0, doodleY

    # initial direction - up
    # increment jumpCounter on each redraw
    li $t0, 18
    sw $t0, jumpHeight
    li $t0, 1
    sw $t0, direction

    # random x coordinate for 2 platforms (platform 2, platform 3), 
    # first one is fixed at middle
    # random generator v0=42 (a0, a1) -> a0
    li $t0, 13
    sw $t0, platform1X

    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform2X

    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform3X

    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform4X

    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform5X

    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform6X

    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform7X

    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform8X

    li $t0, 31
    sw $t0, platform1Y

    li $t0, 24
    sw $t0, platform2Y

    li $t0, 15
    sw $t0, platform3Y

    li $v0, 42
    li $a0, 20
    li $a1, 31
    syscall
    sw $a0, platform4Y

    li $v0, 42
    li $a0, 21
    li $a1, 31
    syscall
    sw $a0, platform5Y

    li $v0, 42
    li $a0, 21
    li $a1, 31
    syscall
    sw $a0, platform6Y

    li $v0, 42
    li $a0, 21
    li $a1, 31
    syscall
    sw $a0, platform7Y

    li $v0, 42
    li $a0, 21
    li $a1, 31
    syscall
    sw $a0, platform8Y

    # initially, vaccine is not taken
    li $t0, 0
    sw $t0, vaccineTaken

    # generate random location for coronavirus
    li $v0, 42
    li $a0, 0
    li $a1, 31
    syscall
    sw $a0, coronaX

    li $t0, -10
    sw $t0, coronaY

    # set game speed
    li $t0, 19
    sw $t0, gameSpeed

    # initialize score to 2020
    li $t0, 2020
    sw $t0, score
       
# draw initial screen
jal DrawScreen
li $s0, 1       # acts as jumpCounter, tells us how much more to move up
InputCheck:
    # check for new input, if new input check for j, k, s press,
    # update doodleX, doodleY, platforms. 
    # re-draw screen and pause.
    lw $s1, score
    lw $a0, doodleX
    lw $a1, doodleY
    lw $a3, direction
    li $s2, 0   # vaccineTaken

    # get the input from the keyboard
	li $t0, 0xffff0000
	lw $t1, ($t0)
	andi $t1, $t1, 0x0001

	# if (equal to zero) no new input -> SelectDrawDirection 
	beqz $t1, MoveMiddle    # if no new input, draw in same direction
	lw $t2, 0xffff0004

    # input was j
	beq $t2, 97, MoveLeft
    # input was k
	beq $t2, 100, MoveRight

    j MoveMiddle

# update x, then y
MoveMiddle:
    # If direction is down
    blt $a3, 0, CheckCollisionDownPlatformY
    # Else
    # If at some y level, scroll
    blt $a1, 12, Scroll
    j MoveUp
MoveLeft:
    # update X coordinate
    add $a0, $a0, -2
    sw $a0, doodleX
    # If direction is down
    blt $a3, 0, CheckCollisionDownPlatformY
    # Else
    # If at some y level, scroll
    blt $a1, 12, Scroll
    j MoveUp
MoveRight:
    # update x coordinate
    add $a0, $a0, 2
    sw $a0, doodleX
    # If direction is down
    blt $a3, 0, CheckCollisionDownPlatformY
    # Else
    # If at some y level, scroll
    blt $a1, 12, Scroll
    j MoveUp

ChangeDirectionToDown:
    add $a3, $zero, -1
    sw $a3, direction
    j InputCheck

ChangeDirectionToUp:
    add $a3, $zero, 1
    sw $a3, direction
    j InputCheck
Scroll:
    add $s0, $s0, 1

    lw $t0, platform1Y
    lw $t1, platform2Y
    lw $t2, platform3Y
    lw $t3, platform4Y
    lw $t4, platform5Y
    lw $t5, coronaY

    lw $t7, platform6Y
    lw $t8, platform7Y
    lw $t6, platform8Y

    add $t0, $t0, 1
    add $t1, $t1, 1
    add $t2, $t2, 1
    add $t3, $t3, 1
    add $t4, $t4, 1
    add $t5, $t5, 1
    add $t7, $t7, 1
    add $t8, $t8, 1
    add $t6, $t6, 1

    sw $t0, platform1Y
    sw $t1, platform2Y
    sw $t2, platform3Y
    sw $t3, platform4Y
    sw $t4, platform5Y
    sw $t5, coronaY
    sw $t7, platform6Y
    sw $t8, platform7Y
    sw $t6, platform8Y

    bgt $t0, 31, GenerateNewPlatform1
    bgt $t1, 31, GenerateNewPlatform2
    bgt $t2, 31, GenerateNewPlatform3
    bgt $t3, 31, GenerateNewPlatform4
    bgt $t4, 31, GenerateNewPlatform5
    bgt $t5, 45, GenerateNewCorona
    bgt $t7, 31, GenerateNewPlatform6
    bgt $t8, 31, GenerateNewPlatform7
    bgt $t6, 31, GenerateNewPlatform8

    jal DrawScreen
    lw $t0, jumpHeight
    beq $s0, $t0, ChangeDirectionToDown

    j CheckCollisionCoronaUp

GenerateNewPlatform1:
    add $s1, $s1, 473
    sw $s1, score
    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform1X
    li $t0, 0
    sw $t0, platform1Y
    jal DrawScreen
    lw $t0, jumpHeight
    beq $s0, $t0, ChangeDirectionToDown

    j InputCheck

GenerateNewPlatform2:
    add $s1, $s1, 473
    sw $s1, score
    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform2X
    li $t0, 0
    sw $t0, platform2Y

    jal DrawScreen
    lw $t0, jumpHeight
    beq $s0, $t0, ChangeDirectionToDown

    j InputCheck

GenerateNewPlatform3:
    add $s1, $s1, 473
    sw $s1, score
    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform3X
    li $t0, 0
    sw $t0, platform3Y

    jal DrawScreen
    lw $t0, jumpHeight
    beq $s0, $t0, ChangeDirectionToDown

    j InputCheck

GenerateNewPlatform4:
    add $s1, $s1, 473
    sw $s1, score
    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform4X
    li $t0, 0
    sw $t0, platform4Y

    jal DrawScreen
    lw $t0, jumpHeight
    beq $s0, $t0, ChangeDirectionToDown

    j InputCheck

GenerateNewPlatform5:
    add $s1, $s1, 473

    sw $s1, score
    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform5X
    li $t0, 0
    sw $t0, platform5Y

    jal DrawScreen
    lw $t0, jumpHeight
    beq $s0, $t0, ChangeDirectionToDown

    j InputCheck

GenerateNewPlatform6:
    add $s1, $s1, 473
    sw $s1, score
    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform6X
    li $t0, 0
    sw $t0, platform6Y

    jal DrawScreen
    lw $t0, jumpHeight
    beq $s0, $t0, ChangeDirectionToDown

    j InputCheck

GenerateNewPlatform7:
    add $s1, $s1, 473
    sw $s1, score
    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform7X
    li $t0, 0
    sw $t0, platform7Y

    jal DrawScreen
    lw $t0, jumpHeight
    beq $s0, $t0, ChangeDirectionToDown

    j InputCheck

GenerateNewPlatform8:
    add $s1, $s1, 473
    sw $s1, score
    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, platform8X
    li $t0, 0
    sw $t0, platform8Y

    jal DrawScreen
    lw $t0, jumpHeight
    beq $s0, $t0, ChangeDirectionToDown

    j InputCheck

GenerateNewCorona:
    add $s1, $s1, 1000
    sw $s1, score
    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, coronaX
    li $t0, -7
    sw $t0, coronaY

    jal DrawScreen
    lw $t0, jumpHeight
    beq $s0, $t0, ChangeDirectionToDown
    
    j InputCheck


GenerateNewVaccine:
    add $s1, $s1, 1000
    sw $s1, score
    li $v0, 42
    li $a0, 0
    li $a1, 28
    syscall
    sw $a0, vaccineX
    li $t0, -7
    sw $t0, vaccineY

    jal DrawScreen
    lw $t0, jumpHeight
    beq $s0, $t0, ChangeDirectionToDown
    
    j InputCheck
CheckCollisionBottom:
    lw $a0, doodleX
    # If bottom, exit 
    beq $a1, 31, GameOverLoop
    j MoveDown

CheckCollisionCoronaUp:
    # If collided with corona: game over
    # Else: move up/ move down
    ###########################################
    # NorthEast Direction
    ###########################################
    lw $a0, doodleX
    lw $a1, doodleY
    lw $t2, screenWidth
    div $a0, $t2
    mfhi $a0
    CCC1X: 
        # load center of coronavirus
        lw $t0, coronaX
        lw $t1, coronaY

        # go to game over pixel
        add $t0, $t0, 0
        add $t1, $t1, -7
        # account for screen wrap around
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC1Y
        j CCC2X
    CCC1Y:
        beq $a1, $t1, checkVaccinated
        j CCC2X
    CCC2X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 1
        add $t1, $t1, -8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC2Y
        j CCC3X

    CCC2Y:
        beq $a1, $t1, checkVaccinated
        j CCC3X

    CCC3X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 2
        add $t1, $t1, -7 
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC3Y
        j CCC4X

    CCC3Y:
        beq $a1, $t1, checkVaccinated
        j CCC4X

    CCC4X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 2
        add $t1, $t1, -6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC4Y
        j CCC5X

    CCC4Y:
        beq $a1, $t1, checkVaccinated
        j CCC5X

    CCC5X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 3
        add $t1, $t1, -5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC5Y
        j CCC6X

    CCC5Y:
        beq $a1, $t1, checkVaccinated
        j CCC6X

    CCC6X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 4
        add $t1, $t1, -6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC6Y
        j CCC7X

    CCC6Y:
        beq $a1, $t1, checkVaccinated
        j CCC7X

    CCC7X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 5
        add $t1, $t1, -5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC7Y
        j CCC8X

    CCC7Y:
        beq $a1, $t1, checkVaccinated
        j CCC8X

    CCC8X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 5
        add $t1, $t1, -2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC8Y
        j CCC9X

    CCC8Y:
        beq $a1, $t1, checkVaccinated
        j CCC9X

    CCC9X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 6
        add $t1, $t1, -4
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC9Y
        j CCC10X

    CCC9Y:
        beq $a1, $t1, checkVaccinated
        j CCC10X

    CCC10X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 6
        add $t1, $t1, -3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC10Y
        j CCC11X

    CCC10Y:
        beq $a1, $t1, checkVaccinated
        j CCC11X

    CCC11X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 6
        add $t1, $t1, -1
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC11Y
        j CCC12X

    CCC11Y:
        beq $a1, $t1, checkVaccinated
        j CCC12X

    CCC12X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 7
        add $t1, $t1, -2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC12Y
        j CCC13X

    CCC12Y:
        beq $a1, $t1, checkVaccinated
        j CCC13X

    CCC13X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 8
        add $t1, $t1, -1
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC13Y
        j CCC14X

    CCC13Y:
        beq $a1, $t1, checkVaccinated
        j CCC14X

    CCC14X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 8
        add $t1, $t1, 0
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC14Y
        j CCC15X

    CCC14Y:
        beq $a1, $t1, checkVaccinated
        j CCC15X

    ###########################################
    # SouthEast Direction
    ###########################################
    CCC15X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 8
        add $t1, $t1, 1
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC15Y
        j CCC16X
    CCC15Y:
        beq $a1, $t1, checkVaccinated
        j CCC16X
    CCC16X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 8
        add $t1, $t1, 2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC16Y
        j CCC17X
    CCC16Y:
        beq $a1, $t1, checkVaccinated
        j CCC17X
    CCC17X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 7
        add $t1, $t1, 3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC17Y
        j CCC18X
    CCC17Y:
        beq $a1, $t1, checkVaccinated
        j CCC18X
    CCC18X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 6
        add $t1, $t1, 4
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC18Y
        j CCC19X
    CCC18Y:
        beq $a1, $t1, checkVaccinated
        j CCC19X
    CCC19X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 6
        add $t1, $t1, 5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC19Y
        j CCC20X
    CCC19Y:
        beq $a1, $t1, checkVaccinated
        j CCC20X
    CCC20X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 5
        add $t1, $t1, 3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC20Y
        j CCC21X
    CCC20Y:
        beq $a1, $t1, checkVaccinated
        j CCC21X
    CCC21X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 5
        add $t1, $t1, 6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC21Y
        j CCC22X
    CCC21Y:
        beq $a1, $t1, checkVaccinated
        j CCC22X
    CCC22X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 4
        add $t1, $t1, 7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC22Y
        j CCC23X
    CCC22Y:
        beq $a1, $t1, checkVaccinated
        j CCC23X
    CCC23X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 3
        add $t1, $t1, 8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC23Y
        j CCC24X
    CCC23Y:
        beq $a1, $t1, checkVaccinated
        j CCC24X
    CCC24X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 2
        add $t1, $t1, 8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC24Y
        j CCC25X
    CCC24Y:
        beq $a1, $t1, checkVaccinated
        j CCC25X
    CCC25X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 2
        add $t1, $t1, 7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC25Y
        j CCC26X
    CCC25Y:
        beq $a1, $t1, checkVaccinated
        j CCC26X
    CCC26X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 2
        add $t1, $t1, 6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC26Y
        j CCC27X
    CCC26Y:
        beq $a1, $t1, checkVaccinated
        j CCC27X
    CCC27X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 1
        add $t1, $t1, 9
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC27Y
        j CCC28X
    CCC27Y:
        beq $a1, $t1, checkVaccinated
        j CCC28X
    CCC28X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 0
        add $t1, $t1, 10
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC28Y
        j CCC29X
    CCC28Y:
        beq $a1, $t1, checkVaccinated
        j CCC29X
    ###########################################
    CCC29X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -2
        add $t1, $t1, 10
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC29Y
        j CCC30X
    CCC29Y:
        beq $a1, $t1, checkVaccinated
        j CCC30X
    CCC30X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -3
        add $t1, $t1, 9
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC30Y
        j CCC31X
    CCC30Y:
        beq $a1, $t1, checkVaccinated
        j CCC31X
    CCC31X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -4
        add $t1, $t1, 7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC31Y
        j CCC32X
    CCC31Y:
        beq $a1, $t1, checkVaccinated
        j CCC32X
    CCC32X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -4
        add $t1, $t1, 8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC32Y
        j CCC33X
    CCC32Y:
        beq $a1, $t1, checkVaccinated
        j CCC33X
    CCC33X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -5
        add $t1, $t1, 8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC33Y
        j CCC34X
    CCC33Y:
        beq $a1, $t1, checkVaccinated
        j CCC34X
    CCC34X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -6
        add $t1, $t1, 7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC34Y
        j CCC35X
    CCC34Y:
        beq $a1, $t1, checkVaccinated
        j CCC35X
    CCC35X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -7
        add $t1, $t1, 6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC35Y
        j CCC36X
    CCC35Y:
        beq $a1, $t1, checkVaccinated
        j CCC36X
    CCC36X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -7
        add $t1, $t1, 3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC36Y
        j CCC37X
    CCC36Y:
        beq $a1, $t1, checkVaccinated
        j CCC37X
    CCC37X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -8
        add $t1, $t1, 4
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC37Y
        j CCC38X
    CCC37Y:
        beq $a1, $t1, checkVaccinated
        j CCC38X
    CCC38X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -8
        add $t1, $t1, 5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC38Y
        j CCC39X
    CCC38Y:
        beq $a1, $t1, checkVaccinated
        j CCC39X
    CCC39X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -9
        add $t1, $t1, 3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC39Y
        j CCC40X
    CCC39Y:
        beq $a1, $t1, checkVaccinated
        j CCC40X
    CCC40X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -10
        add $t1, $t1, 2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC40Y
        j CCC41X
    CCC40Y:
        beq $a1, $t1, checkVaccinated
        j CCC41X
    CCC41X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -10
        add $t1, $t1, 1
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC41Y
        j CCC42X
    CCC41Y:
        beq $a1, $t1, checkVaccinated
        j CCC42X
    CCC42X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -10
        add $t1, $t1, 0
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC42Y
        j CCC43X
    CCC42Y:
        beq $a1, $t1, checkVaccinated
        j CCC43X
    ####################################
    CCC43X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -10
        add $t1, $t1, -1
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC43Y
        j CCC44X
    CCC43Y:
        beq $a1, $t1, checkVaccinated
        j CCC44X
    CCC44X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -9
        add $t1, $t1, -2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC44Y
        j CCC45X
    CCC44Y:
        beq $a1, $t1, checkVaccinated
        j CCC45X
    CCC45X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -8
        add $t1, $t1, -3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC45Y
        j CCC46X
    CCC45Y:
        beq $a1, $t1, checkVaccinated
        j CCC46X
    CCC46X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -8
        add $t1, $t1, -4
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC46Y
        j CCC47X
    CCC46Y:
        beq $a1, $t1, checkVaccinated
        j CCC47X
    CCC47X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -7
        add $t1, $t1, -2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC47Y
        j CCC48X
    CCC47Y:
        beq $a1, $t1, checkVaccinated
        j CCC48X
    CCC48X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -7
        add $t1, $t1, -5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC48Y
        j CCC49X
    CCC48Y:
        beq $a1, $t1, checkVaccinated
        j CCC49X
    CCC49X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -6
        add $t1, $t1, -6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC49Y
        j CCC50X
    CCC49Y:
        beq $a1, $t1, checkVaccinated
        j CCC50X
    CCC50X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -5
        add $t1, $t1, -5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC50Y
        j CCC51X
    CCC50Y:
        beq $a1, $t1, checkVaccinated
        j CCC51X
    CCC51X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -4
        add $t1, $t1, -6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC51Y
        j CCC52X
    CCC51Y:
        beq $a1, $t1, checkVaccinated
        j CCC52X
    CCC52X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -4
        add $t1, $t1, -7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC52Y
        j CCC53X
    CCC52Y:
        beq $a1, $t1, checkVaccinated
        j CCC53X
    CCC53X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -3
        add $t1, $t1, -8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC53Y
        j CCC54X
    CCC53Y:
        beq $a1, $t1, checkVaccinated
        j CCC54X
    CCC54X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -2
        add $t1, $t1, -7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC54Y
        j CCC55X
    CCC54Y:
        beq $a1, $t1, checkVaccinated
        j CCC55X
    CCC55X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -1
        add $t1, $t1, -8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CCC55Y
        j CCCEnd
    CCC55Y:
        beq $a1, $t1, checkVaccinated
        j CCCEnd
    CCCEnd:
        j MoveUpInner

CheckCollisionCoronaDown:
    # If collided with corona: game over
    # Else: move up/ move down
    ###########################################
    # NorthEast Direction
    ###########################################
    lw $a0, doodleX
    lw $a1, doodleY
    lw $t2, screenWidth
    div $a0, $t2
    mfhi $a0
    dCCC1X: 
        # load center of coronavirus
        lw $t0, coronaX
        lw $t1, coronaY

        # go to game over pixel
        add $t0, $t0, 0
        add $t1, $t1, -7
        # account for screen wrap around
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC1Y
        j dCCC2X
    dCCC1Y:
        beq $a1, $t1, checkVaccinated
        j dCCC2X
    dCCC2X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 1
        add $t1, $t1, -8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC2Y
        j dCCC3X

    dCCC2Y:
        beq $a1, $t1, checkVaccinated
        j dCCC3X

    dCCC3X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 2
        add $t1, $t1, -7 
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC3Y
        j dCCC4X

    dCCC3Y:
        beq $a1, $t1, checkVaccinated
        j dCCC4X

    dCCC4X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 2
        add $t1, $t1, -6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC4Y
        j dCCC5X

    dCCC4Y:
        beq $a1, $t1, checkVaccinated
        j dCCC5X

    dCCC5X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 3
        add $t1, $t1, -5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC5Y
        j dCCC6X

    dCCC5Y:
        beq $a1, $t1, checkVaccinated
        j dCCC6X

    dCCC6X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 4
        add $t1, $t1, -6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC6Y
        j dCCC7X

    dCCC6Y:
        beq $a1, $t1, checkVaccinated
        j dCCC7X

    dCCC7X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 5
        add $t1, $t1, -5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC7Y
        j dCCC8X

    dCCC7Y:
        beq $a1, $t1, checkVaccinated
        j dCCC8X

    dCCC8X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 5
        add $t1, $t1, -2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC8Y
        j dCCC9X

    dCCC8Y:
        beq $a1, $t1, checkVaccinated
        j dCCC9X

    dCCC9X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 6
        add $t1, $t1, -4
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC9Y
        j dCCC10X

    dCCC9Y:
        beq $a1, $t1, checkVaccinated
        j dCCC10X

    dCCC10X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 6
        add $t1, $t1, -3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC10Y
        j dCCC11X

    dCCC10Y:
        beq $a1, $t1, checkVaccinated
        j dCCC11X

    dCCC11X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 6
        add $t1, $t1, -1
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC11Y
        j dCCC12X

    dCCC11Y:
        beq $a1, $t1, checkVaccinated
        j dCCC12X

    dCCC12X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 7
        add $t1, $t1, -2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC12Y
        j dCCC13X

    dCCC12Y:
        beq $a1, $t1, checkVaccinated
        j dCCC13X

    dCCC13X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 8
        add $t1, $t1, -1
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC13Y
        j dCCC14X

    dCCC13Y:
        beq $a1, $t1, checkVaccinated
        j dCCC14X

    dCCC14X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 8
        add $t1, $t1, 0
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC14Y
        j dCCC15X

    dCCC14Y:
        beq $a1, $t1, checkVaccinated
        j dCCC15X

    ###########################################
    # SouthEast Direction
    ###########################################
    dCCC15X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 8
        add $t1, $t1, 1
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC15Y
        j dCCC16X
    dCCC15Y:
        beq $a1, $t1, checkVaccinated
        j dCCC16X
    dCCC16X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 8
        add $t1, $t1, 2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC16Y
        j dCCC17X
    dCCC16Y:
        beq $a1, $t1, checkVaccinated
        j dCCC17X
    dCCC17X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 7
        add $t1, $t1, 3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC17Y
        j dCCC18X
    dCCC17Y:
        beq $a1, $t1, checkVaccinated
        j dCCC18X
    dCCC18X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 6
        add $t1, $t1, 4
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC18Y
        j dCCC19X
    dCCC18Y:
        beq $a1, $t1, checkVaccinated
        j dCCC19X
    dCCC19X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 6
        add $t1, $t1, 5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC19Y
        j dCCC20X
    dCCC19Y:
        beq $a1, $t1, checkVaccinated
        j dCCC20X
    dCCC20X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 5
        add $t1, $t1, 3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC20Y
        j dCCC21X
    dCCC20Y:
        beq $a1, $t1, checkVaccinated
        j dCCC21X
    dCCC21X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 5
        add $t1, $t1, 6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC21Y
        j dCCC22X
    dCCC21Y:
        beq $a1, $t1, checkVaccinated
        j dCCC22X
    dCCC22X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 4
        add $t1, $t1, 7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC22Y
        j dCCC23X
    dCCC22Y:
        beq $a1, $t1, checkVaccinated
        j dCCC23X
    dCCC23X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 3
        add $t1, $t1, 8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC23Y
        j dCCC24X
    dCCC23Y:
        beq $a1, $t1, checkVaccinated
        j dCCC24X
    dCCC24X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 2
        add $t1, $t1, 8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC24Y
        j dCCC25X
    dCCC24Y:
        beq $a1, $t1, checkVaccinated
        j dCCC25X
    dCCC25X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 2
        add $t1, $t1, 7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC25Y
        j dCCC26X
    dCCC25Y:
        beq $a1, $t1, checkVaccinated
        j dCCC26X
    dCCC26X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 2
        add $t1, $t1, 6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC26Y
        j dCCC27X
    dCCC26Y:
        beq $a1, $t1, checkVaccinated
        j dCCC27X
    dCCC27X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 1
        add $t1, $t1, 9
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC27Y
        j dCCC28X
    dCCC27Y:
        beq $a1, $t1, checkVaccinated
        j dCCC28X
    dCCC28X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, 0
        add $t1, $t1, 10
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC28Y
        j dCCC29X
    dCCC28Y:
        beq $a1, $t1, checkVaccinated
        j dCCC29X
    ###########################################
    dCCC29X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -2
        add $t1, $t1, 10
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC29Y
        j dCCC30X
    dCCC29Y:
        beq $a1, $t1, checkVaccinated
        j dCCC30X
    dCCC30X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -3
        add $t1, $t1, 9
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC30Y
        j dCCC31X
    dCCC30Y:
        beq $a1, $t1, checkVaccinated
        j dCCC31X
    dCCC31X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -4
        add $t1, $t1, 7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC31Y
        j dCCC32X
    dCCC31Y:
        beq $a1, $t1, checkVaccinated
        j dCCC32X
    dCCC32X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -4
        add $t1, $t1, 8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC32Y
        j dCCC33X
    dCCC32Y:
        beq $a1, $t1, checkVaccinated
        j dCCC33X
    dCCC33X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -5
        add $t1, $t1, 8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC33Y
        j dCCC34X
    dCCC33Y:
        beq $a1, $t1, checkVaccinated
        j dCCC34X
    dCCC34X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -6
        add $t1, $t1, 7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC34Y
        j dCCC35X
    dCCC34Y:
        beq $a1, $t1, checkVaccinated
        j dCCC35X
    dCCC35X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -7
        add $t1, $t1, 6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC35Y
        j dCCC36X
    dCCC35Y:
        beq $a1, $t1, checkVaccinated
        j dCCC36X
    dCCC36X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -7
        add $t1, $t1, 3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC36Y
        j dCCC37X
    dCCC36Y:
        beq $a1, $t1, checkVaccinated
        j dCCC37X
    dCCC37X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -8
        add $t1, $t1, 4
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC37Y
        j dCCC38X
    dCCC37Y:
        beq $a1, $t1, checkVaccinated
        j dCCC38X
    dCCC38X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -8
        add $t1, $t1, 5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC38Y
        j dCCC39X
    dCCC38Y:
        beq $a1, $t1, checkVaccinated
        j dCCC39X
    dCCC39X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -9
        add $t1, $t1, 3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC39Y
        j dCCC40X
    dCCC39Y:
        beq $a1, $t1, checkVaccinated
        j dCCC40X
    dCCC40X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -10
        add $t1, $t1, 2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC40Y
        j dCCC41X
    dCCC40Y:
        beq $a1, $t1, checkVaccinated
        j dCCC41X
    dCCC41X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -10
        add $t1, $t1, 1
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC41Y
        j dCCC42X
    dCCC41Y:
        beq $a1, $t1, checkVaccinated
        j dCCC42X
    dCCC42X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -10
        add $t1, $t1, 0
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC42Y
        j dCCC43X
    dCCC42Y:
        beq $a1, $t1, checkVaccinated
        j dCCC43X
    ####################################
    dCCC43X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -10
        add $t1, $t1, -1
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC43Y
        j dCCC44X
    dCCC43Y:
        beq $a1, $t1, checkVaccinated
        j dCCC44X
    dCCC44X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -9
        add $t1, $t1, -2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC44Y
        j dCCC45X
    dCCC44Y:
        beq $a1, $t1, checkVaccinated
        j dCCC45X
    dCCC45X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -8
        add $t1, $t1, -3
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC45Y
        j dCCC46X
    dCCC45Y:
        beq $a1, $t1, checkVaccinated
        j dCCC46X
    dCCC46X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -8
        add $t1, $t1, -4
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC46Y
        j dCCC47X
    dCCC46Y:
        beq $a1, $t1, checkVaccinated
        j dCCC47X
    dCCC47X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -7
        add $t1, $t1, -2
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC47Y
        j dCCC48X
    dCCC47Y:
        beq $a1, $t1, checkVaccinated
        j dCCC48X
    dCCC48X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -7
        add $t1, $t1, -5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC48Y
        j dCCC49X
    dCCC48Y:
        beq $a1, $t1, checkVaccinated
        j dCCC49X
    dCCC49X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -6
        add $t1, $t1, -6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC49Y
        j dCCC50X
    dCCC49Y:
        beq $a1, $t1, checkVaccinated
        j dCCC50X
    dCCC50X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -5
        add $t1, $t1, -5
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC50Y
        j dCCC51X
    dCCC50Y:
        beq $a1, $t1, checkVaccinated
        j dCCC51X
    dCCC51X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -4
        add $t1, $t1, -6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC51Y
        j dCCC52X
    dCCC51Y:
        beq $a1, $t1, checkVaccinated
        j dCCC52X
    dCCC52X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -4
        add $t1, $t1, -7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC52Y
        j dCCC53X
    dCCC52Y:
        beq $a1, $t1, checkVaccinated
        j dCCC53X
    dCCC53X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -3
        add $t1, $t1, -8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC53Y
        j dCCC54X
    dCCC53Y:
        beq $a1, $t1, checkVaccinated
        j dCCC54X
    dCCC54X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -2
        add $t1, $t1, -7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC54Y
        j dCCC55X
    dCCC54Y:
        beq $a1, $t1, checkVaccinated
        j dCCC55X
    dCCC55X:
        lw $t0, coronaX
        lw $t1, coronaY
        add $t0, $t0, -1
        add $t1, $t1, -8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, dCCC55Y
        j dCCCEnd
    dCCC55Y:
        beq $a1, $t1, checkVaccinated
        j dCCCEnd
    dCCCEnd:
        j MoveDownInner

CheckCollisionDownPlatformY:
    # checks if left leg is ABOVE a platform, Y-wise
    # If above, check X
    lw $t0, platform1Y
    add $t0, $t0, -1
    beq $a1, $t0, CheckCollisionDownPlatformX1
    lw $t0, platform2Y
    add $t0, $t0, -1
    beq $a1, $t0, CheckCollisionDownPlatformX2
    lw $t0, platform3Y
    add $t0, $t0, -1
    beq $a1, $t0, CheckCollisionDownPlatformX3
    lw $t0, platform4Y
    add $t0, $t0, -1
    beq $a1, $t0, CheckCollisionDownPlatformX4
    lw $t0, platform5Y
    add $t0, $t0, -1
    beq $a1, $t0, CheckCollisionDownPlatformX5
    lw $t0, platform6Y
    add $t0, $t0, -1
    beq $a1, $t0, CheckCollisionDownPlatformX6
    lw $t0, platform7Y
    add $t0, $t0, -1
    beq $a1, $t0, CheckCollisionDownPlatformX7
    lw $t0, platform8Y
    add $t0, $t0, -1
    beq $a1, $t0, CheckCollisionDownPlatformX8
    # not above a platform, proceed as normal: 
    # check if fell off, then corona collision
    j CheckCollisionBottom

CheckCollisionDownPlatformX1:
    lw $t0, platform1X
    add $t0, $t0, -2
    lw $t1, screenWidth
    div $a0, $t1
    mfhi $a0

    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    # not above platform 1
    # not at bottom or above any platform, 
    # check if fell off
    j CheckCollisionBottom

CheckCollisionDownPlatformX2:
    lw $t0, platform2X
    lw $t1, screenWidth
    div $a0, $t1
    mfhi $a0

    add $t0, $t0, -2
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    # not above platform 2
    # not at bottom or above any platform, 
    # check if fell off
    j CheckCollisionBottom
CheckCollisionDownPlatformX3:
    lw $t0, platform3X
    lw $t1, screenWidth
    div $a0, $t1
    mfhi $a0

    add $t0, $t0, -2
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    # not above platform 3
    # not at bottom or above any platform, 
    # check if fell off
    j CheckCollisionBottom

CheckCollisionDownPlatformX4:
    lw $t0, platform4X
    lw $t1, screenWidth
    div $a0, $t1
    mfhi $a0

    add $t0, $t0, -2
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    # not above platform 4
    # not at bottom or above any platform, 
    # check if fell off
    j CheckCollisionBottom

CheckCollisionDownPlatformX5:
    lw $t0, platform5X
    lw $t1, screenWidth
    div $a0, $t1
    mfhi $a0

    add $t0, $t0, -2
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    # not above platform 5
    # not at bottom or above any platform, 
    # check if fell off
    j CheckCollisionBottom

CheckCollisionDownPlatformX6:
    lw $t0, platform6X
    lw $t1, screenWidth
    div $a0, $t1
    mfhi $a0

    add $t0, $t0, -2
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    # not above platform 5
    # not at bottom or above any platform, 
    # check if fell off
    j CheckCollisionBottom
CheckCollisionDownPlatformX7:
    lw $a0, doodleX
    lw $a1, doodleY
    lw $t0, platform7X
    lw $t1, screenWidth
    div $a0, $t1
    mfhi $a0

    add $t0, $t0, -2
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    # not above platform 5
    # not at bottom or above any platform, 
    # check if fell off
    j CheckCollisionBottom
CheckCollisionDownPlatformX8:
    lw $t0, platform8X
    lw $t1, screenWidth
    div $a0, $t1
    mfhi $a0

    add $t0, $t0, -2
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    add $t0, $t0, 1
    beq $a0, $t0, Bounce
    # not above platform 5
    # not at bottom or above any platform, 
    # check if fell off
    j CheckCollisionBottom
CheckCollisionVaccineUp:
    lw $a0, doodleX
    lw $a1, doodleY
    lw $t2, screenWidth
    div $a0, $t2
    mfhi $a0
    CV1X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, 0
        add $t1, $t1, -6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV1Y
        j CV2X
    CV1Y:
        beq $a1, $t1, vaccinate
        j CV2X
    CV2X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, 0
        add $t1, $t1, -7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV2Y
        j CV3X
    CV2Y:
        beq $a1, $t1, vaccinate
        j CV3X
    CV3X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, 0
        add $t1, $t1, -8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV3Y
        j CV4X
    CV3Y:
        beq $a1, $t1, vaccinate
        j CV4X
    CV4X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, 0
        add $t1, $t1, -9
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV4Y
        j CV5X
    CV4Y:
        beq $a1, $t1, vaccinate
        j CV5X
    CV5X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, -1
        add $t1, $t1, -6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV5Y
        j CV6X
    CV5Y:
        beq $a1, $t1, vaccinate
        j CV6X
    CV6X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, -1
        add $t1, $t1, -7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV6Y
        j CV7X
    CV6Y:
        beq $a1, $t1, vaccinate
        j CV7X
    CV7X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, -1
        add $t1, $t1, -8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV7Y
        j CV8X
    CV7Y:
        beq $a1, $t1, vaccinate
        j CV8X
    CV8X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, -1
        add $t1, $t1, -9
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV8Y
        j CV9X
    CV8Y:
        beq $a1, $t1, vaccinate
        j CV9X
    CV9X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, -2
        add $t1, $t1, -6
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV9Y
        j CV10X
    CV9Y:
        beq $a1, $t1, vaccinate
        j CV10X
    CV10X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, -2
        add $t1, $t1, -7
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV10Y
        j CV11X
    CV10Y:
        beq $a1, $t1, vaccinate
        j CV11X
    CV11X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, -2
        add $t1, $t1, -8
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV11Y
        j CV12X
    CV11Y:
        beq $a1, $t1, vaccinate
        j CV12X
    CV12X:
        lw $t0, vaccineX
        lw $t1, vaccineY
        add $t0, $t0, -2
        add $t1, $t1, -9
        div $t0, $t2
        mfhi $t0
        beq $a0, $t0, CV12Y
        j CVEnd
    CV12Y:
        beq $a1, $t1, vaccinate
        j CVEnd
    CVEnd:
        j MoveUpInner


checkVaccinated:
    beq $s2, 0, GameOverLoop
    j MoveUpInner
    

vaccinate:
    add $s2, $zero, 1
    j MoveUpInner
Bounce:
    # change direction to 1 
    add $a3, $zero, 1
    sw $a3, direction
    add $s0, $zero, 0
    # update Y coordinate
    add $a1, $a1, -2
    sw $a1, doodleY
    move $s0, $zero
    jal DrawScreen
    # play sound
	li $v0, 31
	li $a0, 79
	li $a1, 150
	li $a2, 7
	li $a3, 127
	syscall	
    j InputCheck

# when moving down, check collisions with y=32 and with platforms
MoveUp:
    j CheckCollisionCoronaUp
    MoveUpInner:
        lw $a0, doodleX
        lw $a1, doodleY
        # update Y coordinate
        add $a1, $a1, -1
        sw $a1, doodleY
        add $s0, $s0, 1     # s0 += 1

        jal DrawScreen
        lw $t0, jumpHeight
        beq $s0, $t0, ChangeDirectionToDown

        j InputCheck

MoveDown:
    j CheckCollisionCoronaDown
    MoveDownInner:
        lw $a0, doodleX
        lw $a1, doodleY
        # update Y coordinate
        add $a1, $a1, 1
        sw $a1, doodleY
        add $s0, $s0, -1    # s0 -= 1   

        j DrawScreen
        j InputCheck

GameOverLoop:
	li $v0, 31
	li $a0, 77
	li $a1, 1000
	li $a2, 7
	li $a3, 127
    syscall
	li $v0, 31
	li $a0, 65
	li $a1, 55
	li $a2, 7
	li $a3, 127
	syscall	
    DrawGameOver:
        #################
        # draw G 

        li $a0, 8      # get x coordinate of platform
        li $a1, 10
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 8      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 8      # get x coordinate of platform
        li $a1, 12
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 9      # get x coordinate of platform
        li $a1, 9
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 10      # get x coordinate of platform
        li $a1, 9
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 11      # get x coordinate of platform
        li $a1, 9
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 9      # get x coordinate of platform
        li $a1, 13
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 10      # get x coordinate of platform
        li $a1, 13
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 11      # get x coordinate of platform
        li $a1, 13
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 10      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 11      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 11      # get x coordinate of platform
        li $a1, 12
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)
        ######################################
        # draw A
        
        li $a0, 13      # get x coordinate of platform
        li $a1, 10
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 13      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 13      # get x coordinate of platform
        li $a1, 12
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 13      # get x coordinate of platform
        li $a1, 13
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 16      # get x coordinate of platform
        li $a1, 10
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 16      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 16      # get x coordinate of platform
        li $a1, 12
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 16      # get x coordinate of platform
        li $a1, 13
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 14      # get x coordinate of platform
        li $a1, 9
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 15      # get x coordinate of platform
        li $a1, 9
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 14      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 15      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)
        ##################### 
        # draw M
        li $a0, 18      # get x coordinate of platform
        li $a1, 9
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 18      # get x coordinate of platform
        li $a1, 10
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 18      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 18      # get x coordinate of platform
        li $a1, 12
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 18      # get x coordinate of platform
        li $a1, 13
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 22      # get x coordinate of platform
        li $a1, 9
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 22      # get x coordinate of platform
        li $a1, 10
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 22      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 22      # get x coordinate of platform
        li $a1, 12
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 22      # get x coordinate of platform
        li $a1, 13
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)


        li $a0, 19      # get x coordinate of platform
        li $a1, 10
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 20      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 21      # get x coordinate of platform
        li $a1, 10
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)
        ################################
        # draw E

        li $a0, 24      # get x coordinate of platform
        li $a1, 9
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 24      # get x coordinate of platform
        li $a1, 10
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 24      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 24      # get x coordinate of platform
        li $a1, 12
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 24      # get x coordinate of platform
        li $a1, 13
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 25      # get x coordinate of platform
        li $a1, 9
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 26      # get x coordinate of platform
        li $a1, 9
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 25      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 26      # get x coordinate of platform
        li $a1, 11
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 25      # get x coordinate of platform
        li $a1, 13
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 26      # get x coordinate of platform
        li $a1, 13
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        ########################
        # draw O
        li $a0, 8      # get x coordinate of platform
        li $a1, 17
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 8      # get x coordinate of platform
        li $a1, 18
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 8      # get x coordinate of platform
        li $a1, 19
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 11      # get x coordinate of platform
        li $a1, 17
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 11      # get x coordinate of platform
        li $a1, 18
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 11      # get x coordinate of platform
        li $a1, 19
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 9      # get x coordinate of platform
        li $a1, 16
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 10      # get x coordinate of platform
        li $a1, 16
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 9      # get x coordinate of platform
        li $a1, 20
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)

        li $a0, 10      # get x coordinate of platform
        li $a1, 20
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)
        ############################## 
        # draw V

        li $a0, 13      # get x coordinate of platform
        li $a1, 16
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)     

        li $a0, 13      # get x coordinate of platform
        li $a1, 17
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)  


        li $a0, 14      # get x coordinate of platform
        li $a1, 18
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)       

        li $a0, 14      # get x coordinate of platform
        li $a1, 19
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0) 

        li $a0, 15      # get x coordinate of platform
        li $a1, 20
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0) 

        li $a0, 16      # get x coordinate of platform
        li $a1, 18
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)        
        li $a0, 16      # get x coordinate of platform
        li $a1, 19
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 17      # get x coordinate of platform
        li $a1, 16
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)      
        li $a0, 17      # get x coordinate of platform
        li $a1, 17
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)     
        ##########################
        # draw E
        li $a0, 19      # get x coordinate of platform
        li $a1, 16
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 19      # get x coordinate of platform
        li $a1, 17
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 19      # get x coordinate of platform
        li $a1, 18
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 19      # get x coordinate of platform
        li $a1, 19
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 19      # get x coordinate of platform
        li $a1, 20
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   

        li $a0, 20      # get x coordinate of platform
        li $a1, 16
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 21      # get x coordinate of platform
        li $a1, 16
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 20      # get x coordinate of platform
        li $a1, 18
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 21      # get x coordinate of platform
        li $a1, 18
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 20      # get x coordinate of platform
        li $a1, 20
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 21      # get x coordinate of platform
        li $a1, 20
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        ###############3
        # draw R
        li $a0, 23      # get x coordinate of platform
        li $a1, 16
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 23      # get x coordinate of platform
        li $a1, 17
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 23      # get x coordinate of platform
        li $a1, 18
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 23      # get x coordinate of platform
        li $a1, 19
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 23      # get x coordinate of platform
        li $a1, 20
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   

        li $a0, 24      # get x coordinate of platform
        li $a1, 16
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 25      # get x coordinate of platform
        li $a1, 16
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   

        li $a0, 24      # get x coordinate of platform
        li $a1, 18
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 25      # get x coordinate of platform
        li $a1, 18
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   
        li $a0, 25      # get x coordinate of platform
        li $a1, 19
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)   

        li $a0, 26      # get x coordinate of platform
        li $a1, 20
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)  

        li $a0, 26      # get x coordinate of platform
        li $a1, 17
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, blackColor
        sw $a1, ($a0)    
        GameOverInputCheck:
            # get the input from the keyboard
            li $t0, 0xffff0000
            lw $t1, ($t0)
            andi $t1, $t1, 0x0001

            # If (equal to zero) no new input -> SelectDrawDirection 
            beqz $t1, GameOverInputCheck    # if no new input, draw in same direction
            lw $t2, 0xffff0004

            # input was s
            beq $t2, 115, main
            j GameOverInputCheck
Exit:
	li $v0, 56 #syscall value for dialog
	la $a0, lostMessage #get message
    lw $a1, score
	syscall
	
	li $v0, 50 #syscall for yes/no dialog
	la $a0, replayMessage #get message
	syscall
	
	beqz $a0, main # jump back to start of program
	# end program
	li $v0, 10
	syscall

DrawScreen:
    # responsible for updating location of elements on screen
    #########################################################
    FillBackground:
        # fill background white 
        lw $a0, screenWidth		# a0 = screenWidth
        lw $a1, backgroundColor	# a1 = backgroundColor
        mul $a2, $a0, $a0       # a2 = a0 * a0
        mul $a2, $a2, 4         # a2 = a2 * 4
        add $a2, $a2, $gp       # a2 = a2 + display base
        add $a0, $gp, $zero     # a0 = display base
        FillBackgroundLoop:
            # display address = backgroundColor
            # displayaddress += 4
            # Screen not filled => repeat
            sw $a1, ($a0) 
            addiu $a0, $a0, 4
            bne $a0, $a2, FillBackgroundLoop
    ###################################################
    DrawCorona:
        ########################################
        # draw black
        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, 1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 1
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, -1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -1
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 1
        add $a1, $a1, 2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 2
        add $a1, $a1, 1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 2
        add $a1, $a1, -1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 1
        add $a1, $a1, -2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -1
        add $a1, $a1, -2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -2
        add $a1, $a1, -1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -2
        add $a1, $a1, 1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -1
        add $a1, $a1, 2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 3
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 3
        add $a1, $a1, 2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 3
        add $a1, $a1, 3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 2
        add $a1, $a1, 3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, 3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -2
        add $a1, $a1, 3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -3
        add $a1, $a1, 3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -3
        add $a1, $a1, 2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -3
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -3
        add $a1, $a1, -2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -3
        add $a1, $a1, -3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -2
        add $a1, $a1, -3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, -3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 2
        add $a1, $a1, -3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 3
        add $a1, $a1, -3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 3
        add $a1, $a1, -2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, blackColor
        sw $a1, ($a0)

        ####################3
        # Draw Dark PInk
        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 1
        add $a1, $a1, 1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 1
        add $a1, $a1, -1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -1
        add $a1, $a1, -1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -1
        add $a1, $a1, 1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, 2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 2
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, -2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -2
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 2
        add $a1, $a1, 2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 2
        add $a1, $a1, -2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -2
        add $a1, $a1, -2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -2
        add $a1, $a1, 2
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 7
        add $a1, $a1, -1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 7
        add $a1, $a1, 1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 5
        add $a1, $a1, 4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 4
        add $a1, $a1, 5
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 1
        add $a1, $a1, 7
        lw $t0, screenWidth
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -1
        add $a1, $a1, 7
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -4
        add $a1, $a1, 5
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -5
        add $a1, $a1, 4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -7
        add $a1, $a1, 1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -7
        add $a1, $a1, -1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -5
        add $a1, $a1, -4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -4
        add $a1, $a1, -5
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -1
        add $a1, $a1, -7
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 1
        add $a1, $a1, -7
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 4
        add $a1, $a1, -5
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 5
        add $a1, $a1, -4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkDark
        sw $a1, ($a0)
    
        ##############
        # draw gray
        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, 6
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, 5
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 1
        add $a1, $a1, 4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -1
        add $a1, $a1, 4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 4
        add $a1, $a1, 4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -4
        add $a1, $a1, 4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 4
        add $a1, $a1, 1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -4
        add $a1, $a1, 1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 6
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 5
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -5
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -6
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 4
        add $a1, $a1, -1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -4
        add $a1, $a1, -1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 4
        add $a1, $a1, -4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 1
        add $a1, $a1, -4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -1
        add $a1, $a1, -4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -4
        add $a1, $a1, -4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, -5
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, -6
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, gray
        sw $a1, ($a0)

        ####################
        # Light PInk
        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, 4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 1
        add $a1, $a1, 3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 3
        add $a1, $a1, 1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 4
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 3
        add $a1, $a1, -1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 1
        add $a1, $a1, -3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, 0
        add $a1, $a1, -4
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -1
        add $a1, $a1, -3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -3
        add $a1, $a1, -1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -4
        add $a1, $a1, 0
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -3
        add $a1, $a1, 1
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

        lw $a0, coronaX
        lw $a1, coronaY
        add $a0, $a0, -1
        add $a1, $a1, 3
        lw $t0, screenWidth
        div $a0, $t0
        mfhi $a0
        mul $t0, $t0, $a1
        add $t0, $t0, $a0
        mul $t0, $t0, 4 
        add $t0, $t0, $gp
        move $a0, $t0
        lw $a1, coronaPinkLight
        sw $a1, ($a0)

    
    
    
    
    
    ####################################################
    ##################################################
    # draw score board 
    ##################################################
    lw $t4, score     
    li $t5, 0
    DrawScore:
        # score = score // 10
        # digit = score % 10
        beq $t4, 0, DrawPlatforms
        li $t2, 10
        div $t4, $t2
        mflo $t4    # integer quotient
        mfhi $t1    # remainder
        beq $t1, 0, DrawZero
        beq $t1, 1, DrawOne
        beq $t1, 2, DrawTwo
        beq $t1, 3, DrawThree
        beq $t1, 4, DrawFour
        beq $t1, 5, DrawFive
        beq $t1, 6, DrawSix
        beq $t1, 7, DrawSeven
        beq $t1, 8, DrawEight
        beq $t1, 9, DrawNine

        DrawZero:
            ######
            # top three
            ######
            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)
        
            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)


            ######
            # left four 
            ######
            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            ######
            # bottom middle
            ######

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            ####
            # right four
            ####
            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            add $t5, $t5, 4     # offset by one digit
            j DrawScore

        DrawOne:
            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            add $t5, $t5, 4     # offset by one digit
            j DrawScore

        DrawTwo:
            ######
            # top three
            ######
            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)
        
            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)


            ######
            # left four 
            ######
            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            ######
            # bottom middle
            ######

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            ####
            # right four
            ####
            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            ####
            # middle/center
            ####
            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            add $t5, $t5, 4     # offset by one digit
            j DrawScore



        DrawThree:
            ######
            # top three
            ######
            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)
        
            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)


            ######
            # left four 
            ######

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            ######
            # bottom middle
            ######

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)


            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)


            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            add $t5, $t5, 4     # offset by one digit
            j DrawScore

        DrawFour:
            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)


            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)


            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)


            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            add $t5, $t5, 4     # offset by one digit
            j DrawScore

        DrawFive:
            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            add $t5, $t5, 4     # offset by one digit
            j DrawScore

        DrawSix:
            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)


            add $t5, $t5, 4     # offset by one digit
            j DrawScore


        DrawSeven:
            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)


            add $t5, $t5, 4     # offset by one digit
            j DrawScore

        DrawEight:
            # top three
            ######
            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)
        
            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)


            ######
            # left four 
            ######
            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            ######
            # bottom middle
            ######

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            ####
            # right four
            ####
            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            add $t5, $t5, 4     # offset by one digit
            j DrawScore
        DrawNine:
            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 30
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 29
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 30      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 26
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 27
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 28      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            li $a0, 29      # get x coordinate of platform
            sub $a0, $a0, $t5   # x offset
            li $a1, 28
            # convert (x, y) Coordinate to Address in bitmap
            lw $t0, screenWidth     # $t0 = screenWidth
            mul $t0, $t0, $a1       # $t0 *= $a1
            add $t0, $t0, $a0       # $t0 += $a0
            mul $t0, $t0, 4         # $t0 *= 4
            add $t0, $t0, $gp       # $t0 += $gp
            move $a0, $t0           # $a0 = $t0 = address
            # draw pixel
            lw $a1, blackColor
            sw $a1, ($a0)

            add $t5, $t5, 4     # offset by one digit
            j DrawScore

    
    #########################################################
    # draw platforms
    #########################################################
    DrawPlatforms:
        # platform 1
        lw $a0, platform1X       # get x coordinate of platform
        lw $a1, platform1Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor1
        sw $a1, ($a0)

        lw $a0, platform1X       # get x coordinate of platform
        add $a0, $a0, 1        # $a0 += 1
        lw $a1, platform1Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor1
        sw $a1, ($a0)

        lw $a0, platform1X       # get x coordinate of platform
        add $a0, $a0, 2        # $a0 += 1
        lw $a1, platform1Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor1
        sw $a1, ($a0)

        lw $a0, platform1X       # get x coordinate of platform
        add $a0, $a0, 3        # $a0 += 1
        lw $a1, platform1Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor1
        sw $a1, ($a0)

        lw $a0, platform1X       # get x coordinate of platform
        add $a0, $a0, 4        # $a0 += 1
        lw $a1, platform1Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor1
        sw $a1, ($a0)
        #######################################
        # platform 2
        lw $a0, platform2X       # get x coordinate of platform
        lw $a1, platform2Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor2
        sw $a1, ($a0)

        lw $a0, platform2X       # get x coordinate of platform
        add $a0, $a0, 1         # $a0 += 1
        lw $a1, platform2Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor2
        sw $a1, ($a0)

        lw $a0, platform2X       # get x coordinate of platform
        add $a0, $a0, 2        # $a0 += 1
        lw $a1, platform2Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor2
        sw $a1, ($a0)

        lw $a0, platform2X       # get x coordinate of platform
        add $a0, $a0, 3        # $a0 += 1
        lw $a1, platform2Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor2
        sw $a1, ($a0)

        lw $a0, platform2X       # get x coordinate of platform
        add $a0, $a0, 4        # $a0 += 1
        lw $a1, platform2Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor2
        sw $a1, ($a0)
        #######################################
        # platform 3
        lw $a0, platform3X       # get x coordinate of platform
        lw $a1, platform3Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor3
        sw $a1, ($a0)

        lw $a0, platform3X       # get x coordinate of platform
        add $a0, $a0, 1        # $a0 += 1
        lw $a1, platform3Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor3
        sw $a1, ($a0)

        lw $a0, platform3X       # get x coordinate of platform
        add $a0, $a0, 2        # $a0 += 1
        lw $a1, platform3Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor3
        sw $a1, ($a0)

        lw $a0, platform3X       # get x coordinate of platform
        add $a0, $a0, 3        # $a0 += 1
        lw $a1, platform3Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor3
        sw $a1, ($a0)

        lw $a0, platform3X       # get x coordinate of platform
        add $a0, $a0, 4        # $a0 += 1
        lw $a1, platform3Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor3
        sw $a1, ($a0)
        #######################################
        # platform 2
        lw $a0, platform4X       # get x coordinate of platform
        lw $a1, platform4Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor4
        sw $a1, ($a0)

        lw $a0, platform4X       # get x coordinate of platform
        add $a0, $a0, 1         # $a0 += 1
        lw $a1, platform4Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor4
        sw $a1, ($a0)

        lw $a0, platform4X       # get x coordinate of platform
        add $a0, $a0, 2        # $a0 += 1
        lw $a1, platform4Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor4
        sw $a1, ($a0)

        lw $a0, platform4X       # get x coordinate of platform
        add $a0, $a0, 3        # $a0 += 1
        lw $a1, platform4Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor4
        sw $a1, ($a0)

        lw $a0, platform4X       # get x coordinate of platform
        add $a0, $a0, 4        # $a0 += 1
        lw $a1, platform4Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor4
        sw $a1, ($a0)
        #######################################
        # platform 5
        lw $a0, platform5X       # get x coordinate of platform
        lw $a1, platform5Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor5
        sw $a1, ($a0)

        lw $a0, platform5X       # get x coordinate of platform
        add $a0, $a0, 1         # $a0 += 1
        lw $a1, platform5Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor5
        sw $a1, ($a0)

        lw $a0, platform5X       # get x coordinate of platform
        add $a0, $a0, 2        # $a0 += 1
        lw $a1, platform5Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor5
        sw $a1, ($a0)

        lw $a0, platform5X       # get x coordinate of platform
        add $a0, $a0, 3        # $a0 += 1
        lw $a1, platform5Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor5
        sw $a1, ($a0)

        lw $a0, platform5X       # get x coordinate of platform
        add $a0, $a0, 4        # $a0 += 1
        lw $a1, platform5Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor5
        sw $a1, ($a0)
        #######################################
        # platform 6
        lw $a0, platform6X       # get x coordinate of platform
        lw $a1, platform6Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor6
        sw $a1, ($a0)

        lw $a0, platform6X       # get x coordinate of platform
        add $a0, $a0, 1        # $a0 += 1
        lw $a1, platform6Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor6
        sw $a1, ($a0)

        lw $a0, platform6X       # get x coordinate of platform
        add $a0, $a0, 2        # $a0 += 1
        lw $a1, platform6Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor6
        sw $a1, ($a0)

        lw $a0, platform6X       # get x coordinate of platform
        add $a0, $a0, 3        # $a0 += 1
        lw $a1, platform6Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor6
        sw $a1, ($a0)

        lw $a0, platform6X       # get x coordinate of platform
        add $a0, $a0, 4        # $a0 += 1
        lw $a1, platform6Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor6
        sw $a1, ($a0)
        #######################################
        # platform 3
        lw $a0, platform7X       # get x coordinate of platform
        lw $a1, platform7Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor7
        sw $a1, ($a0)

        lw $a0, platform7X       # get x coordinate of platform
        add $a0, $a0, 1        # $a0 += 1
        lw $a1, platform7Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor7
        sw $a1, ($a0)

        lw $a0, platform7X       # get x coordinate of platform
        add $a0, $a0, 2        # $a0 += 1
        lw $a1, platform7Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor7
        sw $a1, ($a0)

        lw $a0, platform7X       # get x coordinate of platform
        add $a0, $a0, 3        # $a0 += 1
        lw $a1, platform7Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor7
        sw $a1, ($a0)

        lw $a0, platform7X       # get x coordinate of platform
        add $a0, $a0, 4        # $a0 += 1
        lw $a1, platform7Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor7
        sw $a1, ($a0)
        #######################################
        # platform 3
        lw $a0, platform8X       # get x coordinate of platform
        lw $a1, platform8Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor8
        sw $a1, ($a0)

        lw $a0, platform8X       # get x coordinate of platform
        add $a0, $a0, 1        # $a0 += 1
        lw $a1, platform8Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor8
        sw $a1, ($a0)

        lw $a0, platform8X       # get x coordinate of platform
        add $a0, $a0, 2        # $a0 += 1
        lw $a1, platform8Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor8
        sw $a1, ($a0)

        lw $a0, platform8X       # get x coordinate of platform
        add $a0, $a0, 3        # $a0 += 1
        lw $a1, platform8Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor8
        sw $a1, ($a0)

        lw $a0, platform8X       # get x coordinate of platform
        add $a0, $a0, 4        # $a0 += 1
        lw $a1, platform8Y
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel
        lw $a1, platformColor8
        sw $a1, ($a0)

    #########################################################
    # draw doodler
    #########################################################
    DrawDoodler:
        # draw Doodler
        # ## #
        lw $a0, doodleX
        lw $a1, doodleY

        lw $t1, screenWidth
        div $a0, $t1
        mfhi $a0
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel 
        lw $a1, doodleColor
        sw $a1, ($a0)

        # ## #
        lw $a0, doodleX
        lw $a1, doodleY
        add $a1, $a1, -1

        lw $t1, screenWidth
        div $a0, $t1
        mfhi $a0
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel 
        lw $a1, darkRedColor
        sw $a1, ($a0)

        # ## #
        lw $a0, doodleX
        lw $a1, doodleY
        add $a0, $a0, 1
        add $a1, $a1, -1

        lw $t1, screenWidth
        div $a0, $t1
        mfhi $a0
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel 
        lw $a1, darkRedColor
        sw $a1, ($a0)

        # ## #
        lw $a0, doodleX
        lw $a1, doodleY
        add $a0, $a0, 1
        add $a1, $a1, -2

        lw $t1, screenWidth
        div $a0, $t1
        mfhi $a0
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel 
        lw $a1, darkRedColor
        sw $a1, ($a0)

        # ## #
        lw $a0, doodleX
        lw $a1, doodleY
        add $a0, $a0, 2
        lw $t1, screenWidth
        div $a0, $t1
        mfhi $a0
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel 
        lw $a1, doodleColor
        sw $a1, ($a0)

        # ## #
        lw $a0, doodleX
        lw $a1, doodleY
        add $a0, $a0, 2
        add $a1, $a1, -1

        lw $t1, screenWidth
        div $a0, $t1
        mfhi $a0
        # convert (x, y) Coordinate to Address in bitmap
        lw $t0, screenWidth     # $t0 = screenWidth
        mul $t0, $t0, $a1       # $t0 *= $a1
        add $t0, $t0, $a0       # $t0 += $a0
        mul $t0, $t0, 4         # $t0 *= 4
        add $t0, $t0, $gp       # $t0 += $gp
        move $a0, $t0           # $a0 = $t0 = address
        # draw pixel 
        lw $a1, darkRedColor
        sw $a1, ($a0)
    DrawLoopEnd:

            # sleep for a little
            li $v0, 32 #syscall value for sleep
            lw $t0, gameSpeed
            move $a0, $t0
            syscall

            jr $ra




# End 
