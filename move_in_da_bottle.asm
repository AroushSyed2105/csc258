.data
# Bitmap Display Base Address
DISPLAY_ADDR:   .word 0x10008000  # Memory-mapped address for the display
KEYBOARD_ADDR:  .word 0xffff0000  # Memory-mapped address for the keyboard

# Initial pixel position (X=32, Y=32) (center of 64x64 screen)

# .word used for allocating and initalizing variable
# okay full honesty when i was first starting this yestersay i saw this crappy video
# and people used variable for x_pos and y_pos just to make it easier when updating

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
col1: .word 0           # designates memory to col1
col2: .word 0           # designates memory to col2
map: .word 0

# Screen Width
SCREEN_WIDTH: .word 64  # Screen width is 64 pixels

.text
    # assign col1 & col2 & map
    jal random
    sw $t7, col1
    jal random
    sw $t7, col2
    
    jal random              # Get random number in $a0
    ble $a0, 5, set_map_1        # If random <= 5, jump to map1
    ble $a0, 10, set_map_2       # If random <= 10, jump to map2
    # Otherwise, map=3
    li $t1, 3
    sw $t1, map
    j skip
    
    set_map_1:
    li $t1, 1
    sw $t1, map
    j skip
    set_map_2:
    li $t1, 2
    sw $t1, map
    
    skip:

    # Setup frame delay (60 FPS)
    li $v0, 32         # System call for sleep
    # li $a0, 16666      saw this online im not sure if its needed when settig upo FPS
   

j game_loop

random:
# random seed: stores a random value from 0-15 inclusive in $a0
li $v0, 42
li $a0, 0
li $a1, 16
syscall

color:
# stores one of the 3 colors in $t7 depending on the random number stored in $a0
li $t7, 0xFF5050            # store red in $t7
ble $a0, 5, color_end       # if random <= 5 then keep red and jump to color_end
li $t7, 0x50CC50            # store green in $t7 
ble $a0, 10, color_end      # if random <= 10 then keep green and jump to color_end
li $t7, 0xFFFF50            # store yellow in $t7, random > 10 by this point
color_end:
jr $ra

# START GAME LOOP ####################################################################################

game_loop:
j walls     # skip line drawing methods

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
    jr $ra              # jump back to where we came from
    
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
    
# draw walls ######################################################################################
walls:
    lw $t0, DISPLAY_ADDR       # $t0 = base address for display
    li $t4, 0x5F5F5F            # $t4 = grey
# left wall
    addi $t5, $t0, 3840     # moving down 5 rows      
    addi $t5, $t5, 52       # vert line start
    addi $t6, $zero, 45     # vert line lenght
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
    addi $t5, $t0, 15360    # move 30 rows down to base of bottle
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
    
# draw viruses ###########################################################################################

    li $t1, 0xFF0505        # $t1 = red
    li $t2, 0x00CC30        # $t2 = green
    li $t3, 0xFFCF00        # $t3 = yellow
    lw $t4, map
    beq $t4, 1, draw_map1        # If random <= 5, jump to map1
    beq $t4, 2, draw_map2       # If random <= 10, jump to map2
    j draw_map3                  # Otherwise, jump to map3

  draw_map1:
    # Draw three fixed pixels for map1
    addi $t5, $t0, 12856      # Position 1
    sw $t1, 0($t5) # red
    sw $t1, 4($t5)
    sw $t1, 256($t5)
    sw $t1, 260($t5)  
    addi $t5, $t0, 14920     # Position 2
    sw $t2, 0($t5)          # green
    sw $t2, 4($t5)
    sw $t2, 256($t5)
    sw $t2, 260($t5)
    addi $t5, $t0, 6144     # Position 3
    sw $t3, 3168($t5)       # yellow
    sw $t3, 3172($t5)
    sw $t3, 3424($t5)
    sw $t3, 3428($t5)
    j gameplay

