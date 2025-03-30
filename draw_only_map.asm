.data
map: .space 16384  # Allocate space for 64 rows * 64 columns * 4 bytes per word (since each word is 4 bytes) = 6840bytes
DISPLAY_ADDR:   .word 0x10008000  # Memory-mapped address for the display
KEYBOARD_ADDR:  .word 0xffff0000  # Memory-mapped address for the keyboard

x1_pos: .word 30        # Stores the x-coordinate of side 1 of pill  
y1_pos: .word 12        # Stores the y-coordinate of side 1 of pill
x2_pos: .word 32        # Stores the x-coordinate of side 2 of pill  
y2_pos: .word 12        # Stores the y-coordinate of side 2 of pill
orientation: .word 0    # Stores the orientation of the pill 
# x_pos and y_pos ARE STARTING POSITIONS FOR OUR PIXEL
prev_x1_pos: .word 30  # Previous x-coordinate
prev_y1_pos: .word 12  # Previous y-coordinate
prev_x2_pos: .word 32  
prev_y2_pos: .word 12  
# colors
col1: .word 0xff0000           # designates memory to col1
col2: .word 0x00ff00    # designates memory to col2
virusmap: .word 0
SCREEN_WIDTH: .word 64 


.text
.globl main
li $v0, 32      #frames per second or something

# assign color1 & color2 & map
jal random
jal color
sw $t7, col1
jal random
jal color
sw $t7, col2


### SKIP FUNCTIONS: RANDOM, VERT LINE, HORIZ LINE ####################################################################
j main

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
    
map_horizontal:
    # parameters:
    # - $t1: line start Y
    # - $t2: line start X
    # - $t6: line length
    la $t3, map
    mul $t5, $t1, 64          # Multiply Y coordinate by total width
    add $t5, $t5, $t2         # Add X coordinate (column start)
    sll $t5, $t5, 2           # Multiply by 4 to get byte offset
    add $t8, $t5, $t3         # add to base address
    li $t4, 0                 # Column counter   
    li $t7, 0xFFFFFF          # $t7: white
hori_loop:
    bge $t4, $t6, end_hori    # If line counter >= line length, stop drawing
    sw $t7, 0($t8)          # Store color at the current cell
    addi $t8, $t8, 4          # Move to next pixel (4 bytes ahead)
    addi $t4, $t4, 1          # Increment column counter
    j hori_loop               # Continue loop 
end_hori:
    jr $ra                    # Return to caller
    
    
map_vertical:
    # parameters:
    # - $t1: line start Y
    # - $t2: line start X
    # - $t6: line length
    la $t3, map
    mul $t5, $t1, 64          # Multiply Y coordinate by total width
    add $t5, $t5, $t2         # Add X coordinate (column start)
    sll $t5, $t5, 2           # Multiply by 4 to get byte offset
    add $t8, $t5, $t3         # add to base address
    li $t4, 0                 # Column counter   
    li $t7, 0xFFFFFF          # $t7: white
vert_loop:
    bge $t4, $t6, end_vert    # If line counter >= line length, stop drawing
    sw $t7, 0($t8)          # Store color at the current cell
    addi $t8, $t8, 256          # Move to next row (64*4 bytes ahead)
    addi $t4, $t4, 1          # Increment column counter
    j vert_loop               # Continue loop 
end_vert:
    jr $ra                    # Return to caller

    
### MAP ARRAY SETUP ############################################################

main:
    li $t0, 0           # Row counter (starting at 0)
    li $t1, 0           # Column counter (starting at 0)
    li $t2, 64          # Number of rows
    li $t3, 64          # Number of columns 

loop_rows:
    bge $t0, $t2, end_loop  # If row counter >= 20, end loop

    # Calculate base address for the current row
    la $t4, map         # Load base address of array into $t4
    mul $t5, $t0, $t3     # Multiply row index by number of columns
    sll $t5, $t5, 2     # Multiply by 4 to get byte offset (each word is 4 bytes)
    add $t6, $t4, $t5   # Add offset to base address for the current row

    li $t1, 0           # Reset column counter

