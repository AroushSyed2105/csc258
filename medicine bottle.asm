    .data
ADDR_DSPL:
    .word 0x10008000

    .text
	.globl main

main:
lw $t0, ADDR_DSPL       # $t0 = base address for display
li $t1, 0xFF5050        # $t1 = red
li $t2, 0x50CC50        # $t2 = green
li $t3, 0xFFFF50        # $t3 = yellow
li $t4, 0x5F5F5F        # $t4 = grey


# Milestone 1: draw a medicine bottle ######################################################

# left wall
addi $t5, $t0, 3840     # moving down 5 rows      
addi $t5, $t5, 52       # vert line start
addi $t6, $zero, 44     # vert line lenght
add $t7, $zero, $zero   # loop variable
jal draw_vertical       # jump to vertical line drawing loop 
# jal: keep current location in memory so when the loop terminates we can come back here

# right wall
addi $t5, $t0, 3840     # moving down 5 rows      
addi $t5, $t5, 200      # vert line start
# vert line length didn't change so we don't touch it
add $t7, $zero, $zero   # reset loop variable
jal draw_vertical       # jump to vertical line drawing loop

#base
addi $t5, $t0, 15104    # move 30 rows down to base of bottle
addi $t5, $t5, 52       # move right to start of bottle
addi $t6, $zero, 38     # $t6 = width of bottle
add $t7, $zero, $zero   # reset loop variable
jal draw_horizontal

# top horizontal left
addi $t5, $t0, 3840     # moving to 5 rows down from top    
addi $t5, $t5, 52       # line start
addi $t6, $zero, 13     # line length
add $t7, $zero, $zero   # loop variable
jal draw_horizontal     # jump to horizontal line drawing loop 

# top horizontal right
addi $t5, $t0, 3840     # moving to 5 rows down from top
addi $t5, $t5, 148      # line start
addi $t6, $zero, 13     # line length
add $t7, $zero, $zero   # loop variable
jal draw_horizontal     # jump to horizontal line drawing loop 

# neck left
addi $t5, $t0, 2048     # moving to 1 row down from top
addi $t5, $t5, 104      # vert line start
addi $t6, $zero, 8      # vert line lenght
add $t7, $zero, $zero   # loop variable
jal draw_vertical       # jump to vertical line drawing loop

# neck right
addi $t5, $t0, 2048     # moving to 1 row down from top
addi $t5, $t5, 148      # vert line start
addi $t6, $zero, 8      # vert line lenght
add $t7, $zero, $zero   # loop variable
jal draw_vertical       # jump to vertical line drawing loop

# pill
addi $t5, $t0, 2560     # moving downward
addi $t5, $t5, 120      # moving to inside neck of bottle
# color left
jal random              # gets a random number
jal color               # uses the random number to generate a color
# draw left side of pixel
sw $t7, 0($t5)
sw $t7, 4($t5)
sw $t7, 256($t5)
sw $t7, 260($t5)
# color 2
jal random              # gets a random number
jal color               # uses the random number to generate a color
# move to right side of pixel
addi $t5, $t5, 8   
# draws right side of pixel
sw $t7, 0($t5)
sw $t7, 4($t5)
sw $t7, 256($t5)
sw $t7, 260($t5)          

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
li $t7, 0xFF5050            # store red in $t7
ble $a0, 5, color_end       # if random <= 5 then keep red and jump to color_end
li $t7, 0x50CC50            # store green in $t7 
ble $a0, 10, color_end      # if random <= 10 then keep green and jump to color_end
li $t7, 0xFFFF50            # store yellow in $t7, random > 10 by this point
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
draw_horiz_end:         # stop drawing
jr $ra                  # jump back to where we came from

draw_vertical:
# draw vertical line
# parameters:
# - $t5 start position
# - $t6 length
    sw $t4, 0($t5)                  # draw pixel at current location
    addi $t7, $t7, 1                # increment loop variable
    addi $t5, $t5, 256              # go to next line
    beq $t7, $t6, draw_vert_end     # if loop variable = line length then stop drawing
    j draw_vertical                 # restart loop
draw_vert_end:          # stop drawing
jr $ra                  # jump back to where we came from

# Exit #############################################################################

exit:
    li $v0, 10              # terminate the program gracefully
    syscall
