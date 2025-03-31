.data
map: .space 16384  # Allocate space for 64 rows * 64 columns * 4 bytes per word (since each word is 4 bytes) = 6840bytes
DISPLAY_ADDR:   .word 0x10008000  # Memory-mapped address for the display

first_of_color: .word 0x10010000
.text
### MAP ARRAY SETUP ############################################################

main:
    li $t0, 0           # Row counter (starting at 0)
    li $t1, 0           # Column counter (starting at 0)
    li $t2, 10          # Number of rows
    li $t3, 10          # Number of columns 

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

### STORE VALUES IN MAP #######################################################

la $t0, map
li $t3, 0xF00000 # red
li $t4, 0x00F000 # green
li $t5, 0x0000F0 # blue


sw $t3, 0($t0)
sw $t4, 4($t0)
sw $t4, 8($t0)
sw $t4, 12($t0)
sw $t4, 16($t0)
sw $t4, 20($t0)
sw $t5, 24($t0)
sw $t3, 28($t0)
sw $t5, 32($t0)
sw $t5, 36($t0)
sw $t5, 40($t0)
sw $t5, 44($t0)

addi $t0, $t0, 48
sw $t3, 0($t0)
sw $t4, 4($t0)
sw $t4, 8($t0)
sw $t5, 12($t0)
sw $t5, 16($t0)
sw $t3, 20($t0)
sw $t5, 24($t0)
sw $t3, 28($t0)
sw $t5, 32($t0)
sw $t5, 36($t0)
sw $t5, 40($t0)
sw $t5, 44($t0)

addi $t0, $t0, 48
sw $t3, 0($t0)
sw $t4, 4($t0)
sw $t4, 8($t0)
sw $t3, 12($t0)
sw $t4, 16($t0)
sw $t4, 20($t0)
sw $t5, 24($t0)
sw $t3, 28($t0)
sw $t5, 32($t0)
sw $t5, 36($t0)
sw $t5, 40($t0)
sw $t5, 44($t0)

addi $t0, $t0, 48
sw $t3, 0($t0)
sw $t3, 4($t0)
sw $t4, 8($t0)
sw $t3, 12($t0)
sw $t4, 16($t0)
sw $t4, 20($t0)
sw $t5, 24($t0)
sw $t3, 28($t0)
sw $t5, 32($t0)
sw $t5, 36($t0)
sw $t5, 40($t0)
sw $t5, 44($t0)

addi $t0, $t0, 48
sw $t3, 0($t0)
sw $t4, 4($t0)
sw $t4, 8($t0)
sw $t4, 12($t0)
sw $t3, 16($t0)
sw $t3, 20($t0)
sw $t3, 24($t0)
sw $t3, 28($t0)
sw $t5, 32($t0)
sw $t5, 36($t0)
sw $t5, 40($t0)
sw $t5, 44($t0)

jal draw_map

    
### PARSE ROW BY ROW #######################################################################

    li $t0, 0           # Row counter (starting at 0)
    li $t1, 0           # Column counter (starting at 0)
    li $t2, 10          # Number of rows
    li $t3, 9          # Number of columns 
    la $t4, map         # Load base address of array into $t4
    li $t6, 1           # number of same color
    li $t7, 0x00        # black
    
    # Calculate base address for the current row
    add $t8, $zero, $t4   # start address: map address
    
    parse_rows:
    bge $t0, $t2, finish_searching  # If row counter >= 10, end loop
    
    parse_columns:
    bge $t1, $t3, parse_next_row  # If column counter >= 10, move to the next row
    
    lw $a0, 0($t8)          # Get color from the current row, column position
    lw $a1, 4($t8)          # Get color from the next row, column position
    
    beq $a0, $a1, increment_counter
    bne $a0, $a1, reset_counter
    
        increment_counter:  # next color same as current color
        addi $t6, $t6, 1    # increment color counter
        beq $t1, 8, reset_counter
        j continue_parsing
        
        #_____________________________________________#
        reset_counter:  # next color different to current color
        bge $t6, 4, clear           # if more then 4 in a row, jump to clear function
        addi $t9, $t8, 4
        sw $t9, first_of_color      # else, save next pixel to first_of_color
        li $t6, 1                   # and reset color counter
        j finish_clearing
    
        #_____________________________________________#
        clear:
        #lw $t5, first_of_color      # first pixel to clear
        li $a3, 0                   # clear loop pixel counter
        
        clear_loop:
        bge $a3, $t6, finish_clearing
        sw $t7, 0($t9)              # clear current pixel (starts at first of color)
        
        addi $t9, $t9, 4            # move to next pixel
        addi $a3, $a3, 1            # increment loop counter
        j clear_loop
        
        finish_clearing:
        sw $t9, first_of_color
        li $t6, 1
        
        continue_parsing:
        
    addi $a0, $a0, 4      # Move to the next column in the current row (map)
    addi $t1, $t1, 1      # Increment column counter
    addi $t8, $t8, 4
    j parse_columns        # Continue looping through columns

    parse_next_row:
    #addi $t6, $6, -1
    bge $t6, 4, clear           # if more then 4 in a row, jump to clear function
    addi $t0, $t0, 1      # Increment row counter
    li $t1, 0             # Reset column counter
    li $t6, 1             # Reset color counter
    addi $t8, $t8, 4      # go to next row
    add $t9, $t8, $zero   # Update first of current color to be first of row
    j parse_rows           # Continue looping through rows
    
    finish_searching:
    jal draw_map
    
