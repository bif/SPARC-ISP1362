#include <inttypes.h>
#include <machine/modules.h>
#include <machine/interrupts.h>
#include <machine/UART.h>
#include <stdio.h>
#include <drivers/dis7seg.h>
#include <drivers/vgatext.h>
#include <string.h>
#include "but_sw_led.h"
#include "timer.h"



// ----------------------- defines for timer -----------------------
#define TIMER_BADDR											((uint32_t)-288)

// --------------- defines for buttons/switche/leds ----------------
#define BUT_SW_LED_BADDR                ((uint32_t)-320)


static module_handle_t timer_handle;

void isr() __attribute__ ((interrupt));

void isr(uint8_t* toggle) {
	// todo do PWM signal
  setLeds(R_LED0);
	if(toggle) {
    setLeds(G_LED0);
		*toggle = 0;
	}	else {
    setLeds(~G_LED0);
		*toggle = 1;
	}

	timer_irq_ack(&timer_handle);

}


int main (int argc, char *argv[])
{
  //TIMER_BADDR |= (1<<2);
  setLeds(R_LED1);
  //register interrupt to line 2
//  REGISTER_INTERRUPT(isr, 2);
  // unmask interrupt line 2
//  UMASKI(2);
  // globally enable interrupts
//  SEI();
   
  setLeds(R_LED2);
    // timer 80000 ticks = 1ms, 80 ticks = 1s
//  config_timer(50000, 0);
//  timer_initHandle(&timer_handle, TIMER_BADDR);
//  start_timer();
  
  //TIMER_BADDR &= ~(1<<2);
	while(1);	


  return 0;
}
