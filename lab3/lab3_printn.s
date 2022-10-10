/*********
 * 
 * Write the assembly function:
 *     printn ( char * , ... ) ;
 * Use the following C functions:
 *     printHex ( int ) ;
 *     printOct ( int ) ;
 *     printDec ( int ) ;
 * 
 * Note that 'a' is a valid integer, so movi r2, 'a' is valid, and you don't need to look up ASCII values.
 *********/

.global	printn
printn:
// will make calls so push ra
subi sp, sp, 4;
stw ra, 0(sp);

// load ptr to string
// put this in a callee-saved (unclobbered) register
mov r16, r4; // first argument is the string addr
movi r17, 0; // loop counter
mov r9, sp; // ptr to values


startloop:
addi r17, r17, 1; // increment loop
ldb r18, 0(r16); // r18 stores current char
beq r18, r0, endloop;


// pass arguments
// first time in r5
beq r17, 0, 1loop
beq r17, 1, 2loop
beq r17, 2, 3loop

// for following calls, grab value from stack
addi r9, r9, 4;
ldw r4, r9;
br callstart


1loop:
    add r4, r0, r5;
    br callstart;
2loop:
    add r4, r0, r6;
    br callstart;
3loop:
    add r4, r0, r7;
    br callstart;


callstart:

movi r8, 79; // O
beq r18, call_printOct
movi r8, 72; // H
beq r18, call_printHex
movi r8, 68; // D
beq r18, call_printDec

call_printOct:
    call printOct;
    br loopepilogue;
call_printHex:
    call printHex;
    br loopepilogue;
call_printDec:
    call printDec:
    br loopepilogue;

loopepilogue:
    addi r16, r16, 1; // move along the string
    br printn;

endloop:



printn_epilogue:
// pop return addr from stack, restore stack, return
ldw ra, 0(sp)
    addi sp, sp, 4
    ret