loop_columns:
    bge $t1, $t3, next_row  # If column counter >= 38, move to the next row

    # Store a value in array[row][col]
    li $t7, 0x0      # Just an example value to store (could be computed)
    sw $t7, 0($t6)        # Store value at the current row, column position

    addi $t6, $t6, 4      # Move to the next column in the current row
    addi $t1, $t1, 1      # Increment column counter
    j loop_columns        # Continue looping through columns

next_row:
    addi $t0, $t0, 1      # Increment row counter
    j loop_rows           # Continue looping through rows

end_loop:

### SELECT MAP #################################################################

    jal random              # Get random number in $a0
    ble $a0, 5, set_map_1        # If random <= 5, jump to map1
    ble $a0, 10, set_map_2       # If random <= 10, jump to map2
    # Otherwise, map=3
    
    li $t1, 3
    sw $t1, virusmap
    j end_virus_map
    
    set_map_1:
    li $t1, 1
    sw $t1, virusmap
    j end_virus_map
    
    set_map_2:
    li $t1, 2
    sw $t1, virusmap
    
    end_virus_map:
    
### WALLS #####################################################################

#base
    li $t1, 60                # Y coordinate (row)
    li $t2, 13                # X coordinate (column start)
    li $t6, 38                # Number of pixels to draw (line length)
    jal map_horizontal       # Call horizontal line drawing function
    
#left_wall
    li $t1, 15                # Y coordinate (row start)
    li $t2, 13                # X coordinate (fixed column)
    li $t6, 45                # Number of pixels to draw (line height)
    jal map_vertical         # Call vertical line drawing function
    
# right wall
    li $t1, 15                # moving down 5 rows      
    li $t2, 50                # vert line start
    li $t6, 45                # vert line lenght
    jal map_vertical         # jump to vertical line drawing loop
# top horizontal left
    li $t1, 15                # y   
    li $t2,13                 # x
    li $t6, 13                # line length
    jal map_horizontal       # jump to horizontal line drawing loop 
# top horizontal right
    li $t1,15                 # y   
    li $t2, 37                # x
    li $t6, 13                # line length
    jal map_horizontal       # jump to horizontal line drawing loop 
# neck left
    li $t1, 8                 # moving to 5 rows down from top
    li $t2, 26                # vert line start
    li $t6, 8                 # vert line lenght
    jal map_vertical         # jump to vertical line drawing loop
# neck right
    li $t1, 8                 # moving to 5 rows down from top
    li $t2, 37                # vert line start
    li $t6, 8                 # vert line lenght
    jal map_vertical         # jump to vertical line drawing loop
    
### VIRUSES #################################################################################################
    lw $t0, DISPLAY_ADDR
    li $t1, 0xFF0505        # $t1 = red
    li $t2, 0x00CC30        # $t2 = green
    li $t3, 0xFFCF00        # $t3 = yellow
    la $t4, map             # $t4 = map address
    lw $t5, virusmap
    beq $t5, 1, draw_map1        # If random <= 5, jump to map1
    beq $t5, 2, draw_map2       # If random <= 10, jump to map2
    j draw_map3 
    
draw_map1:
    # Draw three fixed pixels for map1
    addi $t5, $t4, 12856    # Position 1: Red
    sw $t1, 0($t5)
    sw $t1, 4($t5)
    sw $t1, 256($t5)
    sw $t1, 260($t5)
    
    addi $t5, $t4, 14920    # Position 2: Green
    sw $t2, 0($t5)
    sw $t2, 4($t5)
    sw $t2, 256($t5)
    sw $t2, 260($t5)
    
    addi $t5, $t4, 9312     # Position 3: Yellow
    sw $t3, 0($t5)
    sw $t3, 4($t5)
    sw $t3, 256($t5)
    sw $t3, 260($t5)
    
    j end_virus
    
