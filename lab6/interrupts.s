/* Pre-lab
How do you tell the JTAG UART to send read interrupts?
  - Set the ERI bit in the JTAG UART Control Register (bit 0)
How do you tell the timer to send timeout interrupts?
  - Set timmeout interrupt enable bit (bit 0 @ (base+4)) 
How do you tell the processor to accept interrupts from both Timer1 and the terminal JTAG UART?
  - set ctl0's bit 0 to 1 to enable interrupts
  - set bit 8 of ctl3 to 1 for irq8
  - Timer1: IRQ Line 0: (bit 0 of ctl3 register)
Write a line of code to adjust ea before returning from the interrupt handler so that the aborted instruction will be re-executed.
  - TODO
Which registers must you backup before overwriting inside an interrupt handler?
  - everything except for ea
If you want to call a function implemented in C from inside your interrupt handler, which registers must you back up?
  - all caller-saved registers


Write a simple test program to blink an LED with a period of 1 second using timer interrupts.
  - see below

Write a simple test program to echo characters on the terminal JTAG UART using read interrupts.


Enhance your solution to Lab 5 to display speed and sensor state over the JTAG UART, as described above. Use interrupts both to read from the terminal JTAG UART and to check the Timer for a timeout.

display speed and sensor state
interrupt on timer to display


*/

.equ JTAG_UART_BASE, 0x10001020
.equ JTAG_UART_BASE2, 0xff201000
.equ CLOCK_BASE, 0xFF202000

.data
speed: .byte '0'
sensor1: .byte '0'
sensor2: .byte '0'
sensor3: .byte '0'
sensor4: .byte '0'
sensor5: .byte '0'

.text
.align 2

.global _start
_start:

/* ea stores PC of instruction following one that was interrupted*/
main:
  setup:
    /* enable cpu interrupts */
    movia r5, JTAG_UART_BASE

    movi r4, 0b1
    wrctl ctl0, r14
    /* bit 8, bit 0 for timer & uart */
    movi r4, 0x101 /* 0b1 0000 0001 */
    wrctl ctl3, r4

    /* enable receive interrupts on uart */
    addi r9, r0, 0x1
    stwio r9, 4(r5)

    /* configure timer  */
    movia r5, CLOCK_BASE
    /* stop timer, just in case  */

    movi r6, 0b1000
    stwio r6, 4(r5)

    /* clear timeout */
    stwio r0, 0(r5)

    /* store period (1/2 s)*/
    andi r6, r4, 0xFFFF
    stwio r6, 8(r5)
    srli r6, r4, 16
    stwio r6, 12(r5)

    /* start & enable interrupt & cont */ 
    movi r6, 0b0111
    stwio r6, 4(r5)


  car_loop: 

  /* code from previous lab goes here ... */




  br car_loop







// Make sure to have this live in memory addr 0x00000020
.section .exceptions, "ax"
.align 2

myISR:
  /* we can probably do less than this if we don't use any other registers...*/
myISR_prolog:
  subi sp, sp, 100
  stw ea 0(sp)

  rdctl et, ctl1
  stw et, 4(s0)

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
  */

  /* bit 8: uart */
  rdctl r5, ctl4
  andi r5, 0x100 
  bne r6, r0, myISR_uart_handler

  /* bit 0: timer */
  rdctl r5, ctl4
  andi r5, 0b1
  bne r6, r0, myISR_timer_handler

  br myISR_epilog

myISR_uart_handler:
  movia r4, JTAG_UART_BASE

  /* read status register to clear interrupt */
  ldwio r2, 4(r4)
  addi et, et, 0x1  /* enable interrupts */
  wrctl crl0, et


  /* Read in data and then write to appropriate data 

  Response: 3 bytes. 
  1st byte is 0x00
  2nd byte is [][][][outer right][inner right][center][inner left][outer left]
      each of which denotes on(1) or off(0) the track
  3rd byte is speed, which is an unsigned byte (0-255)
  */

  movia r4, JTAG_UART_BASE
  call uart_read
  movia r8, sensor1
  andi r5, r2, 0b00000001
  stbio r5, 0(r8)
  movia r8, sensor2
  andi r5, r2, 0b00000010
  stbio r5, 0(r8)
  movia r8, sensor3
  andi r5, r2, 0b00000100
  stbio r5, 0(r8)
  movia r8, sensor4
  andi r5, r2, 0b00001000
  stbio r5, 0(r8)
  movia r8, sensor5
  andi r5, r2, 0b00010000
  stbio r5, 0(r8)

  movia r4, JTAG_UART_BASE
  call uart_read
  movia r8, speed
  stbio r2, 0(r8)
  
  /* display our results */

  /*    clear terminal screen */
  /* could also remove all the movi r5 jtag uart bases since uart_write
  doesn't mutate r5 */
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

  /*    write current values to screen */
  /* On second thought we didn't need the memory
    I originally thought that we would want to to the display
    update on the timer interrupt which would make using memory make sense
  */
  /* movia r5, JTAG_UART_BASE2 */
  movia r6, speed
  ldbuio r4, 0(r6)
  call uart_write

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

  br myISR_epilog



myISR_timer_handler:
  /* make requests for sensor data */
  movi r4, 0x02
  movi r5, JTAG_UART_BASE
  call uart_write

  br myISR_epilog


myISR_epilog:
/* should be in reverse order... */
  ldw ea 0(sp)

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







uart_write: /* writes arg in r4 to uart in r5 */
  ldwio r3, 4(r5) /* read from the JTAG */
  srli r3, r3, 16 /* check write-avaliable bits */
  beq r3, r0, uart_write /* poll since cannot write if 0 (no spaces ava. for writing) */
  stwio r4, 0(r5) /* write value */
  ret

uart_read: /* reads one byte from uart @ r4 to r2 */
  movia r7, 4(r4)
  ldwio r2, 0(r7) /* read from the JTAG */
  andi r3, r2, 0x8000 /* check if read valid */
  beq r3, r0, uart_read
  andi r2, r2, 0x00FF /* AND data into r2 */
  ret