draw_map2:
    # Draw three fixed pixels for map2
    addi $t5, $t0, 9848     # Position 1
    sw $t1, 0($t5)        # red
    sw $t1, 4($t5)
    sw $t1, 256($t5)
    sw $t1, 260($t5)
    addi $t5, $t0, 8560     # Position 2
    sw $t2, 320($t5)       # green
    sw $t2, 324($t5)
    sw $t2, 576($t5)
    sw $t2, 580($t5)
    addi $t5, $t0, 10072     # Position 3
    sw $t3, 352($t5)        # yellow
    sw $t3, 356($t5)
    sw $t3, 608($t5)
    sw $t3, 612($t5)
    j gameplay

draw_map3:
    # Draw three fixed pixels for map3
    addi $t5, $t0, 3584     # Position 1
    sw $t1, 2448($t5)       # red
    sw $t1, 2452($t5)
    sw $t1, 2704($t5)
    sw $t1, 2708($t5)
    addi $t5, $t0, 4096     # Position 2
    sw $t2, 3448($t5)       # yellow
    sw $t2, 3452($t5)
    sw $t2, 3704($t5)
    sw $t2, 3708($t5)
    addi $t5, $t0, 4608     # Position 3   
    sw $t3, 6848($t5)       # green
    sw $t3, 6852($t5)
    sw $t3, 7104($t5)
    sw $t3, 7108($t5)
    j gameplay

# GAMEPLAY ###############################################################################################

gameplay:
    lw $t0, KEYBOARD_ADDR  # Load keyboard base address
    lw $t1, 0($t0)         # Read if a key is pressed (1 if pressed, 0 if not)
    beq $t1, $zero, draw_pixel # If no key press we just want t0 redraw screen 

    lw $t2, 4($t0)         # Get ASCII code of key pressed

    # Move pixel based on key press
    beq $t2, 0x77, rotate     # 'w' (0x87 ASCII for w)
    beq $t2, 0x61, move_left  # 'a' (0x61 ASCII for a)
    beq $t2, 0x73, move_down  # 's' (0x73 ASCII for s)
    beq $t2, 0x64, move_right # 'd' (0x64 ASCII for d)
    beq $t2, 0x71, exit_game  # 'q' (0x71 ASCII for q)
    