draw_map2:
    # Draw three fixed pixels for map1
    addi $t5, $t4, 9848    # Position 1: Red
    sw $t1, 0($t5)
    sw $t1, 4($t5)
    sw $t1, 256($t5)
    sw $t1, 260($t5)
    
    addi $t5, $t4, 8880    # Position 2: Green
    sw $t2, 0($t5)
    sw $t2, 4($t5)
    sw $t2, 256($t5)
    sw $t2, 260($t5)
    
    addi $t5, $t4, 10424     # Position 3: Yellow
    sw $t3, 0($t5)
    sw $t3, 4($t5)
    sw $t3, 256($t5)
    sw $t3, 260($t5)
    
    j end_virus
    
draw_map3:
    # Draw three fixed pixels for map1
    addi $t5, $t4, 6720    # Position 1: Red
    sw $t1, 0($t5)
    sw $t1, 4($t5)
    sw $t1, 256($t5)
    sw $t1, 260($t5)
    
    addi $t5, $t4, 11968    # Position 2: Green
    sw $t2, 0($t5)
    sw $t2, 4($t5)
    sw $t2, 256($t5)
    sw $t2, 260($t5)
    
    addi $t5, $t4, 9288     # Position 3: Yellow
    sw $t3, 0($t5)
    sw $t3, 4($t5)
    sw $t3, 256($t5)
    sw $t3, 260($t5)

end_virus:

### PILL SETUP ################################################################################
jal map_pill
j game_loop

map_pill:
# clear old position
    #load previous values
    lw $t0, prev_x1_pos
    lw $t1, prev_y1_pos
    li $t2, 0x00
    lw $t3, prev_x2_pos
    lw $t4, prev_y2_pos
    la $t6, map     
    # clear previous half-1
    mul $t7, $t1, 64    # Multiply Y * 64 (# of columns)
    add $t7, $t7, $t0   # Add X
    sll $t7, $t7, 2     # byte offset
    add $t7, $t7, $t6   # add to map address
    sw $t2, 0($t7)
    sw $t2, 4($t7)
    sw $t2, 256($t7)
    sw $t2, 260($t7)
    # clea previous half-2
    mul $t7, $t4, 64    # Multiply Y * 64 (# of columns)
    add $t7, $t7, $t3   # Add X
    sll $t7, $t7, 2     # byte offset
    add $t7, $t7, $t6   # add to map address
    sw $t2, 0($t7)  
    sw $t2, 4($t7)
    sw $t2, 256($t7)
    sw $t2, 260($t7)

    lw $t0, x1_pos
    lw $t1, y1_pos
    lw $t2, col1
    lw $t3, x2_pos
    lw $t4, y2_pos
    lw $t5, col2
    la $t6, map         # Load base address of array into $t4
    
    mul $t7, $t1, 64    # Multiply Y * 64 (# of columns)
    add $t7, $t7, $t0   # Add X
    sll $t7, $t7, 2     # byte offset
    add $t7, $t7, $t6   # add to map address
    sw $t2, 0($t7)
    sw $t2, 4($t7)
    sw $t2, 256($t7)
    sw $t2, 260($t7)
    
    mul $t7, $t4, 64    # Multiply Y * 64 (# of columns)
    add $t7, $t7, $t3   # Add X
    sll $t7, $t7, 2     # byte offset
    add $t7, $t7, $t6   # add to map address
    sw $t5, 0($t7)  
    sw $t5, 4($t7)
    sw $t5, 256($t7)
    sw $t5, 260($t7)
jr $ra    

### GAME TIME BABY ######################################################################## 

game_loop:

    lw $t0, KEYBOARD_ADDR  # Load keyboard base address
    lw $t1, 0($t0)         # Read if a key is pressed (1 if pressed, 0 if not)
    beq $t1, $zero, draw_map # If no key press we just want t0 redraw screen 

    lw $t2, 4($t0)         # Get ASCII code of key pressed

    # Move pixel based on key press
    beq $t2, 0x77, rotate      # 'w' (0x87 ASCII for w)
    beq $t2, 0x61, move_left   # 'a' (0x61 ASCII for a)
    beq $t2, 0x73, move_down    # 's' (0x73 ASCII for s)
    beq $t2, 0x64, move_right  # 'd' (0x64 ASCII for d)
    beq $t2, 0x71, exit_game   # 'q' (0x71 ASCII for q)
    j draw_map
    
