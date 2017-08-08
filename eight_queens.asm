	.data 
	str:.asciiz "Eight Queen problems, entering the number of queens:"
	.text
main:
	add $a1,$0,$0 # $a1=iCount=0
	add $k0,$0,$0 # $k0=Queen::n=0
	li $v0,4
	la $a0,str # print string
	syscall
	li $v0,5 # read the input number n
	syscall
	add $a2,$0,$v0 # $a2=n=the input number=Queen::QUEENS
	jal Queen # go to Queen, the return value is $a1
	add $a0,$a1,$0 # put the return value of $a1 into $a0 in order to print
	li $v0,1 # print integer
	syscall
	li $v0,10 # exit
	syscall
Queen:
	addi $sp,$sp,-12 # push stack
			 # in the recursion process only n and i need to save
	sw $ra,8($sp)
	sw $t7,4($sp) # $t7=Queen::i
	sw $k0,0($sp) # $k0=Queen::n
calculate: # avoid useless sw instructs
	beq $k0,$a2,count # if n==QUEENS go to count
	addi $t7,$0,1 # i=1
loop1:
	slt $v1,$a2,$t7 # if QUEENS<i $v1=1
	beq $v1,1,exit # if i>QUEENS go to exit
	sll $t8,$k0,2 # $t8=4*n
	add $t8,$t8,$gp # $t8=4*n+$gp,address transform
	sw $t7,0($t8) # site[n]=i
	add $k1,$0,$ra # save $ra in order to jump back to main
	jal Valid # go to Valid, the return number is $s0
	add $ra,$0,$k1 # refresh $ra 
	beq $s0,1,cycle # if Valid(n)==1 go into cycle
	addi $t7,$t7,1 #Queen::i++
	j loop1 
count:
	add $a1,$a1,1 # if n==QUEENS iCount=iCount+1, return iCount
	lw $k0,0($sp) # pop stack
	lw $t7,4($sp)
	lw $ra,8($sp)
	addi $sp,$sp,12
	jr $ra # go to main
cycle:
	jal queen # the recursion process
	addi $t7,$t7,1 # Queen::i++
	j loop1
queen:
	addi $sp,$sp,-12 # push stack
	sw $ra,8($sp)
	sw $t7,4($sp)
	sw $k0,0($sp)
	addi $k0,$k0,1 # new n=old n+1
	jal calculate # go to the Queen function
	lw $k0,0($sp) # pop stack
	lw $t7,4($sp)
	lw $ra,8($sp)
	addi $sp,$sp,12
	jr $ra # jump back to loop1 and the next operation is Queen::i++
exit: # when the loop is over, return iCount
	lw $k0,0($sp) # pop stack
	lw $t7,4($sp)
	lw $ra,8($sp)
	addi $sp,$sp,12
	jr $ra # return back to main
Valid:
	add $t0,$0,$0 # $t0=i=0,$k0=n
loop2:
	slt $t1,$t0,$k0 # if i<n $t1=1
	beq $t1,$0,return1 # if i>=n go to return1
	sll $t2,$t0,2 # $t2=4*i
	sll $t3,$k0,2 # $t3=4*n
	add $t2,$t2,$gp # $t2=$gp+4*i,address transform
	add $t3,$t3,$gp # $t3=$gp+4*n,address transform
	lw $t2,0($t2) # $t2=site[i]
	lw $t3,0($t3) # $t3=site[n]
	sub $t4,$t2,$t3 # $t4=site[i]-site[n]
	abs $t4,$t4 # $t4=abs(site[i]-site[n])
	sub $t5,$k0,$t0 # $t5=n-i
	beq $t4,$0,return0 # if site[i]==site[n] go to return0
	                   # here use the value of abs(site[i]-site[n]) to judge
	                   # can save one instruct
	beq $t4,$t5,return0 # if abs(site[i]-site[n])==n-i go to return 0
	addi $t0,$t0,1 # Valid::i++
	j loop2
return1:
	add $s0,$0,1 # set the return value 1
	jr $ra # jump back to Queen
return0:
	add $s0,$0,0 # set the return value 0
	jr $ra # jump back to Queen
