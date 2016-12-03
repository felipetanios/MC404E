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

@constantes
.set MAX_CALLBACKS,         8
.set MAX_ALARMS,            8
