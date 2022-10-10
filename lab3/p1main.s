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
