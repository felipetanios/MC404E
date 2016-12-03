/*NAO ACABOU, REVISE*/

#include "bico.h"

#define DEF_SPEED 25
#define DIST_LIM 600

typedef struct
{
  unsigned char id;
  unsigned char speed;
} motor_cfg_t;

void _start (){
	//procura uma parede
	procura();
	//segue a parede
	segue();
}


void procura(){
	//anda
	go();
	//procura uma parede para retornar
	while(1){
		sonar3 = read_sonar(3);
		sonar4 = read_sonar(4);
		if ((sonar3 <= DIST_LIM) || (sonar4 <= DIST_LIM)){
			return;
		}
	}
}

void go(){
	unsigned short sonar3, sonar4;
	motor_cfg_t motor1, motor2;
	motor1.id = 1;
	motor1.speed = DEF_SPEED;
	motor2.id = 2;
	motor2.speed = DEF_SPEED;

	//comeca a andar
	set_motors_speed(&motor1, &motor2);
}

void segue(){
	//a parede esta na frente entao vira

}
