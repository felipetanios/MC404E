
        
.text
.align 4
.globl _start

_start:                         @ main
        
        mov r0, #0              @ Carrega em r0 a velocidade do motor 0.
                                @ Lembre-se: apenas os 6 bits menos significativos
                                @ serao utilizados.
        mov r1, #0              @ Carrega em r1 a velocidade do motor 1.
        mov r7, #124            @ Identifica a syscall 124 (write_motors).
        svc 0x0                 @ Faz a chamada da syscall.

        ldr r6, =1300           @ r6 <- 1200 (Limiar para parar o robo)

loop:        
        
        @r5: resposta do sensor 3 (perto do motor 1)
        @r0: resposta do sensor 4 (perto do motor 0)
        mov r0, #3              @ Define em r0 o identificador do sonar a ser consultado.
        mov r7, #125            @ Identifica a syscall 125 (read_sonar).
        svc 0x0                 
        mov r5, r0              @ Armazena o retorno da syscall.

        mov r0, #4              @ Define em r0 o sonar.
        mov r7, #125
        svc 0x0      
        cmp r5, r0              @ Compara o retorno (em r0) com r5.
        ble min                 @ Se r5(so3) < r0 (so4): Salta pra min
        mov r5, r0
min:
        cmp r5, r6              @ Compara r0 com r6
        blt esq                 @ Se r0 menor que o limiar: Salta para dir

                                @ Senao define uma velocidade para os 2 motores
        mov r0, #36            
        mov r1, #36
        mov r7, #124        
        svc 0x0

        b loop                  @ Refaz toda a logica
        

            @ Refaz toda a logica


esq:                            @vira ele para a esquerda
        mov r0, #0             
        mov r1, #4
        mov r7, #124
        svc 0x0
        b loop  


        mov r7, #1              @ syscall exit
        svc 0x0



