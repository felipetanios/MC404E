.globl _start

.data

input_buffer:   .skip 32
output_buffer:  .skip 32
    
.text
.align 4

@ Funcao inicial
_start:
    @ Chama a funcao "read" para ler 4 caracteres da entrada padrao
    ldr r0, =input_buffer
    mov r1, #5             @ 4 caracteres + '\n'
    bl  read
    mov r4, r0             @ copia o retorno para r4.

    @ Chama a funcao "atoi" para converter a string para um numero
    ldr r0, =input_buffer
    mov r1, r4
    bl  atoi

    @ Chama a funcao "encode" para codificar o valor de r0 usando
    @ o codigo de hamming.
    bl  encode
    mov r4, r0             @ copia o retorno para r4.
	
    @ Chama a funcao "itoa" para converter o valor codificado
    @ para uma sequencia de caracteres '0's e '1's
    ldr r0, =output_buffer
    mov r1, #7
    mov r2, r4
    bl  itoa

    @ Adiciona o caractere '\n' ao final da sequencia (byte 7)
    ldr r0, =output_buffer
    mov r1, #'\n'
    strb r1, [r0, #7]

    @ Chama a funcao write para escrever os 7 caracteres e
    @ o '\n' na saida padrao.
    ldr r0, =output_buffer
    mov r1, #8         @ 7 caracteres + '\n'
    bl  write
    
    @ Chama a funcao "read" para ler 7 caracteres da entrada padrao
    ldr r0, =input_buffer
    mov r1, #8             @ 7 caracteres + '\n'
    bl  read
    mov r4, r0             @ copia o retorno para r4.

    @ Chama a funcao "atoi" para converter a string para um numero
    ldr r0, =input_buffer
    mov r1, r4
    bl  atoi
    
    @ Chama a funcao "decode" para decodificar o valor de r0 usando
    @ o codigo de hamming.
    bl  decode
    mov r4, r0             @ copia o retorno para r4.
    mov r5, r1             @ copia o outro retorno para r5.
	
    @ Chama a funcao "itoa" para converter o valor codificado
    @ para uma sequencia de caracteres '0's e '1's
    ldr r0, =output_buffer
    mov r1, #4
    mov r2, r4
    bl  itoa

    @ Adiciona o caractere '\n' ao final da sequencia (byte 5)
    ldr r0, =output_buffer
    mov r1, #'\n'
    strb r1, [r0, #4]

    @ Chama a funcao write para escrever os 7 caracteres e
    @ o '\n' na saida padrao.
    ldr r0, =output_buffer
    mov r1, #5         @ 4 caracteres + '\n'
    bl  write
    
    @ Chama a funcao "itoa" para converter o valor codificado na saida r1 de 
    @ decode para uma sequencia de caracteres '0's e '1's
    
    ldr r0, =output_buffer
    mov r1, #1
    mov r2, r5
    bl  itoa

    @ Adiciona o caractere '\n' ao final da sequencia (byte 7)
    ldr r0, =output_buffer
    mov r1, #'\n'
    strb r1, [r0, #1]

    @ Chama a funcao write para escrever os 7 caracteres e
    @ o '\n' na saida padrao.
    ldr r0, =output_buffer
    mov r1, #2         @ 7 caracteres + '\n'
    bl  write
    
    
    @ Chama a funcao exit para finalizar processo.
    mov r0, #0
    bl  exit

@ Codifica o valor de entrada usando o codigo de hamming.
@ parametros:
@  r0: valor de entrada (4 bits menos significativos)
@ retorno:
@  r0: valor codificado (7 bits como especificado no enunciado).
encode:

       @ <<<<<< ADICIONE SEU CODIGO AQUI >>>>>>    
       push {r4-r11, lr}
       mov r4, r0
       and r5, r4, #1 @r5 recebe o primeiro bit de r4 (d4)
       and r6, r4, #2
       mov r6, r6, lsr #1 @r6 recebe o segundo bit de r4 (d3)
       and r7, r4, #4 
       mov r7, r7, lsr #2 @r7 recebe o terceiro bit de r4 (d2)
       and r8, r4, #8 
       mov r8, r8, lsr #3 @r8 recebe o quarto bit de r4 (d1)
       @para calcular os valores de p1, p2, p3 farei um XOR entre
       @os bits que eles testam. Se o resultado desse XOR for 1
       @o bit de paridade vale 1, senao ele vale 0
       eor r9, r8, r7 @ r9 recebe p1
       eor r9, r9, r5
       eor r10, r8, r6 @ r10 recebe p2
       eor r10, r10, r5 
       eor r11, r7, r6 @r11 recebe p3
       eor r11, r11, r5
       and r4, r4, #0 @zera o registrador 4 para ele guardar o resultado
       add r4, r4, r9, lsl #6 @coloca p1 no 7o bit
       add r4, r4, r10, lsl #5 @coloca p2 no 6o bit
       add r4, r4, r8, lsl #4 @coloca d1 no 5o bit
       add r4, r4, r11, lsl #3 @coloca p3 no 4o bit
       add r4, r4, r7, lsl #2 @coloca d2 no 3o bit
       add r4, r4, r6, lsl #1 @coloca d3 no 2o bit
       add r4, r4, r5 @coloca d4 no 1o bit
       mov r0, r4
       
    
       pop  {r4-r11, lr}
       mov  pc, lr

@ Decodifica o valor de entrada usando o codigo de hamming.
@ parametros:
@  r0: valor de entrada (7 bits menos significativos)
@ retorno:
@  r0: valor decodificado (4 bits como especificado no enunciado).
@  r1: 1 se houve erro e 0 se nao houve.
decode:    
       push {r4-r11, lr}
       @ <<<<<< ADICIONE SEU CODIGO AQUI >>>>>>
       mov r4, r0
       and r5, r4, #1 @r1 recebe d4
       and r6, r4, #2
       mov r6, r6, lsr #1 @r6 recebe d3
       and r7, r4, #4 
       mov r7, r7, lsr #2 @r7 recebe d2
       and r8, r4, #16 
       mov r8, r8, lsr #4 @r8 recebe d1
       and r4, r4, #0 @zera o registrador 4 para ele guardar o resultado
       add r4, r4, r8,  lsl #3 @coloca d1 em sua posicao final
       add r4, r4, r7, lsl #2 @coloca d2 em sua posicao final
       add r4, r4, r6, lsl #1 @coloca d3 em sua posicao final
       add r4, r4, r5 @coloca d4 em sua posicao final 
       mov r0, r4 @coloca o resultado em r0
       @verificacao de paridades, o registrador r9 vai ser onde vai ser 
       @armazenado o bit de paridade e o resultado do teste desse bit
       and r1, r1, #0 @zera r1, onde no final tera o resultado do erro
       @teste de p1
       mov r9, r4, lsr #6
       and r9, r9, #1 @r9 recebe p1
       eor r9, r9, r8
       eor r9, r9, r7
       eor r9, r9, r5 @se r9 for 1 teve um erro na paridade
       orr r1, r1, r9 @se teve erro r1 = 1, senao r1 = 0
       @teste de p2
       mov r9, r4, lsr #5
       and r9, r9, #1 @r9 recebe p2
       eor r9, r9, r8
       eor r9, r9, r6
       eor r9, r9, r5 @se r9 for 1 teve um erro na paridade
       orr r1, r1, r9 @se teve erro r1 = 1, senao r1 = 0
       @teste de p3
       mov r9, r4, lsr #3
       and r9, r9, #1 @r9 recebe p3
       eor r9, r9, r7
       eor r9, r9, r6
       eor r9, r9, r5 @se r9 for 1 teve um erro na paridade
       orr r1, r1, r9 @se teve erro r1 = 1, senao r1 = 0
       
       

       pop  {r4-r11, lr}
       mov  pc, lr

@ Le uma sequencia de bytes da entrada padrao.
@ parametros:
@  r0: endereco do buffer de memoria que recebera a sequencia de bytes.
@  r1: numero maximo de bytes que pode ser lido (tamanho do buffer).
@ retorno:
@  r0: numero de bytes lidos.
read:
    push {r4,r5, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #0         @ stdin file descriptor = 0
    mov r1, r4         @ endereco do buffer
    mov r2, r5         @ tamanho maximo.
    mov r7, #3         @ read
    svc 0x0
    pop {r4, r5, lr}
    mov pc, lr

@ Escreve uma sequencia de bytes na saida padrao.
@ parametros:
@  r0: endereco do buffer de memoria que contem a sequencia de bytes.
@  r1: numero de bytes a serem escritos
write:
    push {r4,r5, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #1         @ stdout file descriptor = 1
    mov r1, r4         @ endereco do buffer
    mov r2, r5         @ tamanho do buffer.
    mov r7, #4         @ write
    svc 0x0
    pop {r4, r5, lr}
    mov pc, lr

@ Finaliza a execucao de um processo.
@  r0: codigo de finalizacao (Zero para finalizacao correta)
exit:    
    mov r7, #1         @ syscall number for exit
    svc 0x0

@ Converte uma sequencia de caracteres '0' e '1' em um numero binario
@ parametros:
@  r0: endereco do buffer de memoria que armazena a sequencia de caracteres.
@  r1: numero de caracteres a ser considerado na conversao
@ retorno:
@  r0: numero binario
atoi:
    push {r4, r5, lr}
    mov r4, r0         @ r4 == endereco do buffer de caracteres
    mov r5, r1         @ r5 == numero de caracteres a ser considerado 
    mov r0, #0         @ number = 0
    mov r1, #0         @ loop indice
atoi_loop:
    cmp r1, r5         @ se indice == tamanho maximo
    beq atoi_end       @ finaliza conversao
    mov r0, r0, lsl #1 
    ldrb r2, [r4, r1]  
    cmp r2, #'0'       @ identifica bit
    orrne r0, r0, #1   
    add r1, r1, #1     @ indice++
    b atoi_loop
atoi_end:
    pop {r4, r5, lr}
    mov pc, lr

@ Converte um numero binario em uma sequencia de caracteres '0' e '1'
@ parametros:
@  r0: endereco do buffer de memoria que recebera a sequencia de caracteres.
@  r1: numero de caracteres a ser considerado na conversao
@  r2: numero binario
itoa:
    push {r4, r5, lr}
    mov r4, r0
itoa_loop:
    sub r1, r1, #1         @ decremento do indice
    cmp r1, #0          @ verifica se ainda ha bits a serem lidos
    blt itoa_end
    and r3, r2, #1
    cmp r3, #0
    moveq r3, #'0'      @ identifica o bit
    movne r3, #'1'
    mov r2, r2, lsr #1  @ prepara o proximo bit
    strb r3, [r4, r1]   @ escreve caractere na memoria
    b itoa_loop
itoa_end:
    pop {r4, r5, lr}
    mov pc, lr    
