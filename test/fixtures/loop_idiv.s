.text
loop:
  idivq %rcx
  addq $1, %rsi
  jne loop
