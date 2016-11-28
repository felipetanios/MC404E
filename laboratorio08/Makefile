main.s: main.c
	arm-eabi-gcc main.c -S -o main.s

main.o: main.s
	arm-eabi-as main.s -o main.o

api_robot.o: api_robot.s
	arm-eabi-as api_robot.s -o api_robot.o


robot_ctrl: main.o api_robot.o
	arm-eabi-ld main.o api_robot.o -o robot_ctrl -Ttext=0x77802000
    
clean:
	rm -f main.s main.o api_robot.o robot_ctrl

