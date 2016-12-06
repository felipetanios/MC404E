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

@definicoes de constantes
.text

@definicao do .text do modo USER (maior que 77802000 definido no Makefile)
.set USER_TEXT				0x77802500

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


@constantes
.set MAX_CALLBACKS,         8
.set MAX_ALARMS,            8



.text

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@                                TODOS OS SETS                                @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

RESET_HANDLER:

	@seta o endereco vetor de interrupcao no coprocessador 15
	ldr r0, =interrupt_vector
	mcr p15, 0, r0, c12, c0, 0

	mov r1, #0
	@reseta sys_time
	ldr r0, =sys_time
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
  mov sp,=STACK_IRQ


  @entra no modo SYSTEM
  msr CPSR_c, #0x1F
  @muda o comeco da pilha para esta posicao
  mov sp,=STACK_SYS


  @entra no modo SUPERVISOR
  msr CPSR_c, #0x13
  @ajusta o comeco da pilha para essa posicao
  mov sp, =STACK_SUPER



RETURN_TO_USER:
	@retorna para o modo de usuario
	ldr r0, =USER_TEXT

	@muda para modo USER
	msr CPSR_c, #0x10
	@salta para a posicao do inicio do programa do usuario
	mov pc, r0


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@                                SYSCALL_HANDLER                              @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
SYSCALL_HANDLER:
  stmfd sp!, {lr}

  @funcao read sonar
  cmp r7, #16
  bleq READ_SONAR

  @funcao register_proximity_callback
  cmp r7, #17
  bleq REGISTER_PROXIMITY_CALLBACK

  @funcao set_motor_speed
  cmp r7, #18
  bleq SET_MOTOR_SPEED

  @funcao set motors speed
  cmp r7, #19                                     @ set motors speed
  bleq SET_MOTORS_SPEED

  cmp r7, #20
  bleq GET_TIME

  cmp r7, #21                                     @ set time
  bleq SET_TIME

  cmp r7, #22                                     @ set alarm
  bleq ADD_ALARM

  ldmfd sp!, {lr}

  @retorna para modo usuario
  movs pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
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
  srt r2, [r2, #GPIO_DR]

  @espera um tempo ate o valor do sensor ser definido

  bl delay

  @seta o trigger como 0
  ldr r2, [r0, #GPIO_DR]
  bic r2, r2, #0b10
  srt r2, [r2, #GPIO_DR]

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
  lsl r2, r2, #6
  @agora r0 contem apenas o resultado de sonar data
  and r0, r2, #0b111111111111

  @desempilha (retorna para SYSCALL_HANDLER)
  ldmfd sp!, {r4-r11, pc}


break_read_sonar:
  @retorna -1 se o id do sonar é invalido
  mov r0, #-1
  @desempilha (retorna para SYSCALL_HANDLER)
  ldmfd sp!, {r4-r11, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
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
  mov r4, sp
  sub r4, r4, #4
  ldr r2, [r4]
  sub r4, r4, #4
  ldr r1, [r4]
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
  ldr r4, [r0, #GPIO_DR]
motor0:
  @desloca a velocidade para a posicao certa
  mov r2, r2, lsl #19
  and r4, r4, #MOTOR_0_MASK
  orr r1, r1, r4
  @escreve a velocidade na saida
  str r1, [r0, #GPIO_DR]
  mov r0, #0
  ldmfd sp!, {r1-r11, pc}

motor1:
  @desloca a velocidade para a posicao certa
  mov r2, r2, lsl #26
  and r4, r4, #MOTOR_1_MASK
  orr r1, r1, r4
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


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@                                SET_MOTORS_SPEED                             @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @r1:speed1
  @r2:speed0

  stmfd sp!, {r4-r11, lr}
  @salva CPRS em r0 para nao perder quando mudar de modo
  mrs r0, CPSR
  @entra no modo system para pegar os parametros da funcao da pilha
  msr CPSR, #0x1F
  @recupera o valor (salvando em r1 e em r2)
  mov r4, sp
  sub r4, r4, #4
  ldr r2, [r4]
  sub r4, r4, #4
  ldr r1, [r4]
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
  motor0:
  @desloca a velocidade para a posicao certa
  mov r1, r1, lsl #19
  and r4, r4, #MOTOR_0_MASK
  orr r1, r1, r4
  @escreve a velocidade na saida
  str r1, [r0, #GPIO_DR]

  motor1:
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


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@                                SET_MOTORS_SPEED                             @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
REGISTER_PROXIMITY_CALLBACK:

@testa se o id do sensor eh valido
cmp r1, #15
bhi break_sonar_id


break_sonar_id:
    mov r0, #-2
    ldmfd sp!, {r4-r11, pc}

ADD_ALARM


.data

sys_time:
	.word 0

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
