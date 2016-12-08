.org 0x0
.section .iv, "a"

@vetor de interrupcoes
_start:

interrupt_vector:
.org 0x00
    b RESET_HANDLER

.org 0x08
    b SYSCALL_HANDLER

.org 0x18
    b IRQ_HANDLER



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@definicoes de constantes
.text

@definicao do .text do modo USER (maior que 77802000 definido no Makefile)
.set USER_TEXT,             0x77802500

@enderecos do GPT
.set GPT_BASE,              0x53FA0000
.set GPT_CR,                0x0
.set GPT_PR,                0x4
.set GPT_SR,                0x8
.set GPT_OCR1,              0x10
.set GPT_IR,                0xC

@constantes de clock
.set CLOCK_SRC,             0x41            @ enable clock
.set TIME_SZ,               100             @ clock cycling (1ms)
.set CLOCK_WAIT,            200

@enderecos do TZIC
.set TZIC_BASE,             0x0FFFC000
.set TZIC_INTCTRL,          0x0
.set TZIC_INTSEC1,          0x84
.set TZIC_ENSET1,           0x104
.set TZIC_PRIOMASK,         0xC
.set TZIC_PRIORITY9,        0x424

@enderecos do GPIO
.set GPIO_BASE,             0x53F84000
.set GPIO_DR,               0x0
.set GPIO_GDIR,             0x4
.set GPIO_PSR,              0x8

@mascara de GDIR (0 = entrada 1 = saida)
.set GDIR_MASK,             0b11111111111111000000000000111110

@mascara de velocidade dos motores
.set MOTOR_0_MASK,          0b11111110000000111111111111111111
.set MOTOR_1_MASK,          0b00000001111111111111111111111111

@mascara da data do sonar
.set SONAR_DATA_MASK,       0b111111111111


@constantes
.set MAX_CALLBACKS,         8
.set MAX_ALARMS,            8





@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.text


@                                TODOS OS SETS                                @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

RESET_HANDLER:

	@seta o endereco vetor de interrupcao no coprocessador 15
	ldr r0, =interrupt_vector
	mcr p15, 0, r0, c12, c0, 0

	mov r1, #0
	@reseta sys_time
	ldr r0, =CONTADOR
	str r1, [r0]

	@reseta alarmes
	ldr r0, =alarms
	str r1, [r0]

	@resetal call_backs
	ldr r0, =call_backs
	str r1, [r0]


