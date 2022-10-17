.global	printn
printn:
	# will make calls so push ra
	subi sp, sp, 4
    stw ra, 0(sp)
    # uses a number of callee-stored registers; r23-r17 = 6X
	
	# r21 is ptr to args
	mov r21, sp;
	addi r21, r21, 4;

	subi sp, sp, 24
	stw r23, 0(sp);
	stw r21, 4(sp);
	stw r20, 8(sp);
	stw r19, 12(sp);
	stw r18, 16 (sp);
	stw r17, 20 (sp);
	

    # load ptr to string
    # put this in a callee-saved (unclobbered) register
    mov r22, r4; # first argument is the string addr
    movi r23, 0; # loop counter
	
    
	# first time don't need to worry about clobbering
	# add r19, r5, r0
	add r17, r6, r0
	add r18, r7, r0


    startloop:
	    addi r23, r23, 1; # increment loop
        ldb r20, 1(r22); # lookahead 1 to check for termination
        beq r20, r0, printn_epilogue
		ldb r20, 0(r22); # r20 stores current char
        

        # pass arguments
        # first time in r5
        addi r19, r0, 1 
		beq r23, r19, loop1
        addi r19, r0, 2 
        beq r23, r19, loop2
        addi r19, r0, 3
        beq r23, r19, loop3
        

        
        
        # for following calls, grab value from stack
        ldw r4, 0(r21)
        addi r21, r21, 4
        br callstart


        loop1:
            add r4, r0, r5
            br callstart
        loop2:
            add r4, r0, r17
            br callstart
        loop3:
            add r4, r0, r18
            br callstart


    callstart:

    movi r8, 79; # O
    beq r20, r8, call_printOct
    movi r8, 72; # H
    beq r20, r8, call_printHex
    movi r8, 68; # D
    beq r20, r8, call_printDec

    call_printOct:
        call printOct
        br loopepilogue
    call_printHex:
        call printHex
        br loopepilogue
    call_printDec:
        call printDec
        br loopepilogue

    loopepilogue:
        addi r22, r22, 1; # move along the string
        br startloop

    printn_epilogue:
	
	# restore calee saved registers
	ldw r23, 0(sp);
	ldw r21, 4(sp);
	ldw r20, 8(sp);
	ldw r19, 12(sp);
	ldw r18, 16(sp);
	ldw r17, 20(sp);
	addi sp, sp, 24
	
	
	# pop return addr from stack, restore stack, return
    ldw ra, 0(sp)
	addi sp, sp, 4
	ret

