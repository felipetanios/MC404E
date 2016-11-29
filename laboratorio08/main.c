#include "api_robot.h" /* Robot control API */

void delay();

/* main function */
void _start(void) 
{
	unsigned short a, b;
	/* While not close to anything. */
	do{
		a = read_sonar(4);
		b = read_sonar(3);
		
		while ((a > 1200) && (b > 1200)){
			set_speed_motors(25,25);
			delay();
			a = read_sonar(4);
			b = read_sonar(3);
		} 
		while ((a < 1200) || (b < 1200)){
			set_speed_motors(10,0);
			delay();
			a = read_sonar(4);
			b = read_sonar(3);
		}
  }while (1);
}

/* Spend some time doing nothing. */
void delay()
{
  int i;
  /* Not the best way to delay */
  for(i = 0; i < 1000; i++ );  
}