SET_GPT:
	@ Constantes para os enderecos de GPT

	.set TIME_SZ,  100

	ldr r1, =GPT_BASE

	@ Habilita e configura o clock_src para periférico
	mov r0, #0x41
	str r0, [r1, #GPT_CR]

	@ Zera o prescaler
	mov r0, #0
	str r0, [r1, #GPT_PR]

	@ Coloca em GPT_OCR1 o valor que eu desejo contar (100)
	mov r0, #100
	str r0, [r1, #GPT_OCR1]

	@ Habilita interrupcao Output Compare Channel 1
	mov r0, #1
	str r0, [r1, #GPT_IR]


SET_TZIC:

	@ Liga o controlador de interrupcoes
  @ R1 <= TZIC_BASE

  ldr	r1, =TZIC_BASE

  @ Configura interrupcao 39 do GPT como nao segura
  mov	r0, #(1 << 7)
  str	r0, [r1, #TZIC_INTSEC1]

  @ Habilita interrupcao 39 (GPT)
  @ reg1 bit 7 (gpt)

  mov	r0, #(1 << 7)
  str	r0, [r1, #TZIC_ENSET1]

  @ Configure interrupt39 priority as 1
  @ reg9, byte 3

  ldr r0, [r1, #TZIC_PRIORITY9]
  bic r0, r0, #0xFF000000
  mov r2, #1
  orr r0, r0, r2, lsl #24
  str r0, [r1, #TZIC_PRIORITY9]

  @ Configure PRIOMASK as 0
  eor r0, r0, r0
  str r0, [r1, #TZIC_PRIOMASK]

  @ Habilita o controlador de interrupcoes
  mov	r0, #1
  str	r0, [r1, #TZIC_INTCTRL]

  @instrucao msr - habilita interrupcoes
  msr  CPSR_c, #0x13

SET_GPIO:
	@r1 recebe o endereco de GPIO
	ldr r1, =GPIO_BASE

	@define a mascara para os pinos do GPIO (pinos de entrada e saida)
	ldr r0, =GDIR_MASK
	str r0, [r1, #GPIO_GDIR]


SET_STACKS:


  @entra no modo IRQ
  msr CPSR_c, #0x12
  @ajusta o comeco de sp para essa posicao
  ldr r1,=STACK_IRQ
  ldr r1, [r1]
  mov sp, r1


  @entra no modo SYSTEM
  msr CPSR_c, #0x1F
  @muda o comeco da pilha para esta posicao
  ldr r1, =STACK_SYS
  ldr r1, [r1]
  mov sp, r1


  @entra no modo SUPERVISOR
  msr CPSR_c, #0x13
  @ajusta o comeco da pilha para essa posicao
  ldr r1, =STACK_SUPER
  ldr r1, [r1]
  mov sp, r1



RETURN_TO_USER:
	@retorna para o modo de usuario
	ldr r0, =USER_TEXT

	@muda para modo USER
	msr CPSR_c, #0x10

    @salta para a posicao do inicio do programa do usuario
    mov pc, r0


@                               IRQ_HANDLER                                   @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IRQ_HANDLER:
  stmfd sp!, {r0-r12, lr}
  ldr r1, =GPT_BASE

  @Coloca 1 em GPT_SR (declara que teve interrupcao)
  mov r0, #1
  str r0, [r1, #GPT_SR]

  @Incrementa contador na memoria
  ldr r0, =CONTADOR
  ldr r1, [r0]
  add r1, r1, #1
  str r1, [r0]





@@@@@@@checa se tem alarme



check_alarm:
@r1: tempo dos alarmes
@r2: funcoes que sao chamadas quando da o tempo dos alarmes
@r3: quantidade de alarmes
@r4: contadorde loop_check_alarms
@r5: tempo do alarme
@r6: numero de alarmes que ainda faltam
@r7: funcao para ser pulada quando mudar para modo usuario
@r8: nova quantidade de alarmes (depois que tiraram o que ja foi tocado)
ldr r1, =ALARMS_TIME
ldr r2, =ALARMS_FUNCTIONS
ldr r9, =alarms
ldr r3, [r9]
mov r8, r3
mov r4, #0
mov r6, #0              @ Number of alarms not called

@testa se checou todos os alarmes
loop_check_alarms:
add r4, r4, #1
cmp r4, r3
bgt check_callback

ldr r5, [r1]

@testa se o tempo do alarme atual nao eh o tempo do sistema
cmp r5, r0
@se nao for, passa para o proximo alarme
addne r1, r1, #4
addne r2, r2, #4
@e ainda falta mais um alarme (mais um alarme nao foi chamado ainda)
addne r6, r6, #1
@testa o proximo alarme da lista
bne loop_check_alarms

@se testou todos os alarmes e tem um com o tempo igual ao tempo do sistema
@(nao pulou para finish alarms)
@um alarme tem o tempo do sistema e vai ser executado

@atualiza a nova quantidade de alarmes
sub r8, r8, #1

@salva a nova quantidade de alarmes
str r8, [r9]

@salva r0, r1, r2, r3 (vai ser usado depois e tambem dentro da funcao de excluir alarme)
stmfd sp!, {r0-r3}
@r0: posicao no vetor de tempo de alarme
@r1: posicao no vetor de funcao dos alarmes
@r2: numero de posicoes para ser deslocados (alarmes que sobram no vetor)
mov r0, r1
mov r1, r2
sub r2, r8, r6
bl deleta
ldmfd sp!, {r0-r3}

@r10 recebe a funcao a ser chamada
ldr r7, [r2]


stmfd sp!, {r0-r3}
@muda para modo usuario
msr CPSR_c, #0xD0
@pula para a funcao (executa a funcao)
blx r10

mov r1, r7
@syscall para voltar para modo IRQ
mov r7, #75
svc 0x0
mov r7, r1
ldmfd sp!, {r0-r3}

b loop_check_alarms

deleta:
stmfd sp!, {r4-r5, lr}

loop_deleta:
@r0: posicao no vetor de tempo de alarme
@r1: posicao no vetor de funcao dos alarmes
@r2: numero de posicoes para ser deslocados (alarmes que sobram no vetor)
  @enquanto r2 nao eh zero (nao deslocou todas as posicoes)
  cmp r2, #0
  beq fim_deleta

  @pega as posicoes seguintes
  add r3, r0, #4
  add r4, r1, #4

  @salvam na posicao atual
  ldr r5, [r3]
  str r5, [r0]

  ldr r5, [r4]
  str r5, [r1]

  @atualiza a posicao nos vetores de tempo e funcao
  mov r0, r3
  mov r1, r4

  @decrementa o numero de posicoes que ainda faltam ser deslocados
  sub r2, r2, #1

  b loop_deleta

  fim_deleta:
  ldmfd sp!, {r4-r5, lr}

  mov pc, lr




@@@@@@@@@checa se tem callback


check_callback:
@r0: id do sensor a ser lido
@r1: vetor de id de sonares
@r2: vetor de funcoes de callbacks
@r3: vetor de thresholds de distancias
@r4: numero de callbacks
@r5: ditancia limite (threshold)
@r6: contador
@r7: funcao para executar quando chega no treshold
ldr r4, =callbacks
ldr r4, [r4]
ldr r1, =CALLBACK_IDS
ldr r2, =CALLBACK_FUN
ldr r3, =CALLBACK_THRES
mov r6, #0

@testa todas as callbacks
loop_make_callbacks:
add r6, r6, #1
cmp r6, r4
bgt break_IRQ

@ve qual eh o id do sonar a ser lido
ldr r0, [r1], #4
@salva os registradores antes de ler a distancia
stmfd sp!, {r1-r3}
@le a distancia do sonar
bl INTERNAL_READ_SONAR
@recupera os registradores
ldmfd sp!, {r1-r3}

ldr r5, [r3], #4

@se a distancia ainda nao chegou no treshold
cmp r0, r5
bgt end_callback_loop

@se a distancia ja chegou ou eh menor que o treshold
ldr r7, [r2]
@salva os registradores
stmfd sp!, {r0-r3}
@muda para o modo usuario
msr CPSR_c, #D0
@executa a funcao
blx r7
@salva o valor de r7
mov r1, r7
@retorna para modo IRQ
mov r7, #75
@chama a syscall
svc 0x0
@recupera o valor de r7
mov r7, r1
Desempilha
ldmfd sp!, {r0-r3}

@pula para a proxima funcao
end_callback_loop:
add r2, r2, #4
b loop_make_callbacks



@Retorna para a execucao do usuario
break_IRQ

  ldmfd sp!, {r0-r12, lr}

  sub lr, lr, #4
  movs pc, lr

@                                SYSCALL_HANDLER                              @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
SYSCALL_HANDLER:
  stmfd sp!, {lr}

  @funcao read sonar
  cmp r7, #16
  bleq READ_SONAR

  @ @funcao register_proximity_callback
  @ cmp r7, #17
  @ bleq REGISTER_PROXIMITY_CALLBACK

  @funcao set_motor_speed
  cmp r7, #18
  bleq SET_MOTOR_SPEED

  @funcao set motors speed
  cmp r7, #19
  bleq SET_MOTORS_SPEED

  @funcao get time
  cmp r7, #20
  bleq GET_TIME

  @funcao set time
  cmp r7, #21
  bleq SET_TIME

  @funcao add alarm
  cmp r7, #22
  bleq ADD_ALARM

  @funcao para retornar para modo IRQ
  cmp r7, #75
  bleq BACK_TO_IRQ


  ldmfd sp!, {lr}

  @retorna para modo usuario
  movs pc, lr


@                                READ_SONAR                                   @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@tratamento da syscall read_sonar
READ_SONAR:
  @r1:id do sonar

  stmfd sp!, {r4-r11, lr}
  @salva CPRS em r0 para nao perder quando mudar de modo
  mrs r0, CPSR
  @entra no modo system para pegar os parametros da funcao da pilha
  msr CPSR, #0x1F
  @recupera o valor (salvando em r1)
  ldr r1, [sp]
  @retorna para o modo supervisor
  msr CPSR, r0

  @testa para ver se o id do sonar esta entre 0 e 15
  cmp r1, #15
  bhi break_read_sonar

  @se o sonar eh valido, pega o valor que esta em GPIO_DR
  ldr r0, =GPIO_BASE
  ldr r2, [r0, #GPIO_DR]
  @zera o MUX DO SONAR e o trigger
  bic r2, r2, #0b111110
  @desloca 2 bits para a esquerda para id ficar no lugar certo e ja coloca o
  @resultado em GPIO_DR
  lsl r1, r1, #2
  orr r2, r2, r1
  str r2, [r0, #GPIO_DR]

  @espera um tempo ate os valores serem setados
  bl delay

  @seta o trigger como 1
  ldr r2, [r0, #GPIO_DR]
  bic r2, r2, #0b10
  str r2, [r2, #GPIO_DR]

  @espera um tempo ate o valor do sensor ser definido

  bl delay

  @seta o trigger como 0
  ldr r2, [r0, #GPIO_DR]
  bic r2, r2, #0b10
  str r2, [r2, #GPIO_DR]

  @espera ate flag = 1 (ou seja, ja tem o resultado do sonar)
  ldr r2, [r0, #GPIO_DR]
  and r2, r2, #0b1
  cmp r2, #0b1
  beq flag_um
espera_flag:
  bl delay
  ldr r2, [r0, #GPIO_DR]
  and r2, r2, #0b1
  cmp r2, #0b1
  bne espera_flag

flag_um:

  @le o sonar (o resultado em GPIO_DR contem o SONAR_DATA)
  ldr r2, [r0, #GPIO_DR]
  @le apenas os bits de sonar data para frente
  mov r0, r2, lsr #6
  ldr r1, =SONAR_DATA_MASK
  and r0, r1

  @desempilha (retorna para SYSCALL_HANDLER)
  ldmfd sp!, {r4-r11, pc}


break_read_sonar:
  @retorna -1 se o id do sonar é invalido
  mov r0, #-1
  @desempilha (retorna para SYSCALL_HANDLER)
  ldmfd sp!, {r4-r11, pc}

@                             INTERNAL_READ_SONAR                             @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
INTERNAL_READ_SONAR:
  @r0:id do sonar

  @salva o id do sonar em r1
  mov r1, r0
  @se o sonar eh valido, pega o valor que esta em GPIO_DR
  ldr r0, =GPIO_BASE
  ldr r2, [r0, #GPIO_DR]
  @zera o MUX DO SONAR e o trigger
  bic r2, r2, #0b111110
  @desloca 2 bits para a esquerda para id ficar no lugar certo e ja coloca o
  @resultado em GPIO_DR
  lsl r1, r1, #2
  orr r2, r2, r1
  str r2, [r0, #GPIO_DR]

  @espera um tempo ate os valores serem setados
  bl delay

  @seta o trigger como 1
  ldr r2, [r0, #GPIO_DR]
  bic r2, r2, #0b10
  str r2, [r2, #GPIO_DR]

  @espera um tempo ate o valor do sensor ser definido

  bl delay

  @seta o trigger como 0
  ldr r2, [r0, #GPIO_DR]
  bic r2, r2, #0b10
  str r2, [r2, #GPIO_DR]

  @espera ate flag = 1 (ou seja, ja tem o resultado do sonar)
  ldr r2, [r0, #GPIO_DR]
  and r2, r2, #0b1
  cmp r2, #0b1
  beq flag_um
espera_flag:
  bl delay
  ldr r2, [r0, #GPIO_DR]
  and r2, r2, #0b1
  cmp r2, #0b1
  bne espera_flag

flag_um:

  @le o sonar (o resultado em GPIO_DR contem o SONAR_DATA)
  ldr r2, [r0, #GPIO_DR]
  @le apenas os bits de sonar data para frente
  mov r0, r2, lsr #6
  ldr r1, =SONAR_DATA_MASK
  and r0, r1

  @retorna
  mov pc, lr




@                                SET_MOTOR_SPEED                              @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

SET_MOTOR_SPEED:
  @r1:id
  @r2:speed

  stmfd sp!, {r4-r11, lr}
  @salva CPRS em r0 para nao perder quando mudar de modo
  mrs r0, CPSR
  @entra no modo system para pegar os parametros da funcao da pilha
  msr CPSR, #0x1F
  @recupera o valor (salvando em r1 e em r2)
  ldr r2, [sp]
  ldr r1, [sp,#4]
  @retorna para o modo supervisor
  msr CPSR, r0

  @testa se a velocidade eh valida
  cmp r2, #63
  bhi break_set_motor_speed
  @se ela eh valida, testa se os valores de id de motor eh valido
  cmp r1, #0
  bleq motor0
  cmp r1, #1
  bleq motor1
  b break_set_motor_id

  ldr r0, =GPIO_BASE
  ldr r3, [r0, #GPIO_DR]
motor0:
  @desloca a velocidade para a posicao certa
  mov r2, r2, lsl #19
  and r3, r3, #MOTOR_0_MASK
  orr r1, r1, r3
  @escreve a velocidade na saida
  str r1, [r0, #GPIO_DR]
  mov r0, #0
  ldmfd sp!, {r4-r11, pc}

motor1:
  @desloca a velocidade para a posicao certa
  mov r2, r2, lsl #26
  and r3, r3, #MOTOR_1_MASK
  orr r1, r1, r3
  @escreve a velocidade na saida
  str r1, [r0, #GPIO_DR]
  mov r0, #0
  ldmfd sp!, {r4-r11, pc}

break_set_motor_id:
  @retorna -1 se a funcao tem id de motor invalido
  mov r0, #-1
  ldmfd sp!, {r4-r11, pc}

break_set_motor_speed:
  @retorna -2 se a funcao tem velocidade de motor invalida
  mov r0, #-2
  ldmfd sp!, {r4-r11, pc}



@                                SET_MOTORS_SPEED                             @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
SET_MOTORS_SPEED:
  @r1: motor_id
  @r2: motor_speed'

  stmfd sp!, {r4-r11, lr}
  @salva CPRS em r0 para nao perder quando mudar de modo
  mrs r0, CPSR
  @entra no modo system para pegar os parametros da funcao da pilha
  msr CPSR, #0x1F
  @recupera o valor (salvando em r1 e em r2)
  ldr r1, [sp]
  ldr r2, [sp,#4]
  @retorna para o modo supervisor
  msr CPSR, r0

  @testa se a velocidade 0 eh valida
  cmp r1, #63
  bhi break_motor0_speed
  @testa se a velocidade 1 eh valida
  cmp r2, #63
  bhi break_motor1_speed

  ldr r0, =GPIO_BASE
  ldr r4, [r0, #GPIO_DR]

  @desloca a velocidade para a posicao certa
  mov r1, r1, lsl #19
  and r4, r4, #MOTOR_0_MASK
  orr r1, r1, r4
  @escreve a velocidade na saida
  str r1, [r0, #GPIO_DR]


  @desloca a velocidade para a posicao certa
  mov r2, r2, lsl #26
  and r4, r4, #MOTOR_1_MASK
  orr r2, r2, r4
  @escreve a velocidade na saida
  str r2, [r0, #GPIO_DR]

  mov r0, #0
  ldmfd sp!, {r4-r11, pc}

break_motor0_speed:
  @retorna -1 se a funcao tem velocidade do motor 0 invalida
  mov r0, #-1
  ldmfd sp!, {r4-r11, pc}

break_motor1_speed:
  @retorna -2 se a funcao tem velocidade do motor 1 invalida
  mov r0, #-2
  ldmfd sp!, {r4-r11, pc}



@                         REGISTER_PROXIMITY_CALLBACK                         @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
REGISTER_PROXIMITY_CALLBACK:
    @r1:sensor_id
    @r2: sensor_threshold
    @r3: ponteiro para a funcao
    stmfd sp!, {r4-r11, lr}
    @salva CPRS em r0 para nao perder quando mudar de modo
    mrs r0, CPSR
    @entra no modo system para pegar os parametros da funcao da pilha
    msr CPSR, #0x1F
    @recupera o valor (salvando em r1 e em r2)
    ldr r1, [sp]
    ldr r2, [sp,#4]
    ldr r3, [sp, #8]
    @retorna para o modo supervisor
    msr CPSR, r0

    @ make the necessary verifications
    ldr r4, =callbacks
    ldr r9, [r4]

    @se ja chegou no maximo de callbacks retorna -1
    cmp r4, #MAX_CALLBACKS
    bhs break_call_backs

    @se o sensor nao existe retorna -2
    cmp r0, #MAX_SENSOR_ID              @ if id > MAX_SENSOR_ID
    bhi break_call_backs_id

    @soma 1 no total de callbacks
    add r8, r9, #1
    srt r8, [r4]

    @modifica a posicao do vetor de registros de sinais a ser alterado

    lsl r9, r9, #2


    ldr r5, =CALLBACK_ID
    ldr r6, =CALLBACK_THRESH
    ldr r7, =CALLBACK_FUNCTIONS
    @se esta tudo certo, guarda os valores nos vetores
    str r0, [r5, r9]
    str r1, [r6, r9]
    str r2, [r7, r9]

    @retorna 0 se deu tudo certo
    mov r0, #0

    ldmfd sp!, {r4-r11, pc}

break_call_backs:
  @retorna -1 se a funcao tem velocidade do motor 0 invalida
  mov r0, #-1
  ldmfd sp!, {r4-r11, pc}

break_call_backs_id:
  @retorna -2 se a funcao tem velocidade do motor 1 invalida
  mov r0, #-2
  ldmfd sp!, {r4-r11, pc}

@                                GET_TIME                                     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
GET_TIME:
  ldmfd sp!, {lr}

  ldr r1, =CONTADOR
  ldr r0, [r1]

  ldmfd sp!, {pc}

@                                SET_TIME                                     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
SET_TIME:
  stmfd sp!, {lr}
  @r1: endereco para salvar o tempo

  @salva CPRS em r0 para nao perder quando mudar de modo
  mrs r0, CPSR
  @entra no modo system para pegar os parametros da funcao da pilha
  msr CPSR, #0x1F
  @recupera o valor (salvando em r1)
  ldr r1, [sp]
  @retorna para o modo supervisor
  msr CPSR, r0
  ldr r0, =CONTADOR
  str r1, [r0]

  ldmfd sp!, {pc}



@                                SET_ALARM                                    @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
SET_ALARM:
    @r1:time (unsigned int)
    @r2:function
    stmfd sp!, {r4-r11, lr}
    @salva CPRS em r0 para nao perder quando mudar de modo
    mrs r0, CPSR
    @entra no modo system para pegar os parametros da funcao da pilha
    msr CPSR, #0x1F
    @recupera o valor (salvando em r1 e em r2)
    ldr r2, [sp]
    ldr r1, [sp,#4]
    @retorna para o modo supervisor
    msr CPSR, r0

    dr r0, =alarms
    ldr r4, [r0]
    @se ja possui o maximo de alarmes
    cmp r4, #MAX_ALARMS                 @ if r1 >= MAX_ALARMS
    bge time_error                 @   return -1

    ldr r7, =CONTADOR
    ldr r7, [r7]

    @testa se ja passou o tempo do alarme a set setado
    cmp r7, r1
    bhi break_max

    @guarda a nova quantidade de alarmes
    add r8, r4, #1
    srt r8, [r0]

    @modifica a posicao do vetor de registros de sinais a ser alterado

    lsl r4, r4, #2

    @se nao tem erro, guarda os valores nas listas de alarmes
    ldr r5, =ALARMS_FUNCTIONS
    ldr r6, =ALARMS_TIME

    str r2, [r5, r4]
    str r1, [r6, r4]

    @retorna 0 se deu tudo certo
    mov r0, #0

    ldmfd sp!, {r4-r11, lr}

break_time_error:
  @retorna -1 se a funcao tem velocidade do motor 0 invalida
  mov r0, #-1
  ldmfd sp!, {r4-r11, pc}

break_max:
  @retorna -2 se a funcao tem velocidade do motor 1 invalida
  mov r0, #-2
  ldmfd sp!, {r4-r11, pc}


@                                DELAY                                        @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
delay:
    stmfd sp!, {lr}
    mov r0, #0
loop:
    add r0, r0, #1
    cmp r0, #1000
    ble loop
    ldmfd sp!, {pc}


@                               BACK_TO_IRQ                                   @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
BACK_TO_IRQ:
  
  mrs r1, SPSR
  bic r1, #0xFF
  orr r1, r1, #D2
  msr SPSR, r1

  ldmfd sp!, {r1-r12, lr}
  movs pc, lr



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.data

CONTADOR:
  .skip 32

alarms:
	.word 0

call_backs:
	.word 0

@tamanho total das stacks (1024 para cada um dos 4 modos)
STACK_USER:
  .skip 1024

STACK_SUPER:
  .skip 1024

STACK_SYS:
  .skip 1024

STACK_IRQ:
  .skip 1024

@tamanho: 8*32 = 256
CALLBACK_ID:
.skip 256

CALLBACK_FUNCTIONS:
.skip 256

CALLBACK_THRESH:
.skip 256

ALARMS_FUNCTIONS:
.skip 256

ALARMS_TIME:
.skip 256
