/* polling lego controller port JP1 */
/* this program polls the sensor values on the Lego Controller and displays them */
/* on DE1-SoC HEX display */

// this one doesn't really work
// the balancing lego hardware that we got was broken 
// and so we didn't get to test this code

.equ GPIO_JP1,	 0xFF200060         	/*GPIO_JP1*/
.equ GPIO_JP2,	 0xFF200070         	/*GPIO_JP2*/
.equ ADDR_REDLEDS, 0xFF200000	 	/* red LEDs*/
.equ ADDR_SWITCHES,  0xFF200040	 	/* switches*/
.equ ADDR_7SEGS_low, 0xFF200020	 	/* 7 segment display 0-3*/
.equ ADDR_7SEGS_high,0xFF200030	 	/* 7 segment display 4-5*/

.text
.global _start

_start:
/*r2 data register GPIO JP1*/
/*r3 motor register (bits 0-9)*/
/*r4 sensor register (bits 10,12,14,16,18)*/
/*r5 valid sensor data bit (11,13,15,17,19)*/
/*r6 sensor 1*/
/*r7 sensor 2*/
/*r8 sensor 3*/
/*r9 sensor 4*/
/*r10 sensor 5*/
/*r11 4 bit HEX value*/



  
 movia sp, 0x02000000                   /* initialize the stack to top of NIOS memory*/
 movia  r2, GPIO_JP1              	/* set (motors, sensors and control (bits 0-17,19-25,30,31) as output, set (control bits 18, 26-29) as inputs*/
 movia  r3, 0x07f557ff              	/* direction register GPIO JP1*/
 stwio  r3, 4(r2)

check:
 	movia  r4, 0xfffffbfe               	  /* enable sensor 0 lego controller enable motor 0 */
    and r4, r4, r9
    stwio  r4, 0(r2)
     
loop: 
 ldwio r5, 0(r2)
 andi  r5, r5,0x800
 bne    r0, r5,loop
 good: 
 ldwio  r6, 0(r2)               	/* get sensor0 value from GPIO JP1*/
 
 
 
 movia  r4, 0xffffeffe               	/* enable sensor 1 lego controller enable motor 0 */
 and r4, r4, r9
 stwio  r4, 0(r2)
 
loop2: 
 
 ldwio r5, 0(r2)
 andi  r5, r5,0x2000					# 10 0000 0000 0000
 beq    r0, r5,good1
 br 	loop2 
 good1: 
 ldwio  r7, 0(r2)               	/* get sensor1 value from GPIO JP1*/
	
 movia  r4, 0xfffffffe               	/* turn  polling off and enable motor 0 */	
 stwio  r4, 0(r2)
 
 
 # sensor values in r6 (s0) r7 (s1)
 
 # r6 on our device is higher by 3
 srli 	r7, r7,27              	 	/* algin polling value for sensor 2 (bits 0-3)*/
 srli   r6, r6,27               	/* align polling value for sensor 1 (bits 0-3)*/
 
 # subi r6, r6, 3
 
 blt r6, r7, ccw
 
 

 
cw:
 movia	 r9, 0xffffffff       #  off
 stwio	 r9, 0(r2) 
 
 movia r4, 262150
 call delay
 
 movia	 r9, 0xfffffffc       #  1100
 stwio	 r9, 0(r2)
 
 movia r4, 262150
 call delay
 
 
 br motorend
 
 ccw:
 movia	 r9, 0xffffffff       #  off
 stwio	 r9, 0(r2) 
  
 movia r4, 262150
 call delay
 
 
 movia	 r9, 0xfffffffe       # 1110
 stwio	 r9, 0(r2)
 
 movia r4, 262150
 call delay
 
 
 br motorend
 
 motorend:
 
 

   
   
   
   
 
 
 
 
 /* display HEX value on Hex Display*/
 

 andi   r12, r7,0xf
 call	hexdisplay
 slli   r14, r12,24

 andi   r12, r6,0xf
 call	hexdisplay
 movia  r14, ADDR_7SEGS_high
 
 stwio  r12, 0(r14)

 br     check 
 

 /* find HEX value*/
 
hexdisplay:
 cmpeqi  r13, r12,0x0         		/*check for HEX '0'*/
 bne     r0,  r13,zero
 cmpeqi  r13, r12,0x1         		/*check for HEX '1'*/
 bne     r0,  r13,one
 cmpeqi  r13, r12,0x2       		/*check for HEX '2'*/
 bne     r0,  r13,two
 cmpeqi  r13, r12,0x3         		/*check for HEX '3'*/
 bne     r0,  r13,three
 cmpeqi  r13, r12,0x4         		/*check for HEX '4'*/
 bne     r0,  r13,four
 cmpeqi  r13, r12,0x5        		/*check for HEX '5'*/
 bne     r0,  r13,five
 cmpeqi  r13, r12,0x6         		/*check for HEX '7'*/
 bne     r0,  r13,six
 cmpeqi  r13, r12,0x7         		/*check for HEX '7'*/
 bne     r0,  r13,seven
 cmpeqi  r13, r12,0x8        		/*check for HEX '8'*/
 bne     r0,  r13,eight
 cmpeqi  r13, r12,0x9        		/*check for HEX '9'*/
 bne     r0,  r13,nine
 cmpeqi  r13, r12,0xa         		/*check for HEX 'a'*/
 bne     r0,  r13,ten
 cmpeqi  r13, r12,0xb         		/*check for HEX 'b'*/
 bne     r0,  r13,eleven
 cmpeqi  r13, r12,0xc         		/*check for HEX 'c'*/
 bne     r0,  r13,twelve
 cmpeqi  r13, r12,0xd         		/*check for HEX 'd'*/
 bne     r0,  r13,thirteen
 cmpeqi  r13, r12,0xe         		/*check for HEX 'e'*/
 bne     r0,  r13,fourteen
 cmpeqi  r13, r12,0xf         		/*check for HEX 'f'*/
 bne     r0,  r13,fifteen
 ret
 
zero:
 movi r12, 0x3f
 ret
 
one:
 movi r12, 0x06
 ret

two:
 movi r12, 0x56
 ret
 
three:
 movi r12, 0x4f
 ret
     
four:
 movi r12, 0x66
 ret
 
five:
 movi r12, 0x6d
 ret

six:
 movi r12, 0x7d
 ret
 
seven:
 movi r12, 0x07
 ret
 
eight:
 movi r12, 0x7f
 ret
 
nine:
 movi r12, 0x67
 ret

ten:
 movi r12, 0x77
 ret
 
eleven:
 movi r12, 0x7c
 ret
     
twelve:
 movi r12, 0x39
 ret
 
thirteen:
 movi r12, 0x5e
 ret

fourteen:
 movi r12, 0x79
 ret
 
fifteen:
 movi r12, 0x71
 ret
 
 
 
 
  delay: # takes duration of timer in r4
   movia r3, 0xFF202000                   # r7 contains the base address for the timer 
   stwio r4, 8(r3)                          # Set the period to be 1000 clock cycles 
   movia r13, 5
   stwio r13, 4(r3)
   pollloop:
   	ldwio r4, 0(r3)
    andi r4, r4, 1
   	beq r4, r0, pollloop
  
  stwio r0, 0(r3)
  
   ret
    
