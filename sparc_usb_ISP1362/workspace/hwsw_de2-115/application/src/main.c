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


#define DISP7SEG_BADDR                  ((uint32_t)-288)
#define VGATEXT_BADDR                   ((uint32_t)0xF0000100)
#define BUT_SW_LED_BADDR                ((uint32_t)-384)
#define EXPH_BADDR											((uint32_t)-448)
#define DATA_EXPH   (*(volatile int *const) (EXPH_BADDR+4))
#define TIMER_BADDR											((uint32_t)-480)

static module_handle_t timer_handle;
static dis7seg_handle_t display_handle;


//void isr() __attribute__ ((interrupt));

void isr(uint8_t* toggle) {
	// todo do PWM signal
  setLeds(R_LED0);
	if(toggle) {
		//DATA_EXPH |= (1<<0);
    //setLeds(G_LED0);
		*toggle = 0;
	}	else {
		//DATA_EXPH &= ~(1<<0);
    //setLeds(~G_LED0);
		*toggle = 1;
	}

	timer_irq_ack(&timer_handle);

}



int main (int argc, char *argv[])
{
  char msg[32] = "\n\rHallo Welt!\n\r";
  char msg_key1[32]		 	= " Pushbutton 1 ";
  char msg_key2[32] 		= " Pushbutton 2 ";
  char msg_key3[32] 		= " Pushbutton 3 ";
  char msg_pos1[32]			= "\r";

  UART_Cfg cfg;

  //register interrupt to line 2
  //
  //TODO: wie übergebe ich an eine callback function einen wert und wie bekomme ich ihn wieder?
  REGISTER_INTERRUPT(isr, 2);
  // unmask interrupt line 2
  UMASKI(2);
  // globally enable interrupts
  SEI();
   
    
  // Initialize peripheral components ...
  // UART
  cfg.fclk = 50000000;
  cfg.baud = UART_CFG_BAUD_115200;
  cfg.frame.msg_len = UART_CFG_MSG_LEN_8;
  cfg.frame.parity = UART_CFG_PARITY_EVEN;
  cfg.frame.stop_bits = UART_CFG_STOP_BITS_1;
  UART_init (cfg);

  // 7-Segment
  dis7seg_initHandle(&display_handle, DISP7SEG_BADDR, 8);
  dis7seg_displayHexUInt32(&display_handle, 0, 0x00000042);

  // timer 80000 ticks = 1ms, 80 ticks = 1s
  config_timer(TIMER_C, 80, INT_ON);
  timer_initHandle(&timer_handle, TIMER_BADDR);
  start_timer(TIMER_C);

  uint32_t keys, keys_old, led_port;
  uint8_t i;

  keys_old = 0;
  led_port = 0;


  UART_write(0, msg, strlen(msg));
	
	char msg_tmp[32] = "DATA_EXPH = 1\n\r";
	while(1) {
		// pushbuttons
		keys = getButtonStatus();
		if(keys != keys_old) {
			if(keys & (1<<BUTTON3)) {
				UART_write(0, msg_key3, strlen(msg_key3));
			}
			if(keys & (1<<BUTTON2)) {
				UART_write(0, msg_key2, strlen(msg_key2));
			}
			if(keys & (1<<BUTTON1)) {
				UART_write(0, msg_key1, strlen(msg_key1));
			}
		}
		keys_old = keys;
		UART_write(0, msg_pos1, strlen(msg_pos1));

		// switches & leds
		led_port = 0;
		for(i=0; i<18; i++)
		{
			if (getSwitchStatus(i) == SW_ON)
				led_port |= (SW_ON<<i);
			else 
				led_port &= ~(SW_ON<<i);				
		}
		 
    setLeds(R_LED1);
		// set leds
		//setLeds(led_port);
	}


  return 0;
}
