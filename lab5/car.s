/* Prelab:
 * 1) I read the docs
 * 2.1) Sensor reading of 0x0: off road
 * 2.2) 0x05, 0x9C meaning: changing steering, 0x9c = 100 to left
 * 2.3) To apply max. acceleration: 0x04, 0x7f
 * 3) See below
*/

/*

DR 15 is data valid
Byte is at bites [7:0]; remove from queu
CR [31:16] is the number of free bytes in the write FIFO

0x02: Request sensor and speed
  Response: 3 bytes. 
  1st byte is 0x00
  2nd byte is [][][][outer right][inner right][center][inner left][outer left]
      each of which denotes on(1) or off(0) the track
      speed is 0-255 unsigned number

0x03: Request position data
  Response: 4 bytes
    1st is 0x01
    2nd is x
    3rd is y
    4th is x
0x04, acceleration as 8 bit signed: Change acceleration via seq of 2 bytes. no response
0x05, angle as 9 bit signed; -127 = hard left, +127 hard right. no response

*/

.equ JTAG_UART_BASE, 0x10001020
.equ CLOCK_BASE, 0xFF202000

.data

.text
.global main
.global _start

_start:


main:
  movia sp, 0x02000000                   /* initialize the stack to top of NIOS memory*/
  subi sp, sp, 4
  stw ra, 0(sp)
  call drain_buffers
  
 loop:
  
  call read_sensors
  /*
  
  straight -> angle = 0
  0001 1111 = 0x1F 
  
  127//5 = 0x19
  
  so if it's right, multiply 0x19 by no. of 1s replaced by 0s
  
  and if it's left, i.e 0001 1100
  multiply -0x19 by no. of 1s replaced by 0s
  */
  
  /* need some logic to get back on the road if we're totally off the road*/
  
  movi r3, 0x1F
  beq r2, r3, straight
  
  movi r3, 0x0F
  beq r2, r3, right1
  movi r3, 0x07
  beq r2, r3, right2
  movi r3, 0x03
  beq r2, r3, right3
  movi r3, 0x01
  beq r2, r3, right4
  
  movi r3, 0x1E
  beq r2, r3, left1
  movi r3, 0x1C
  beq r2, r3, left2
  movi r3, 0x18
  beq r2, r3, left3
  movi r3, 0x10
  beq r2, r3, left4
  
  /* hope that all the sensors never go off for now */
  
  straight:
  	movi r4, 0x00
	call set_steering
	br post_steer
	
  right1:
  	movi r4, 0x20
	call set_steering
	br post_steer
  right2:
  	movi r4, 0x40
	call set_steering
	br post_steer
  right3:
  	movi r4, 0x60
	call set_steering
	br post_steer
  right4:
  	movi r4, 0x7f
	call set_steering
	br post_steer

  left1:
  	movi r4, -0x20
	call set_steering
	br post_steer
  left2:
  	movi r4, -0x40
	call set_steering
	br post_steer
  left3:
  	movi r4, -0x60
	call set_steering
	br post_steer
  left4:
  	movi r4, -0x7f
	call set_steering
	br post_steer
  
  
post_steer:
  /* set acceleration to something big */
  movi r4, 0x7F
  call set_accel
  
  
 
  /* do a dumb delay */
  movia r4, 0xf; 
  call delay
  
  /* loop forever */
  br loop
  ret

delay: 
  movia r3, CLOCK_BASE
  stwio r4, 8(r3)
  movia r13, 5
  stwio r13, 4(r3)
  pollloop:
    ldwio r4, 0(r3)
    andi r4, r4, 1
    beq r4, r0, pollloop
  stwio r0, 0(r3)


uart_write: /* writes arg in r4 to JTAG */
  movia r7, JTAG_UART_BASE
  ldwio r3, 4(r7) /* read from the JTAG */
  srli r3, r3, 16 /* check write-avaliable bits */
  beq r3, r0, uart_write /* poll since cannot write if 0 (no spaces ava. for writing) */
  stwio r4, 0(r7) /* write value */
  ret

uart_read: /* reads one byte from uart to r2 */
  movia r7, JTAG_UART_BASE
  ldwio r2, 0(r7) /* read from the JTAG */
  andi r3, r2, 0x8000 /* check if read valid */
  beq r3, r0, uart_read
  andi r2, r2, 0x00FF /* AND data into r2 */
  ret

read_sensors:
  subi sp, sp, 8
  stw ra, 0(sp)
  movi r4, 0x02
  call uart_write
  call uart_read
  beq r2, r0, read_sensors_fail
  call uart_read
  br read_sensors_success
  
  read_sensors_fail:
	and r2, r2, r0
  read_sensors_success:
  	ldw ra, 0(sp)
	addi sp, sp, 8
	ret

set_steering:
  subi sp, sp, 8
  stw ra, 0(sp)
  stw r4, 4(sp)

  movi r4, 0x05
  call uart_write
  ldw r4, 4(sp)
  call uart_write
  ldw ra, 0(sp)
  addi sp, sp, 8
  ret

set_accel:
  subi sp, sp, 8
  stw ra, 0(sp)
  stw r4, 4(sp)

  movi r4, 0x04
  call uart_write
  ldw r4, 4(sp)
  call uart_write
  ldw ra, 0(sp)
  addi sp, sp, 8
  ret
  
drain_buffers:
  subi sp, sp, 4
  stw ra, 0(sp)
  movi r4, 0x00
  call uart_write
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret
  
  
  

