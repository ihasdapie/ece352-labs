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





.equ SPEED_LIM, 40
.equ JTAG_UART_BASE, 0x10001020
.equ JTAG_UART_BASE2, 0xff201000
.equ CLOCK_BASE, 0xFF202000

.data
speed: .byte 's'
sensor1: .byte 'a'
sensor2: .byte 'b'
sensor3: .byte 'c'
sensor4: .byte 'd'
sensor5: .byte 'e'
display_mode: .byte 'r' /* 'r' for sensor, 's' for speed */

.text
.align 2

.global _start
_start:

/* ea stores PC of instruction following one that was interrupted*/
main:
  setup:
	movia sp, 0x02000000                   /* initialize the stack to top of NIOS memory*/
	subi sp, sp, 4
	stw ra, 0(sp)
	call drain_buffers
    /* enable cpu interrupts */
    movi r4, 0b1
    wrctl ctl0, r4

	
    /* enable receive interrupts on uart */
    movia r5, JTAG_UART_BASE2
	addi r9, r0, 0x1
    stwio r9, 4(r5)
	
   


    /* bit 8, bit 0 for timer & uart (term) */
    movi r4, 0x101 /* 0b1 0000 0001 */
    wrctl ctl3, r4



    /* configure timer  */
    movia r5, CLOCK_BASE
    /* stop timer, just in case  */

    movi r6, 0b1000
    stwio r6, 4(r5)

    /* clear timeout */
    stwio r0, 0(r5)

    /* store period (0.01 s) 300 000*/
    movi r6, 0x0000
    stwio r6, 8(r5)
    movi r6, 0x10
    stwio r6, 12(r5)

    /* start & enable interrupt & cont */ 
    movi r6, 0b0111
    stwio r6, 4(r5)


  loop:
    br loop
  
   
  
  call read_speed
  movi r4, SPEED_LIM
  bgt r2, r4, decel  
  
  accel:
  	movi r4, 0x7f
    call set_accel
    br turns
  decel:
  	movi r4, -0x7f
    call set_accel

    
turns:   
  call read_sensors      
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
	
  left1:
  	movi r4, 0x30
	call set_steering
	br post_steer
  left2:
  	movi r4, 0x7f
	call set_steering
	br post_steer
  left3:
  	movi r4, 0x7f
	call set_steering
	br post_steer
  left4:
  	movi r4, 0x7f
	call set_steering
	br post_steer

  right1:
  	movi r4, -0x30
	call set_steering
	br post_steer
  right2:
  	movi r4, -0x7f
	call set_steering
	br post_steer
  right3:
  	movi r4, -0x7f
	call set_steering
	br post_steer
  right4:
  	movi r4, -0x7f
	call set_steering
	br post_steer

post_steer:  

  br loop



uart_write: /* writes arg in r4 to uart in r5 */
  ldwio r3, 4(r5) /* read from the JTAG */
  srli r3, r3, 16 /* check write-avaliable bits */
  beq r3, r0, uart_write /* poll since cannot write if 0 (no spaces ava. for writing) */
  stwio r4, 0(r5) /* write value */
  ret

uart_read: /* reads one byte from uart @ r4 to r2 */
  ldwio r2, 0(r4) /* read from the JTAG */
  andi r3, r2, 0x8000 /* check if read valid */
  beq r3, r0, uart_read
  andi r2, r2, 0x00FF /* AND data into r2 */
  ret

read_sensors:
  subi sp, sp, 8
  stw ra, 0(sp)
  movi r4, 0x02
  movia r5, JTAG_UART_BASE
  call uart_write
  # read until we get a nonzero value
  read_sensors_loop:
	movia r4, JTAG_UART_BASE
  	call uart_read
    beq r2, r0, read_sensors_loop
  mov r13, r2
  
	movia r4, JTAG_UART_BASE
  call uart_read
  mov r2, r13
  ldw ra, 0(sp)
  addi sp, sp, 8
  ret
  
read_speed:
  subi sp, sp, 8
  stw ra, 0(sp)
  movi r4, 0x02
  movia r5, JTAG_UART_BASE
  call uart_write
  # read until we get a nonzero value
  read_speed_loop:
  
	movia r4, JTAG_UART_BASE
  	call uart_read
    beq r2, r0, read_speed_loop
	
	movia r4, JTAG_UART_BASE
  call uart_read
  ldw ra, 0(sp)
  addi sp, sp, 8
  ret

set_steering:
  subi sp, sp, 8
  stw ra, 0(sp)
  stw r4, 4(sp)

  movi r4, 0x05
  movia r5, JTAG_UART_BASE
  call uart_write
  ldw r4, 4(sp)
  movia r5, JTAG_UART_BASE
  call uart_write
  ldw ra, 0(sp)
  addi sp, sp, 8
  ret

set_accel:
  subi sp, sp, 8
  stw ra, 0(sp)
  stw r4, 4(sp)

  movi r4, 0x04
  movia r5, JTAG_UART_BASE
  call uart_write
  ldw r4, 4(sp)
  movia r5, JTAG_UART_BASE
  call uart_write
  ldw ra, 0(sp)
  addi sp, sp, 8
  ret
  
drain_buffers:
  subi sp, sp, 4
  stw ra, 0(sp)
  movi r4, 0x00
  movia r5, JTAG_UART_BASE
  call uart_write
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret
  

