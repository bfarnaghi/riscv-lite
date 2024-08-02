.data:  
v:
.word 0x00000009
.word 0x00000000
.word 0xffffffd2
.word 0xffffffff
.word 0x00000015
.word 0x00000000
.word 0xfffffffe
.word 0xffffffff
.word 0x0000000e
.word 0x00000000
.word 0x0000001a
.word 0x00000000
.word 0xfffffffd
.word 0xffffffff

	.text:  
	.global _start

_start:  
auipc gp,0x1fc18 
addi gp,gp,28 
auipc sp,0x7fbff 
addi sp,sp,-12 
add s0,sp,zero 
jal ra,main

el:  
j el

  

main:  
lui a0,0x10010 
addi sp,sp,-16 
li a1,7 
mv a0,a0 
sw ra,12(sp) 
jal ra,minv
lw ra,12(sp) 
lui a5,0x10010 
sw a0,28(a5) 
li a0,0 
addi sp,sp,16 
ret 

minv:  
lw a2,0(a0) 
li a4,1 
srai a5,a2,0x1f 
xor a2,a5,a2 
sub a2,a2,a5 
ble a1,a4,l1
slli a1,a1,0x2 
addi a4,a0,4 
add a0,a0,a1 
l3:lw a5,0(a4) 
addi a4,a4,4 
srai a3,a5,0x1f 
xor a5,a3,a5 
sub a5,a5,a3 
ble a2,a5,l2
mv a2,a5 
l2:bne a0,a4,l3
l1:mv a0,a2 
ret 
