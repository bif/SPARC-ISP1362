#include <inttypes.h>
#include <machine/modules.h>
#include <machine/interrupts.h>
#include <machine/UART.h>
#include <stdio.h>
#include <drivers/dis7seg.h>
#include <drivers/key_matrix.h>
#include <string.h>

#define KEY_MATRIX_BADDR                ((uint32_t)-352)
#define DISP7SEG_BADDR                  ((uint32_t)-288)

module_handle_t display_handle = {1};
module_handle_t key_matrix_handle = {1};

void isr() __attribute__ ((interrupt));

void isr ()
{
  uint8_t pressedKey;
  
  pressedKey = key_matrix_get_key(&key_matrix_handle);

  // output pressed key
  dis7seg_displayByte(&display_handle, 0, pressedKey);
 
  // acknowledge interrupt by setting INTA bit of extension module
  key_matrix_irq_ack(&key_matrix_handle);
}


int main (int argc, char *argv[])
{
  char msg[32] = "Hallo Welt!\n\r";
  UART_Cfg cfg;
  

  REGISTER_INTERRUPT(isr, 2);
  // unmask interrupt line 2
  UMASKI(2);
  // globally enable interrupts
  SEI();
  
  // Initialize peripheral components ...
  // UART
  cfg.fclk = UART_CFG_FCLK_40MHZ;
  cfg.baud = UART_CFG_BAUD_115200;
  cfg.frame.msg_len = UART_CFG_MSG_LEN_8;
  cfg.frame.parity = UART_CFG_PARITY_EVEN;
  cfg.frame.stop_bits = UART_CFG_STOP_BITS_1;
  UART_init (cfg);
  // KEY MATRIX
  key_matrix_initHandle(&key_matrix_handle, KEY_MATRIX_BADDR);
  // 7-Segment
  dis7seg_initHandle(&display_handle, DISP7SEG_BADDR);


  UART_write(0, msg, strlen(msg));
  dis7seg_displayByte(&display_handle, 0, 0x21);

  return 0;
}
