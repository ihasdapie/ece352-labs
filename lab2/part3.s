.equ RED_LEDS, 0xFF200000 	   # (From DESL website > NIOS II > devices)


.equ IN_LIST_SIZE, 9
.data                              # "data" section for input and output lists

IN_LIST:                  	   # List of 10 signed halfwords starting at address IN_LIST
    .hword 1
    .hword -1
    .hword -2
    .hword 2
    .hword 0
    .hword -3
    .hword 100
    .hword 0xff9c
    .hword 0b1111
LAST:			 	    # These 2 bytes are the last halfword in IN_LIST
    .byte  0x01		  	    # address LAST
    .byte  0x02		  	    # address LAST+1
    
IN_LINKED_LIST:                     # Used only in Part 3
    A: .word 1
       .word B
    B: .word -1
       .word C
    C: .word -2
       .word E + 8
    D: .word 2
       .word C
    E: .word 0
       .word K
    F: .word -3
       .word G
    G: .word 100
       .word J
    H: .word 0xffffff9c
       .word E
    I: .word 0xff9c
       .word H
    J: .word 0b1111
       .word IN_LINKED_LIST + 0x40
    K: .byte 0x01		    # address K
       .byte 0x02		    # address K+1
       .byte 0x03		    # address K+2
       .byte 0x04		    # address K+3
       .word 0
    
OUT_NEGATIVE:
    .skip 40                         # Reserve space for 10 output words
    
OUT_POSITIVE:
    .skip 40                         # Reserve space for 10 output words

#-----------------------------------------

.text                  # "text" section for code

    # Register allocation:
    #   r0 is zero, and r1 is "assembler temporary". Not used here.
    #   r2  Holds the number of negative numbers in the list
    #   r3  Holds the number of positive numbers in the list
    #   r4  A pointer to INLOOP
    #   r5  loop counter for PNLOOP
	#	r7	temporary pointer to pos/neg loops
	#	r9	value at pointer location in list
    #   r16, r17 Short-lived temporary values.
    #   etc...

.global _start
_start:
    
    # Your program here. Pseudocode and some code done for you:

	mov r2, r0; # negnum
	mov r3, r0; # posnum
	
	# r4 is curr node addr
	movia r4, IN_LINKED_LIST;
	
	
	# r9 is curr node value
	
	
	PNLOOP:
		beq r4, r0, PNLOOP_END;
		
		# load number from memory
		ldw r9, 0(r4);
		
		
		# grab next addrs
		addi r5, r4, 4;
		ldw r4, 0(r5);
		
		
		
		# perform pos, neg check
		bge r9, r0, pos
		
		
		
		
		# negative stuff here
		neg:
			movia r7, OUT_NEGATIVE;	#r7 temp address of where new word will be added to out neg
			add r7, r7, r2;	
			add r7, r7, r2;
			add r7, r7, r2;
			add r7, r7, r2;			# incr 4 times bc word = 4 bytes
			
			stw r9, 0(r7);			# store word
			addi r2, r2, 1;			# incr counter for neg words
			br loop_end:
		
		pos:
			movia r7, OUT_POSITIVE;	#r7 temp address of where new word will be added to out pos
			add r7, r7, r3;
			add r7, r7, r3;
			add r7, r7, r3;
			add r7, r7, r3;			# incr 4 times bc word = 4 bytes
			
			stw r9, 0(r7);			# store word
			addi r3, r3, 1;			# incr counter for pos words
			br loop_end:
		
		loop_end:
			
			
			movia  r16, RED_LEDS          # r16 and r17 are temporary values
        	stwio r2, 0(r16);
			stwio r3, 4(r16)
		
		  #movia r15,4000000 /* set starting point for delay counter */

		  #DELAY:
			#subi r15,r15,1       # subtract 1 from delay
		  	#bne r15,r0, DELAY
			#addi r5, r5, 1;			# incr counter for which word we're on in the list
			br PNLOOP;				
	
		
    PNLOOP_END:

        # (You'll learn more about I/O in Lab 4.)
		
		
		

		
    # End loop


LOOP_FOREVER:
    br LOOP_FOREVER                   # Loop forever.
