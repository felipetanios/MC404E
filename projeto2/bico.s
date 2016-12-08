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
    @r1 = id
    @r2 = speed
    ldrb r1, [r0]
    ldrb r2, [r0, #1]
    @empilha os valores para chamar a syscall
    stmfd sp!, {r2}
    stmfd sp!, {r1}
    @determina a syscall
    mov r7, #18
    @chama o sistema operacional
    svc 0x0
    @retorna 0 como funcao ok
    mov r0, #0
    ldmfd sp!, {r4-r11, pc}




set_motors_speed:
    stmfd sp!, {r4-r11, lr}
    @parametros:
    @r0 = ponteiro para struct do motor 1
    @r1 = ponteiro para struct do motor 2
    @r2 = speed1
    @r3 = speed2
    ldrb r2, [r0, #1]
    ldrb r3, [r1, #1]

    @empilha os valores para chamar a syscall
    stmfd sp!, {r3}
    stmfd sp!, {r2}
    @determina a syscall
    mov r7, #19
    @chama o sistema operacional
    svc 0x0
    @retorna 0 se a funcao tem velocidades de motores valida
    mov r0, #0
    ldmfd sp!, {r4-r11, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@                                 SONARS                                    @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
read_sonar:
    stmfd sp!, {r4-r11, lr}
    @parametros:
    @r0: id do sonar que deve ser lido (unsigned char)

    @empilha o identificador do sonar
    stmfd sp!, {r0}
    @ Identifica a syscall 16 (read_sonar)
    mov r7, #16
    @chama o sistema operacional
    svc 0x0
    @retorna o valor do sonar lido em r0
    ldmfd sp!, {r4-r11, pc}



read_sonars:
    stmfd sp!, {r4-r11, lr}
    @parametros:
    @r0: start (int)
    @r1: end (int)
    @r3: endereco do vetor de distancias (unsigned int)

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
    str r0, [r3]
    @atualiza a posicao do vetor
    add r3, r3, #4
    @atualiza a posicao a ser lida
    add r4, r4, #1
    mov pc, lr





register_proximity_callback:
    stmfd sp!, {r4-r11, lr}    @ Save the callee-save registers
    @parametros:
    @r0: sensor id
    @r1: sensor_threshold
    @r3: ponteiro para funcao (endereco do rotulo)
    @empilha as variaveis
    stmfd sp!, {r2}
    stmfd sp!, {r1}
    stmfd sp!, {r0}
    @define a syscall (17)
    mov r7, #17
    @chama o sistema operacional
    svc 0x0
    @retorna 0
    mov r0, #0
    ldmfd sp!, {r4-r11, pc}      @ Restore the registers and return



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@                                 ALARMS                                    @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



get_time:
    stmfd sp!, {r4-r11, lr}    @ Save the callee-save registers
    @parametros:
    @r0: ponteiro para variavel que vai receber o tempo do sistema
    mov r9, r0
    @define a syscall
    mov r7, #20
    @chama o sistema operacional
    svc 0x0
    @r0: tempo do sistema
    str r0, [r9]

    ldmfd sp!, {r4-r11, pc}      @ Restore the registers and return


set_time:
    stmfd sp!, {r4-r11, lr}    @ Save the callee-save registers

    @parametros:
    @r0: novo tempo do sistema

    @empilha as variaveis
    stmfd sp!, {r0}
    @define a syscall
    mov r7, #21
    @chama o sistema operaciuonal
    svc 0x0

    ldmfd sp!, {r4-r11, pc}      @ Restore the registers and return



add_alarm:
    stmfd sp!, {r4-r11, lr}    @ Save the callee-save registers

    @parametros:
    @r0: endereco da funcao (ponteiro para o rotulo)
    @r1: tempo para invocar o alarme

    @empilha as variaveis
    stmfd sp!, {r1}
    stmfd sp!, {r0}
    @define a syscall
    mov r7, #22
    @chama o sistema operacional
    svc 0x0

    ldmfd sp!, {r4-r11, pc}      @ Restore the registers and return

time_error:
    mov r0, #-2
    ldmfd sp!, {r4-r11, pc}      @ Restore the registers and return
