#include <inttypes.h>
#include <machine/modules.h>
#include <machine/interrupts.h>
#include <machine/UART.h>
#include <stdio.h>
#include <drivers/dis7seg.h>
#include <drivers/vgatext.h>
#include <string.h>
#include "but_sw_led.h"
//#include "timer.h"

#define DISP7SEG_BADDR                  ((uint32_t)-288)
#define VGATEXT_BADDR                   ((uint32_t)0xF0000100)
#define BUT_SW_LED_BADDR                ((uint32_t)-384)
//#define TIMER_BADDR		              		((uint32_t)-416)


static dis7seg_handle_t display_handle;

int main (int argc, char *argv[])
{
  char msg[32] = "\n\rHallo Welt!\n\r";
  char msg_key1[32]		 	= " Pushbutton 1 ";
  char msg_key2[32] 		= " Pushbutton 2 ";
  char msg_key3[32] 		= " Pushbutton 3 ";
  char msg_pos1[32]			= "\r";
	char msg_tmp[32] = "";

  UART_Cfg cfg;
    
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
  
	
	uint32_t keys, keys_old, led_port;
	uint8_t i;

	keys_old = 0;
	led_port = 0;
	

  UART_write(0, msg, strlen(msg));
	
	
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
		// switches & leds
		led_port = 0;
		for(i=0; i<18; i++)
		{
			if (getSwitchStatus(i) == SW_ON) {
				led_port |= (SW_ON<<i);
				//(void) sprintf(msg_tmp, "KEY %i ON", i);
				//UART_write(0, msg_tmp, strlen(msg_tmp));
			}	
		} 
		UART_write(0, msg_pos1, strlen(msg_pos1));

		// leds
		setLeds(led_port | G_LED0 | G_LED2 | G_LED7);
	}


  return 0;
}