move_down:
#load coordinates+other info
    la $t0, map
    lw $t3, x1_pos
    lw $t4, y1_pos
    lw $t5, x2_pos
    lw $t6, y2_pos
# current position 1: $t8
    mul $t8, $t4, 64    # Multiply Y * 64 (# of columns)
    add $t8, $t8, $t3   # Add X
    mul $t8, $t8, 4     # byte offset
    add $t8, $t8, $t0   # add to map address
# current position 2: $t9
    mul $t9, $t6, 64    # Multiply Y * 64 (# of columns)
    add $t9, $t9, $t5   # Add X
    sll $t9, $t9, 2     # byte offset
    add $t9, $t9, $t0   # add to map address
# check orientation and split to check next row accordingly 
    beq $t4, $t6, horiz_down
    blt $t6, $t4, side_2_down 
    #j side_3_down # else side 1 down
    
horiz_down:
    addi $t8, $t8, 512
    addi $t9, $t9, 512
    lw $t1, 0($t8)
    lw $t2, 0($t9)
    li $t7, 0x00
    bne $t1, $t7, draw_map
    bne $t2, $t7, draw_map
# else there's space
# update y1
    sw $t4, prev_y1_pos
    addi $t4, $t4, 2    # Increase y1 by 2 (move down)
    sw $t4, y1_pos
# update y2
    sw $t6, prev_y2_pos
    addi $t6, $t6, 2    # Increase y2 by 2 (move down)
    sw $t6, y2_pos
# update prev_x1 and prev_x2
    sw $t3, prev_x1_pos
    sw $t5, prev_x2_pos
    
    jal map_pill
    j draw_map

side_2_down:
    

   
move_left:
    lw $t3, x1_pos
    sw $t3, prev_x1_pos  # store current x in prev_x1
    addi $t3, $t3, -2    # decrease x1 by 2 (move down)
    sw $t3, x1_pos       # store new x in x1_por
    
    lw $t5, x2_pos
    sw $t5, prev_x2_pos
    addi $t5, $t5, -2    # decrease x2 by 2 (move down)
    sw $t5, x2_pos
    # update prev_x1 and prev_x2
    lw $t3, y1_pos
    sw $t3, prev_y1_pos
    lw $t5, y2_pos
    sw $t5, prev_y2_pos
    
    jal map_pill
    j draw_map
 
    
move_right:
    lw $t3, x1_pos
    sw $t3, prev_x1_pos  # store current x in prev_x1
    addi $t3, $t3, 2    # decrease x1 by 2 (move down)
    sw $t3, x1_pos       # store new x in x1_por
    
    lw $t5, x2_pos
    sw $t5, prev_x2_pos
    addi $t5, $t5, 2    # decrease x2 by 2 (move down)
    sw $t5, x2_pos
    # update prev_x1 and prev_x2
    lw $t3, y1_pos
    sw $t3, prev_y1_pos
    lw $t5, y2_pos
    sw $t5, prev_y2_pos
    
    jal map_pill
    j draw_map


rotate:
    # check current orientation
    # move to next orientation
    # - 0: 1 2      next: 1
    #
    # - 1: 1        next: 2
    #      2
    # - 2:          next: 3
    #      2 1
    # - 3:   2      next: 0
    #        1
    lw $t3, orientation 
    beq $t3, 0, S0
    beq $t3, 1, S1
    beq $t3, 2, S2
    beq $t3, 3, S3
    
    S0:
    # x2 -= 2
    lw $t8, x2_pos
    sw $t8, prev_x2_pos
    addi $t8, $t8, -2 
    sw $t8, x2_pos
    # y2 += 2
    lw $t8, y2_pos
    sw $t8, prev_y2_pos
    addi $t8, $t8, 2 
    sw $t8, y2_pos
    # update prev x1,y1 to match current x1,y1
    lw $t4, x1_pos
    sw $t4, prev_x1_pos
    lw $t5, y1_pos
    sw $t5, prev_y1_pos
    # load orientation=1
    li $t3, 1
    sw $t3, orientation
    jal map_pill
    j draw_map
    
    S1:
    # x1 += 2
    lw $t8, x1_pos
    sw $t8, prev_x1_pos
    addi $t8, $t8, 2 
    sw $t8, x1_pos
    # y1 += 2
    lw $t8, y1_pos
    sw $t8, prev_y1_pos
    addi $t8, $t8, 2 
    sw $t8, y1_pos
    # update prev x2,y2 to match current x2,y2
    lw $t3, x2_pos
    sw $t3, prev_x2_pos
    lw $t5, y2_pos
    sw $t5, prev_y2_pos
    # load orientation=2
    li $t3, 2
    sw $t3, orientation
    jal map_pill
    j draw_map
    
    S2:
    # x2 += 2
    lw $t8, x2_pos
    sw $t8, prev_x2_pos
    addi $t8, $t8, 2 
    sw $t8, x2_pos
    # y2 -= 2
    lw $t8, y2_pos
    sw $t8, prev_y2_pos
    addi $t8, $t8, -2 
    sw $t8, y2_pos
    # update prev x1,y1 to match current x1,y1
    lw $t4, x1_pos
    sw $t4, prev_x1_pos
    lw $t5, y1_pos
    sw $t5, prev_y1_pos
    # load orientation=3
    li $t3, 3
    sw $t3, orientation
    jal map_pill
    j draw_map
    
    S3:
    # x1 -= 2
    lw $t8, x1_pos
    sw $t8, prev_x1_pos
    addi $t8, $t8, -2 
    sw $t8, x1_pos
    # y1 -= 2
    lw $t8, y1_pos
    sw $t8, prev_y1_pos
    addi $t8, $t8, -2 
    sw $t8, y1_pos
    # update prev x2,y2 to match current x2,y2
    lw $t4, x2_pos
    sw $t4, prev_x2_pos
    lw $t5, y2_pos
    sw $t5, prev_y2_pos
    # load orientation=0
    sw $zero, orientation
    jal map_pill
    j draw_map
    

### DRAWING #############################################################################
draw_map:
    li $t0, 0           # Row counter (starting at 0)
    li $t1, 0           # Column counter (starting at 0)
    li $t2, 64          # Number of rows
    li $t3, 64          # Number of columns 
    la $t4, map         # Load base address of array into $t4
    lw $t5, DISPLAY_ADDR
    
    draw_rows:
    bge $t0, $t2, finish_drawing  # If row counter >= 20, end loop
    # Calculate base address for the current row
    mul $t6, $t0, $t3   # Multiply row index by number of columns
    sll $t6, $t6, 2     # Multiply by 4 to get byte offset (each word is 4 bytes)
    add $t8, $t6, $t4   # add to base map
    add $t9, $t6, $t5   # add to display address

    draw_columns:
    bge $t1, $t3, draw_next_row  # If column counter >= 38, move to the next row
    # Load value from 
    lw $t7, 0($t8)        # Get value from the current row, column position
    sw $t7, 0($t9) 
    addi $t8, $t8, 4      # Move to the next column in the current row (map)
    addi $t9, $t9, 4      # Move to the next column in the current row (display)
    addi $t1, $t1, 1      # Increment column counter
    j draw_columns        # Continue looping through columns

    draw_next_row:
    addi $t0, $t0, 1      # Increment row counter
    li $t1, 0             # Reset column counter
    addi $t8, $t8, 4      # next line
    addi $t9, $t9, 4
    j draw_rows           # Continue looping through rows
    
    finish_drawing:
    li $a0, 0
    syscall
    j game_loop
    

exit_game:
    li $v0, 10  # Exit syscall (MIPS system call for exit)
    syscall
