# Print ten in octal, hexadecimal, and decimal
# Use the following C functions:
#     printHex ( int ) ;
#     printOct ( int ) ;
#     printDec ( int ) ;

.global main

.text
main:
  addi sp, sp, -4
  stw ra, 0(sp);
  movi r4, 10
  call printOct

  addi sp, sp, -4
  stw ra, 0(sp);
  movi r4, 10
  call printHex

  addi sp, sp, -4
  stw ra, 0(sp);
  movi r4, 10
  call printDec

  ret
