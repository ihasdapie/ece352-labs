	sub	k1,k1	; clear all registers
	sub	k0,k0
	sub	k2,k2
	sub	k3,k3
	ori	16	; load 16 into k1
	add	k2,k1	; set k2 to 16
	shiftl	k2,2	; multiply k2 by 4, giving 64
	load	k0,(k2)	; load value 120 from memory location 64
	sub	k1,k1	; clear k1 again
	ori	1	; set k1 to 1

loop1	store	k0,(k2)	; store value of k0 to memory
	load	k3,(k2) ; read it back to k3
	add	k3,k1	; increment value by 1
	add	k2,k1	; increment memory pointer by 1
	add	k0,k1	; increment k0 by 1
	bpz	loop1	; loop while a positive number

; at this point, k0 == k3 == -128 == 0x80, k1 == 1, k2 == 72 == 0x48

	add	k3,k1	; increment k3, leaving it at -127
	; get twos complement of k3
	ori	31	; sets k1 to 0x1f
	shiftl	k1,3	; sets k1 to 0xf8
	ori	7	; kets k1 to 0xff
	nand	k3,k1	; toggles all the bits of k3, leaving it as 0x7e
	shiftr	k1,3	; shift k1 right by 3, leaving 0x1f
	shiftr	k1,2	; shift k1 right by 2, leaving 0x07
	shiftr	k1,2	; shift k1 right by 2, leaving 0x01
	add	k3,k1	; increment k3 by 1

; at this point, k0 == -128, k1 == 1, k2 == 72, and k3 == +127

	add	k0,k1	; increment k0 by 1 to get -127
	add	k3,k0	; should leave k3 as 0	

	org	64


ori 0x64        ; k1 = 0x10
vload v0 (k1)  ; vector load starting from address 64 into v0
ori 0x68
vload v1 (k1)  ; vector load starting from address 0x14 into v1
vadd v0 v1     ; vector add v0 and v1 result into v0
ori 0x16
vstore v0 (k1) ; write v0 starting at address 0x10

lbl	db 0x10
