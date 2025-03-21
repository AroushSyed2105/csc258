    .data
ADDR_DSPL:
    .word 0x10008000

    .text
	.globl main

main:
lw $t0, ADDR_DSPL       # $t0 = base address for display
li $t1, 0xff0000        # $t1 = red
li $t2, 0x00ff00        # $t2 = green
li $t3, 0x0000ff        # $t3 = blue
li $t4, 0x5f5f5f        # $t4 = grey


# Milestone 1: draw a medicine bottle ######################################################

# left wall
addi $t5, $t0, 1024      # moving down 5 rows      
addi $t5, $t5, 24        # vert line start
addi $t6, $zero, 22     # vert line lenght
add $t7, $zero, $zero   # loop variable
jal draw_vertical       # jump to vertical line drawing loop 
# jal: keep current location in memory so when the loop terminates we can come back here

# right wall
addi $t5, $t0, 1024      # moving down 5 rows      
addi $t5, $t5, 100      # vert line start
# vert line length didn't change so we don't touch it
add $t7, $zero, $zero   # reset loop variable
jal draw_vertical       # jump to vertical line drawing loop

#base
addi $t5, $t0, 3840     # move 30 rows down to base of bottle
addi $t5, $t5, 24        # move right to start of bottle
addi $t6, $zero, 20     # $t6 = width of bottle
add $t7, $zero, $zero   # reset loop variable
jal draw_horizontal

# top horizontal left
addi $t5, $t0, 1024      # moving to 5 rows down from top    
addi $t5, $t5, 28        # line start
addi $t6, $zero, 6     # line length
add $t7, $zero, $zero   # loop variable
jal draw_horizontal     # jump to horizontal line drawing loop 

# top horizontal right
addi $t5, $t0, 1024      # moving to 5 rows down from top
addi $t5, $t5, 76       # line start
addi $t6, $zero, 6     # line length
add $t7, $zero, $zero   # loop variable
jal draw_horizontal     # jump to horizontal line drawing loop 

# neck left
addi $t5, $t0, 512      # moving to 1 row down from top
addi $t5, $t5, 52       # vert line start
addi $t6, $zero, 5      # vert line lenght
add $t7, $zero, $zero   # loop variable
jal draw_vertical       # jump to vertical line drawing loop

# neck right
addi $t5, $t0, 512      # moving to 1 row down from top
addi $t5, $t5, 72       # vert line start
addi $t6, $zero, 5      # vert line lenght
add $t7, $zero, $zero   # loop variable
jal draw_vertical       # jump to vertical line drawing loop

# pill
addi $t5, $t0, 768      # moving to 2 row down from top
addi $t5, $t5, 60       # moving to inside neck of bottle
# color 1
jal random              # gets a random number
jal color               # uses the random number to generate a color
sw $t7, 0($t5)          # draws left part of pixel
# color 2
jal random              # gets a random number
jal color               # uses the random number to generate a color
sw $t7, 4($t5)          # draws right part of pixel

# Milestone 2: Movement #################################################################


# Functions #############################################################################
j exit

random:
# random seed: stores a random value from 0-15 inclusive in $a0
li $v0, 42
li $a0, 0
li $a1, 16
syscall
jr $ra

color:
# stores one of the 3 colors in $t7 depending on the random number stored in $a0
li $t7, 0xFF0000            # store red in $t7
ble $a0, 5, color_end       # if random <= 5 then keep red and jump to color_end
li $t7, 0x00FF00            # store green in $t7 
ble $a0, 10, color_end      # if random <= 10 then keep green and jump to color_end
li $t7, 0x0000FF            # store blue in $t7, random > 10 by this point
color_end:
jr $ra

draw_horizontal:
# draw horizontal line
# parameters:
# - $t5 start position
# - $t6 length
    sw $t4, 0($t5)                  # draw pixel at current location
    addi $t7, $t7, 1                # increment loop variable
    addi $t5, $t5, 4                # go to next pixel
    beq $t7, $t6, draw_horiz_end    # if loop variable = line length then stop drawing
    j draw_horizontal               # restart loop
draw_horiz_end:          # stop drawing
jr $ra                   # jump back to where we came from

draw_vertical:
# draw vertical line
# parameters:
# - $t5 start position
# - $t6 length
    sw $t4, 0($t5)                  # draw pixel at current location
    addi $t7, $t7, 1                # increment loop variable
    addi $t5, $t5, 128              # go to next line
    beq $t7, $t6, draw_vert_end     # if loop variable = line length then stop drawing
    j draw_vertical                 # restart loop
draw_vert_end:          # stop drawing
jr $ra                  # jump back to where we came from

# Exit #############################################################################

exit:
    li $v0, 10              # terminate the program gracefully
    syscall
