
li $t0, 0   # row counter
li $t1, 0   # column counter
li $t2, 64  # height
li $t3, 64  # width
li $t4, 0xCA00AA    # white, unlike us
li $t5, 0x10008000

draw_pixel:
bge $t1, $t3, next_line
sw $t4, 0($t5)
addi $t5, $t5, 4
addi $t1, $t1, 1
j draw_pixel

next_line:
bge $t0, $t2, done
li $t1, 0
addi $t0, $t0, 1
j draw_pixel

done:
