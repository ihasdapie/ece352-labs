ori 16        # k1 = 0x10
vload v0 (k1)  # vector load starting from address 0x10 into v0
ori 20 
vload v1 (k1)  # vector load starting from address 0x14 into v1
vadd v0 v1     # vector add v0 and v1 result into v0
ori 0x10
vstore v0 (k1) # write v0 starting at address 0x10
stop

	org 16
v0lbl	db 252
	org	20
v1lbl	db 123