.section .exceptions, "ax"
.align 2

myISR:
  /* we can probably do less than this if we don't use any other registers...*/
myISR_prolog:
  subi sp, sp, 100
  stw ea, 0(sp)

  rdctl et, ctl1
  stw et, 4(sp)

  stw r2, 8(sp)
  stw r3, 12(sp)
  stw r4, 16(sp)
  stw r5, 20(sp)
  stw r6, 24(sp)
  stw r7, 28(sp)
  stw r8, 32(sp)
  stw r9, 36(sp)
  stw r10, 40(sp)
  stw r11, 44(sp)
  stw r12, 48(sp)
  stw r13, 52(sp)
  stw r14, 56(sp)
  stw r15, 60(sp)
  stw r16, 64(sp)
  stw r17, 68(sp)
  stw r18, 72(sp)
  stw r19, 76(sp)
  stw r20, 80(sp)
  stw r21, 84(sp)
  stw r22, 88(sp)
  stw r23, 92(sp)
  stw ra, 96(sp)

  /* Note: software-impl instructions wouuld live here and are identifiable
  via looking at the value of ea-4, i.e. the prior instruction
  */

  
  /* Instead of lookinag at the UART CSR we'll just assume that all UART
  interrupts are the read interrupts that we want.
  We've only enabled read interrupts on one uart so this is fine.
  * /
  
  

  /* bit 8: uart */
  rdctl r5, ctl4
  movi r6, 0x100
  and r7, r6, r5
  beq r7, r0, not_uart
  call myISR_uart_handler
  
  not_uart:
  
  /* bit 0: timer */
  rdctl r5, ctl4
  movi r6, 0b1
  and r7, r6, r5
  bne r7, r0, myISR_timer_handler


  br myISR_epilog

myISR_uart_handler:
	subi sp, sp,4
    stw ra, 0(sp)
  movia r4, JTAG_UART_BASE2

  /* read status register to clear interrupt */
  ldwio r2, 4(r4)
  addi et, et, 0x1  /* enable interrupts */
  wrctl ctl0, et
  
  call uart_read
  movia r6, display_mode
  stbio r2, 0(r6)
  ldw ra, 0(sp)
  addi sp, sp, 4
  ret



myISR_timer_handler:
  /* make requests for sensor data */
  
  /*    clear terminal screen */
  movia r5, JTAG_UART_BASE2 /* for terminal screen */
  movi r4, 0x1b
  call uart_write

  /* movia r5, JTAG_UART_BASE2 /* for terminal screen  */
  movi r4, '['
  call uart_write
  
  /* movia r5, JTAG_UART_BASE2 /* for terminal screen  */
  movi r4, '2'
  call uart_write

  /* movia r5, JTAG_UART_BASE2 /* for terminal screen  */
  movi r4, 'J'
  call uart_write
  
  movia r5, JTAG_UART_BASE2 /* for terminal screen */
  movi r4, 0x1b
  
  
  # print display mode
  
  movia r6, display_mode
  ldbio r4, 0(r6)

  movi r7, 0x73
  beq r4, r7, print_speed
  
  print_sensors:
  
  
  movia r6, sensor1
  ldbio r4, 0(r6)
  call uart_write
  movia r6, sensor2
  ldbio r4, 0(r6)
  call uart_write
  movia r6, sensor3
  ldbio r4, 0(r6)
  call uart_write
  movia r6, sensor4
  ldbio r4, 0(r6)
  call uart_write
  movia r6, sensor5
  ldbio r4, 0(r6)
  call uart_write 
  br print_end
  
  print_speed:
  movia r6, speed
  ldbio r4, 0(r6)
  call uart_write
  

  print_end:
	  /* configure timer  */
	movia r5, CLOCK_BASE
	/* stop timer, just in case  */

	movi r6, 0b1000
	stwio r6, 4(r5)

	/* clear timeout */
	stwio r0, 0(r5)

	/* store period (1/2 s) 300 000*/
	movi r6, 0x0000
	stwio r6, 8(r5)
	movi r6, 0x10
	stwio r6, 12(r5)

	/* start & enable interrupt & cont */ 
	movi r6, 0b0111
	stwio r6, 4(r5)
	  
  

  br myISR_epilog


myISR_epilog:
/* should be in reverse order... */
  ldw ea, 0(sp)

  ldw et, 4(sp)
  wrctl ctl1, et

  ldw r2, 12(sp)
  ldw r3, 16(sp)
  ldw r4, 20(sp)
  ldw r5, 24(sp)
  ldw r6, 28(sp)
  ldw r7, 32(sp)
  ldw r8, 36(sp)
  ldw r9, 40(sp)
  ldw r10, 44(sp)
  ldw r11, 48(sp)
  ldw r12, 52(sp)
  ldw r13, 56(sp)
  ldw r14, 60(sp)
  ldw r15, 64(sp)
  ldw r16, 68(sp)
  ldw r17, 72(sp)
  ldw r18, 76(sp)
  ldw r19, 80(sp)
  ldw r20, 84(sp)
  ldw r21, 88(sp)
  ldw r22, 92(sp)
  ldw r23, 96(sp)
  ldw ra, 100(sp)

  addi sp, sp, 100
  subi ea, ea, 4
  eret










  
