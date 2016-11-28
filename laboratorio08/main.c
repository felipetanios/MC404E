#include "api_robot.h" /* Robot control API */

void delay();

/* main function */
void _start(void) 
{
  unsigned int distances[16];

  /* While not close to anything. */
  do {
    set_speed_motors(25,25);
    delay();
    
  } while ( ( distances[4] > 1200 ) && ( distances[3] > 1200 ));
  if (distances[4] < 1200){
    set_speed_motors(25,0);
    delay();
  } 
  if (distances[3] < 1200){
    set_speed_motors(0,25);
    delay();
  }
}

/* Spend some time doing nothing. */
void delay()
{
  int i;
  /* Not the best way to delay */
  for(i = 0; i < 10000; i++ );  
}
