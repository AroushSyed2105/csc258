    .data
map: .space 6840  # Allocate space for 45 rows * 38 columns * 4 bytes per word (since each word is 4 bytes) = 6840bytes


    .text
    .globl main
    
### STORING WHITE ############################################################

main:
    li $t0, 0           # Row counter (starting at 0)
    li $t1, 0           # Column counter (starting at 0)
    li $t2, 256          # Number of rows
    li $t3, 256          # Number of columns 

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
    li $t7, 0xFFFFFF      # Just an example value to store (could be computed)
    sw $t7, 0($t6)        # Store value at the current row, column position

    addi $t6, $t6, 4      # Move to the next column in the current row
    addi $t1, $t1, 1      # Increment column counter
    j loop_columns        # Continue looping through columns

next_row:
    addi $t0, $t0, 1      # Increment row counter
    j loop_rows           # Continue looping through rows

end_loop:














### DRAWING #########################################################

draw_white:
la $t0, map
li $a0, 0x10008000      # display address because for some reason it doesn't like calling it from memory
li $t1, 256             # $t1: max rows
li $t2, 256             # $t2: max columns
li $t3, 0               # $t3: row counter
li $t4, 0               # $t4: column counter
li $t5, 0               # $t5: address of current cell

loop_rows2:
bge $t3, $t1, end_draw

mul $t5, $t2, $t3       # multiply current row by number of columns to get address of row start
sll $t5, $t5, 2         # multiply by 4 for byte offset
add $t5, $t5, $a0       # add display address so we can actually draw
li $t4, 0               # reset column counter
addi $t3, $t3, 1        # increment row counter

loop_columns2:
bge $t4, $t2, loop_rows2        # if parsed all columns in the current row, jump back to loop_rows2 to go to the next row

lw $t7, $t5($t0)                # loading value (color) into $t7
sw $t7, 0($t5)                  # drawing
addi $t5, $t5, 4                # moving to next cell/value/location in array
addi $t4, $t4, 1                # increment column counter
j loop_columns2                 # jump back to loop_rows2 to go to next row


end_draw:
