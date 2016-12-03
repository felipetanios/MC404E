.global set_motor_speed
.global set_motors_speed
.global read_sonar
.global read_sonars
.global register_proximity_callback
.global add_alarm
.global get_time
.global set_time

.align 4

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@                                 MOTORS                                    @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@A id do motor e as velocidades são passados como um ponteiro para um struct
@deve-se empilhar o parametro antes de chamar a syscall

set_motor_speed:
    stmfd sp!, {r4-r11, lr}
    @parametros:
    @r0 = ponteiro para struct do motor
    ldr r0,  =r0
    @r1 = id
    @r2 = speed
    @r3 = flag de teste de id de motor ou velocidade
    ldrb r1, [r0]
    ldrb r2, [r0, #1]
    @testa se os valores de id de motor são corretos
    cmp r1, #0
    moveq r3, #0
    cmp r1, #1
    moveq r3 #1
    cmp r3, #1
    bne break_motor_id

    @testa se o valor de velocidade de motor esta correto
    cmp r2, #63
    bhi break_motor_speed

    @empilha os valores para chamar a syscall
    stmfd sp!, {r1, r2}
    @determina a syscall
    mov r7, #18
    @chama o sistema operacional
    svc 0x0
    @retorna 0 como funcao ok
    mov r0, #0
    ldmfd sp!, {r4-r11, pc}

break_motor_id:
    @retorna -1 se a funcao tem id de motor invalido
    mov r0, #-1
    ldmfd sp!, {r4-r11, pc}

break_motor_speed:
    @retorna -1 se a funcao tem velocidade de motor invalida
    mov r0, #-2
    ldmfd sp!, {r4-r11, pc}





set_motors_speed:
    stmfd sp!, {r4-r11, lr}
    @parametros:
    @r0 = ponteiro para struct do motor 1
    @r1 = ponteiro para struct do motor 2
    ldr r0,  =r0
    ldr r1, = r1
    @r2 = speed1
    @r3 = speed2
    ldrb r2, [r0, #1]
    ldrb r3, [r1, #1]
    @testa se as velocidades sao validas
    cmp r2, #63
    bhi break_motor1_speed
    cmp r3, #63
    bhi break_motor2_speed
    @empilha os valores para chamar a syscall
    stmfd sp!, {r2, r3}
    @determina a syscall
    mov r7, #19
    @chama o sistema operacional
    svc 0x0
    @retorna 0 se a funcao tem velocidades de motores valida
    mov r0, #0
    ldmfd sp!, {r4-r11, pc}

break_motor1_speed:
      @retorna -1 se a funcao tem velocidade de motor invalida
      mov r0, #-1
      ldmfd sp!, {r4-r11, pc}


break_motor2_speed:
      @retorna -1 se a funcao tem velocidade de motor invalida
      mov r0, #-2
      ldmfd sp!, {r4-r11, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@                                 SONARS                                    @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
read_sonar:
    stmfd sp!, {r4-r11, lr}
    @parametros:
    @r0: id do sonar que deve ser lido
    @testa para ver se o id do sonar esta entre 0 e 15
    cmp r0, #15
    bhi break_read_sonar
    @empilha o identificador do sonar
    stmfd sp!, {r0}
    @ Identifica a syscall 16 (read_sonar)
    mov r7, #16
    @chama o sistema operacional
    svc 0x0
    @retorna o valor do sonar lido em r0
    ldmfd sp!, {r4-r11, pc}

break_read_sonar:
    @retorna -1 se o id do sonar é invalido
    mov r0, #-1
    ldmfd sp!, {r4-r11, pc}




read_sonars:
    stmfd sp!, {r4-r11, lr}
    @parametros:
    @r0: start
    @r1: end
    @r3: vetor de distancias (unsigned int)
    @r6: endereço do começo do vetor de distancias
    mov r6, =r3
    @r11: indice do vetor de distancias a ser escrito
    mov r11, #0
    @salva as variaveis start e end em outros registradores
    mov r4, r0
    mov r5, r1
    @enquanto nao chegou start != end ele vai para a funcao reading que vai ler
    @um por um os sonares chamando a funcao read sonar
loop:
    bl reading
    cmp r4, r5
    ble loop
    ldmfd sp!, {r4-r11, pc}

reading:
    @coloca o indice do sonar que vai ser lido em r0 e chama a funcao read sonar
    mov r0, r4
    bl read_sonar
    @agora o resultado do sonar esta em r0
    @salva o resultado na primeira posicao vazia do vetor de distancias
    str r0, [r6, r11]
    @atualiza a posicao do vetor
    add r11, r11, #4
    @atualiza a posicao a ser lida
    add r4, r4, #1
    mov pc, lr





register_proximity_callback:
    stmfd sp!, {r4-r11, lr}    @ Save the callee-save registers
    @parametros:
    @r0: sensor id
    @r1: sensor_threshold
    @r3: ponteiro para funcao (endereco do rotulo)
    @testa se o id do sensor eh valido

    @empilha as variaveis
    stmfd sp!, {r0, r1, r2}
    @define a syscall (17)
    mov r7, #17
    @chama o sistema operacional
    svc 0x0

    ldmfd sp!, {r4-r11, pc}      @ Restore the registers and return
break_sonar_id:
    



add_alarm:
    stmfd sp!, {r7, lr}    @ Save the callee-save registers

    mov r7, #22
    svc 0x0

    ldmfd sp!, {r7, pc}      @ Restore the registers and return

get_time:
    stmfd sp!, {r7, lr}    @ Save the callee-save registers

    mov r7, #20
    svc 0x0

    ldmfd sp!, {r7, pc}      @ Restore the registers and return


set_time:
    stmfd sp!, {r7, lr}    @ Save the callee-save registers

    mov r7, #21
    svc 0x0

    ldmfd sp!, {r7, pc}      @ Restore the registers and return