### PARSE COLUMN BY COLUMN #######################################################################
    
    li $t0, 0           # Column counter (starting at 0)
    li $t1, 0           # Row counter (starting at 0)
    li $t2, 10          # Number of columns
    li $t3, 9           # Number of rows 
    la $t4, map         # Load base address of array into $t4
    li $t6, 1           # number of same color
    li $t7, 0x00        # black
    
    # Calculate base address for the current row
    add $t8, $zero, $t4   # start address: map address
    
    search_columns:
    bge $t0, $t2, finish_searching_again  # If column counter >= 10, end loop
    
    search_rows:
    bge $t1, $t3, search_next_column   # If row counter >= 9, move to the next row
    
    lw $a0, 0($t8)          # Get color from the current position
    lw $a1, 40($t8)         # Get color from the next position
    
    beq $a0, $a1, increment_color
    bne $a0, $a1, reset_color
    
        increment_color:  # next color same as current color
        addi $t6, $t6, 1    # increment color counter
        beq $t1, 8, reset_color
        j continue_searching
        
        #_____________________________________________#
        reset_color:  # next color different to current color
        bge $t6, 4, clear_column    # if more then 4 in a column, jump to clear function
        addi $t9, $t8, 40           # go to next line
        li $t6, 1                   # and reset color counter
        j finish_clearing
    
        #_____________________________________________#
        clear_column:
        #lw $t5, first_of_color      # first pixel to clear
        li $a3, 0                   # clear loop pixel counter
        
        clear_column_loop:
        bge $a3, $t6, finish_clearing_column
        sw $t7, 0($t9)              # clear current pixel (starts at first of color)
        
        addi $t9, $t9, 4            # move to next pixel
        addi $a3, $a3, 1            # increment loop counter
        j clear_loop
        
        finish_clearing_column:
        li $t6, 1
        
        continue_searching:
        
    addi $a0, $a0, 4      # Move to the next column in the current row (map)
    addi $t1, $t1, 1      # Increment column counter
    addi $t8, $t8, 4
    j search_columns        # Continue looping through columns

    search_next_column:
    #addi $t6, $6, -1
    bge $t6, 4, clear_column            # if more then 4 in a row, jump to clear function
    addi $t0, $t0, 1                    # Increment column counter
    li $t1, 0                           # Reset row counter
    li $t6, 1                           # Reset color counter
    sll $t8, $t6, 2                     # go to next column (byte offset of column counter)
    add $t8, $t8, $t4                   # add to map address to get next column start
    add $t9, $t8, $zero   # Update first of current color to be first of row
    j search_columns           # Continue looping through columns
    
    finish_searching_again:
    jal draw_map

    
    
    
### DRAW #########################################################################################

draw_map:
    li $t0, 0           # Row counter (starting at 0)
    li $t1, 0           # Column counter (starting at 0)
    li $t2, 10          # Number of rows
    li $t3, 10          # Number of columns 
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
    
    finish_drawing: jr $ra


end: