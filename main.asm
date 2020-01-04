.data
# -9999 marks end of the list
firstList: .word 8, 3, 6, 10, 13, 7, 4, 5, -9999

exitNumber: .word -9999
index: .word 0
tree: .word 16
# other examples for testing your code
secondList: .word 8, 3, 6, 6, 10, 13, 7, 4, 5, -9999
thirdList: .word 8, 3, 6, -9999, 10, 13, 7, 4, 5, -9999
fourthList: .word 8, 3, -3, 6, -10, 13, -7, 4, 5, -9999

# assertEquals data
failf: .asciiz " failed\n"
passf: .asciiz " passed\n"
menu: .asciiz "Press 1 to start insertion process(till -9999 as an input)\nPress 2 to find value in inserted Tree\nPress 3 to find Minimum\nPress 4 to find max\n"
asertNumber: .word 0

space: .asciiz " "
line: .asciiz "-"
Xsign: .asciiz "X "
newLine: .asciiz "\n"

.text
main:
    
    # create root node here and load its address to $a1 and $s0
    
    li $v0, 9
    lw $a0, tree
    syscall                 # DYNAMICALLY ALLOCATING MEMORY OF SIZE 4 BYTES AT ADDRESS OF VAR
 
    la $a0, firstList 

 #   sw $v0, tree
#head node is initialized here
    lw $t1, 0($a0)
    move $t5,$v0
    sw $t1,0($t5)
    sw $zero,4($t5)
    sw $zero,8($t5)
    sw $zero,12($t5)
#address of head node assigned s0
    move $s0,$t5
#arguments are given

    move $a1, $t5

    jal build

    lw $t0, 4($s0) # real address of the left child of the root
    lw $a0, 0($t0) # real value of the left child of the root
    li $a1, 3 # expected value of the left child of the root
    # if left child != 3 then print failed 
    jal assertEquals

    li $a0, 11
    move $a1, $s0
    jal insert
    lw $a1, 0($v0)
    # if returned address's value != 11 print failed 
    jal assertEquals

    move $a0, $s0
    li $a1, 11
    jal find
    # if returned address's value != 11 print failed 
    lw $a0, 0($v1)
    jal assertEquals

    move $a0, $s0
    li $a1, 44
    jal find
    # if returned value of $v0 != 0 print failed
    move $a0, $v0
    li $a1, 0
    jal assertEquals

    # this test only works with the first 3 lists. 
    # if 4th list is used change the value of $a1 to -10 from 3 before calling last assertEquals
    move $a0, $s0
    li $a1, 0
    jal findMinMax
    # if returned address's value != returned value fail
    lw $a0,0($v1)
    move $a1, $v0
    jal assertEquals
    # if returned address's value != expected value of min node
    lw $a0,0($v1)
    li $a1, 3
    jal assertEquals

    move $a0, $s0
    li $a1, 1
    # if returned address's value != returned value fail
    jal findMinMax
    lw $a0,0($v1)
    move $a1, $v0
    jal assertEquals
    # if returned address's value != expected value of max node
    lw $a0,0($v1)
    li $a1, 13
    jal assertEquals


    move $a0, $s0
    jal print

    li $v0, 10
    syscall

assertEquals:
    move $t2, $a0
    # increment count of total assertions.
    la $t0, asertNumber
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    sw $t1, 0($t0) 
    add $a0, $t1, $zero
    li $v0, 1
    syscall

    # print passed or failed.
    beq $t2, $a1, passed
    la $a0, failf
    li $v0, 4
    syscall
    j $ra
passed:
    la $a0, passf
    li $v0, 4
    syscall
    j $ra


build:
    li $s7 ,-9999

    addi $sp, $sp, -4      
    sw $ra, 0($sp)


    lw $t3,index  #index =t3
    #for head node 
    #a1 is the begining of the head node
    
    #a1 will be send to the insert func.
loop:
    move $a1, $s0
    addi $t3,$t3, 4  #index arttırma
    lw  $t1 , firstList($t3) #valueyi yükleme
    move $a0,$t1#
    beq $t1, $s7 , endbuild
    jal insert
    j loop
endbuild:
    lw $ra, 0($sp) 
    addi $sp, $sp, 4  
    j $ra


insert:
        
    #en alt katmana ulaşma
    move $a1, $s0
while: 
    lw  $t5,0($a1)  
    blt $t5,$a0,right
    bgt $t5,$a0,left
right:
    lw $t6,8($a1)
    li $t7,1
    beq $t6, 0, addHere #0 gördüğünde node a ekliyor
    move $a1,$t6 # 
    j while
left:
    lw $t6,4($a1)
    li $t7,0
    beq $t6, 0, addHere #0 gördüğünde node a ekliyor
    move $a1,$t6 # 
    j while
addHere:
    move $t0,$a0
    li $v0, 9
    lw $a0, tree
    syscall                 # DYNAMICALLY ALLOCATING MEMORY OF SIZE 4 BYTES AT ADDRESS OF VAR

    move $s2,$v0 #assignment to ensure the parents child information to parent 
    # right node ise t7 =1, left node t7=0
    beq $t7,1 rightAssignment
    beq $t7,0, leftAssignment

    rightAssignment: 
    sw $t0,0($s2)
    sw $zero,4($s2)
    sw $zero,8($s2)
    sw $a1,12($s2)

    move $a0,$t0

    sw $s2 ,8($a1)
    move $v0,$s2# to return  adress of new node 
    j end

    leftAssignment:
    sw $t0,0($s2)
    sw $zero,4($s2)
    sw $zero,8($s2)
    sw $a1,12($s2)

    move $a0,$t0

    sw $s2 ,4($a1)
    move $v0,$s2 # to return  adress of new node 
    j end
end:    
    j $ra

find:
whileFind: 
    lw  $t5,0($a0)
    beq $t5,$a1,Found  
    blt $t5,$a1,rightFind
    bgt $t5,$a1,leftFind
rightFind:
    lw $t6,8($a0)
    beq $t6, 0, notFound #
    move $a0,$t6 #
    j whileFind
leftFind:
    lw $t6,4($a0)
    beq $t6, 0, notFound #
    move $a0,$t6 # 
    j whileFind
notFound:
    li $v0,0
    j $ra
Found:
    li $v0,1
    move $v1,$t6
    j $ra
findMinMax:
    addi $sp, $sp, -8      
    sw $t0, 0($sp)
    sw $t1, 4($sp)

    li $t0,0
    li $t1,1
    beq $a1,$t0,findMin
    beq $a1,$t1,findMax
 
findMin:
    whileFindMin: 
    lw  $t5,0($a0)#value
    lw $t6,4($a0)
    beq $t6, 0, findMinEnd #
    move $a0,$t6 # 
    j whileFindMin
findMinEnd:
    move $v0 ,$t5
    move $v1 ,$a0
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    addi $sp, $sp, 8   
    j $ra
findMax:
 whileFindMax: 
    lw  $t5,0($a0)#value
    lw $t6,8($a0)
    beq $t6, 0, findMaxEnd #
    move $a0,$t6 #
    j whileFindMax
findMaxEnd:
    move $v0 ,$t5
    move $v1 ,$a0
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    addi $sp, $sp, 8   
    j $ra
levelCounter:
    addi $sp, $sp, -16      
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t5, 8($sp)
    sw $t6, 12($sp)

    addi $t0,1
    addi $t1,1

    whileLeftCounter: #$t0
        lw  $t5,0($a0)#value
        lw $t6,8($a0)
        beq $t6, 0, whileRightCounter #0 gördüğünde node a ekliyor
        move $a0,$t6 #
        addi $t0,1
        j whileLeftCounter
    whileRightCounter: #$t1
        lw  $t5,0($a0)#value
        lw $t6,8($a0)
        beq $t6, 0, endCounter #
        addi $t1,1
        move $a0,$t6 # 
        j whileRightCounter
    endCounter:
        addi $t0,1
        addi $t1,1
        bgt $t1,$t0,rightGreater
        j leftGreater
    rightGreater:
        move $v0,$t1
        j cont
    leftGreater:
        move $v0,$t0
        j cont
    cont:
        lw $t0, 0($sp)
        lw $t1, 4($sp)
        lw $t5, 8($sp)
        lw $t6, 12($sp)
        addi $sp, $sp, 16 
        j $ra
#argument level
#head


print:
    addi $sp, $sp,-4
    sw $ra, 0($sp) 

    move $a0, $s0
    jal levelCounter #v0 da katman sayısı var
    move $a0, $s0 #level counterda bozulan head degerini tazeledık
    move $t7, $v0 #t7 e level counter sayısını ekledik
    li $t5,1  # o print hangi levelda olcağının belirteci
    
    lw $a1,0($a0)
    jal printIntegerAndSpace
    jal printNewLine

    addi $t5,$t5,1

    j printEnd
    #beq $t5,$t7,printEnd
    #move $a0, $s0
    #la $a1,4($a0)
    #lw $a1,0($a0)
    #jal printIntegerAndSpace

    #move $a0, $s0
    #la $a1,8($a0)
    #lw $a1,0($a0)
    #jal printIntegerAndSpace
    #jal printNewLine


printEnd:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    j $ra 

printIntegerAndSpace:
    move $s0,$a1
    li $v0,1
    move $a0,$s0
    syscall

    la  $t1 , space
    move $a0,$t1
    li $v0,4
    syscall

    j $ra#a1 de integer alıyor

printNewLine:
    la  $t1 , newLine
    move $a0,$t1
    li $v0,4
    syscall

    j $ra

printX:
    la  $t1 , Xsign
    move $a0,$t1
    li $v0,4
    syscall

    j $ra