draw_pixel:  
    # Clear previous position
    lw $t4, SCREEN_WIDTH    # load screen width ( i have this incase we change display width again)
    
    lw $t3, prev_y1_pos     # loading prev y-coordinate
    mul $t3, $t3, $t4       # calculating row offset (y * width)
    lw $t5, prev_x1_pos     # loading in prev x-coordinate
    add $t3, $t3, $t5       # final pixel index
    sll $t3, $t3, 2         # shift left logically by 2 bits, which is equivalent to multiplying by 4
                            # We do this since pixel memory address are 4 bytes per pixel
                            # sooo the correct memory offset for a pixel needs us to multiplying the pixel index by 4.
    
    lw $t8, prev_y2_pos     # loading prev y-coordinate
    mul $t8, $t8, $t4       # calculating row offset (y * width)
    lw $t9, prev_x2_pos     # loading in prev x-coordinate
    add $t8, $t8, $t9       # final pixel index

    sll $t8, $t8, 2         #  shift left logically by 2 bits, which is equivalent to multiplying by 4
                          

    lw $t6, DISPLAY_ADDR  # Load display base address
    add $t6, $t6, $t3     # add the offset to the base address SOOO we get the exact pixel address

    li $t7, 0x00          # black pixel to erase old pixel
    sw $t7, 0($t6)        # drawing black      
    sw $t7, 4($t6)
    sw $t7, 256($t6)
    sw $t7, 260($t6)
    
    lw $t6, DISPLAY_ADDR  # Load display base address
    add $t6, $t6, $t8
    
    sw $t7, 0($t6)        # drawing black      
    sw $t7, 4($t6)
    sw $t7, 256($t6)
    sw $t7, 260($t6)
    
    # Update previous coordinates
    lw $t3, x1_pos          # load curr x pos into $t3
    sw $t3, prev_x1_pos     # store as the prev x pos
    lw $t4, y1_pos          # load curr y pos into $t4
    sw $t4, prev_y1_pos     # store as the prev y pos
    lw $t8, x2_pos          # repeat for pixel 2
    sw $t8, prev_x2_pos 
    lw $t9, y2_pos  
    sw $t9, prev_y2_pos
    lw $t1, col1            # load color 1 into $t1
    lw $t2, col2            # load color 2 into $t2

    # Draw new position
    ### okay you are going to see that this section is essentially the same as clear prev postion..
    ### THATS BECAUSE IN MY LOGIC I AM PAINTING A BLACK SQUARE ON THE PREV LOCATION
    #### WHEREAS HERE I AM PAINTING A WHITE SQUARE ON NEW LOCATION
    
    lw $t5, SCREEN_WIDTH
    mul $t4, $t4, $t5     # calculating row offset (y * width)
    add $t4, $t4, $t3     # Final pixel index

    sll $t4, $t4, 2       # shift left logically by 2 bits, which is equivalent to multiplying by 4
                          # We do this since pixel memory address are 4 bytes per pixel
                          # sooo the correct memory offset for a pixel needs us to multiplying the pixel index by 4.

    mul $t9, $t9, $t5     # calculating row offset (y * width)
    add $t9, $t9, $t8     # Final pixel index

    sll $t9, $t9, 2 


    lw $t6, DISPLAY_ADDR  # Load display base address
    add $t6, $t6, $t4     # Final memory address for new pixel

    sw $t1, 0($t6)        # Draw new position
    sw $t1, 4($t6)
    sw $t1, 256($t6)
    sw $t1, 260($t6)
    
    lw $t6, DISPLAY_ADDR  # Load display base address
    add $t6, $t6, $t9     # Final memory address for new pixel
    sw $t2, 0($t6)        # Draw new position
    sw $t2, 4($t6)
    sw $t2, 256($t6)
    sw $t2, 260($t6)

    # Sleep (for 60 FPS frame delay)
    syscall
    j game_loop           # Loop back

    # Movement logic
move_down:
    lw $t3, y1_pos
    addi $t3, $t3, 2    # Increase y1 by 2 (move down)
    lw $t5, y2_pos
    addi $t5, $t5, 2    # Increase y2 by 2 (move down)
    li $t4, 62         
    ble $t3, $t4, update_y  # Ensure y does not exceed bounds
    li $t3, 62          # If exceeded, set to max
    j game_loop

update_y:
    sw $t3, y1_pos      # Store updated y position
    sw $t5, y2_pos      # Store updated y position
    j game_loop         # Go back to game loop


move_left:
    lw $t8, x1_pos
    subi $t8, $t8, 2   # Decrease x by 2 (move left)
    lw $t9, x2_pos
    subi $t9, $t9, 2   # Decrease x by 2 (move left)
    bgez $t8, update_x # Ensure x does not go negative
    li $t8, 0          # If negative, reset to 0
    li $t9, 0

update_x:
    sw $t8, x1_pos      # Store updated x position
    sw $t9, x2_pos      # Store updated x position
    j game_loop

move_right:
    lw $t8, x1_pos
    addi $t8, $t8, 2   # Increase x1 by 2 (move right)
    lw $t9, x2_pos
    addi $t9, $t9, 2   # Increase x2 by 2 (move right)
    li $t4, 60         # Max width (64 - 4)
    ble $t8, $t4, update_x  # Ensure x does not exceed bounds
    li $t8, 60         # If exceeded, set to max
    li $t9, 62
    j game_loop

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
    # load orientation=1
    addi $t3, $t3, 1
    sw $t3, orientation
    j game_loop
    
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
    # load orientation=2
    addi $t3, $t3, 1
    sw $t3, orientation
    j game_loop
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
    # load orientation=3
    addi $t3, $t3, 1
    sw $t3, orientation
    j game_loop
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
    # load orientation=0
    sw $zero, orientation
    
    j game_loop

exit_game:
    li $v0, 10  # Exit syscall (MIPS system call for exit)
    syscall
