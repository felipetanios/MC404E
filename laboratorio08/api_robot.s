	@ Global symbol
    .global set_speed_motor
    .global set_speed_motors
    .global read_sonar
    .global read_sonars

    .align 4
set_speed_motors:
	stmfd sp!, {r7, lr}	@ Save the callee-save registers
			            @ and the return address.

    @r0 tem o valor do motor 0
    @r1 tem o valor do motor 1

    mov r7, #124            @ Identifica a syscall 124 (write_motors).
    svc 0x0                 @ Faz a chamada da syscall.

    ldmfd sp!, {r7, pc} @ Restore the registers and return



set_speed_motor:
	stmfd sp!, {r7, lr}	@ Save the callee-save registers
			            @ and the return address.
	@r0 tem o valor da velocidade
	@r1 tem o motor que vai ser usado
	mov r2, #0

	cmp r1, r2
	beq set_mot

	mov r1, r0
	mov r0, #0

set_mot:
    mov r7, #124            @ Identifica a syscall 124 (write_motors).
    svc 0x0                 @ Faz a chamada da syscall.

    ldmfd sp!, {r7, pc} @ Restore the registers and return

read_sonar:
	stmfd sp!, {r7, lr}	@ Save the callee-save registers
	@r0: id do sonar a ser lido

	mov r7, #125            @ Identifica a syscall 125 (read_sonar).
    svc 0x0                 
    ldmfd sp!, {r7, pc} @ Restore the registers and return

read_sonars:
	stmfd sp!, {r7, lr}	@ Save the callee-save registers
			            @ and the return address.
	
	mov r1, r0
	@r1: endereco do vetor de distancias do sonar
	mov r2, #0
	cmp r2, #15
	ble stor
	ldmfd sp!, {r7, pc} @ Restore the registers and return

stor:
	mov r0, r2 		@r0 recebe qual sonar sera lido
	mov r7, #125            @ Identifica a syscall 125 (read_sonar).
    svc 0x0   
    @r0 tem o valor do sonar
    strh r0, [r1]! @salva no comeco do vetor e atualiza o indice              
	add r2, r2, #1 @incrementa r2
	cmp r2, #15
	ble stor
	
	mov pc, lr
