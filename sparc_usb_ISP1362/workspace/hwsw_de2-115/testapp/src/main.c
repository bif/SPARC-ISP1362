#include <inttypes.h>
#include <machine/modules.h>
#include <machine/interrupts.h>
#include <machine/UART.h>
#include <stdio.h>
#include <drivers/dis7seg.h>
#include <drivers/vgatext.h>
#include <string.h>
#include "buttons.h"

#define DISP7SEG_BADDR                  ((uint32_t)-288)
#define VGATEXT_BADDR                   ((uint32_t)0xF0000100)

static dis7seg_handle_t display_handle;

int main (int argc, char *argv[])
{
  char msg[32] = "\n\rHallo Welt!\n\r";
  char msg_key1[32] = "Pushbutton 1\r";
  char msg_key2[32] = "Pushbutton 2\r";
  char msg_key3[32] = "Pushbutton 3\r";
  
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

  uint32_t keys, keys_old;
	keys_old = 0;

  UART_write(0, msg, strlen(msg));
  dis7seg_displayHexUInt32(&display_handle, 0, 0x00000042);


	while(1) {
		
		keys = getKeys();

		if(keys != keys_old) {
				if(keys & (1<<KEY3)) {
					UART_write(0, msg_key3, strlen(msg));
				}
				if(keys & (1<<KEY2)) {
					UART_write(0, msg_key2, strlen(msg));
				}
				if(keys & (1<<KEY1)) {
					UART_write(0, msg_key1, strlen(msg));
        }
			} 
		keys_old = keys;

	}

  return 0;
}
