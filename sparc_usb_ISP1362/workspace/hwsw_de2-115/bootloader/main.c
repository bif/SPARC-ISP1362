#include <inttypes.h>
#include <machine/modules.h>
#include <machine/interrupts.h>
#include <machine/UART.h>
#include <stdio.h>
#include <string.h>
#include <drivers/drivers.h>

// --------------- defines for buttons/switche/leds ----------------
#define BUT_SW_LED_BADDR                ((uint32_t)-320)
#define BUT_SW_LED_STATUS (*(volatile int *const) (BUT_SW_LED_BADDR))
#define DATA_IO_0_3   (*(volatile int *const) (BUT_SW_LED_BADDR+4))
#define DATA_IO_4_5   (*(volatile int *const) (BUT_SW_LED_BADDR+8))

#define SWITCH_MASK ((uint32_t) 0x3FFFF)
#define LED_MASK ((uint32_t) 0xFFFF)

#define BUTTON1	0
#define BUTTON2 1
#define BUTTON3 2

#define SW_ON 1
#define SW_OFF 0
#define SW_OFFSET 3
#define LED_OFFSET_IO_0_3 21
#define LED_OFFSET_IO_4_5 11

#define R_LED0 (1<<0)
#define R_LED1 (1<<1)
#define R_LED2 (1<<2)
#define R_LED3 (1<<3)
#define R_LED4 (1<<4)
#define R_LED5 (1<<5)
#define R_LED6 (1<<6)
#define R_LED7 (1<<7)
#define R_LED8 (1<<8)
#define R_LED9 (1<<9)
#define R_LED10 (1<<10)
#define R_LED11 (1<<11)
#define R_LED12 (1<<12)
#define R_LED13 (1<<13)
#define R_LED14 (1<<14)
#define R_LED15 (1<<15)
#define R_LED16 (1<<16)
#define R_LED17 (1<<17)

#define G_LED0 (1<<18)
#define G_LED1 (1<<19)
#define G_LED2 (1<<20)
#define G_LED3 (1<<21)
#define G_LED4 (1<<22)
#define G_LED5 (1<<23)
#define G_LED6 (1<<24)
#define G_LED7 (1<<25)
#define G_LED8 (1<<26)

// ----------------------- defines for timer -----------------------
#define TIMER_BADDR											((uint32_t)-288)
#define TIMER_CONF_REG 		(*(volatile int *const) (TIMER_BADDR+3)) 
#define TIMER_STATUS_REG 	(*(volatile int *const) (TIMER_BADDR+1)) 


#define TIMER_CLK_MATCH   (*(volatile int *const) (TIMER_BADDR+4))
#define TIMER_PREESCLER   (*(volatile int *const) (TIMER_BADDR+8))

#define START_TIMER	0	// bit to start inst_timer
#define STOP_TIMER	1	// bit to stop inst_timer



// ---------------- functions for buttons/switches/leds ------------
uint32_t getButtonStatus(void)
{
	uint32_t ret_val;
	
	ret_val = 0;

	// negation because buttons are low-active
	if(!(DATA_IO_0_3 & (1<<BUTTON1)))
		ret_val |= (1<<BUTTON1);
	if(!(DATA_IO_0_3 & (1<<BUTTON2)))
		ret_val |= (1<<BUTTON2);
	if(!(DATA_IO_0_3 & (1<<BUTTON3)))
		ret_val |= (1<<BUTTON3);
	
	return ret_val;
}

uint8_t getSwitchStatus(uint32_t sw_nbr)
{
	uint32_t sw;

	sw = 0;

	sw |= (uint32_t) ((DATA_IO_0_3 >> SW_OFFSET) & SWITCH_MASK);
	if (sw & (1<<sw_nbr))
		return SW_ON;
	else		
		return SW_OFF;
		
	//SW error
	return 2;
}

// usage: setLeds(R_LEDx | ... | GLEDx | ... )
void setLeds(uint32_t leds)//, uint8_t on_off))
{
	uint32_t tmp;
  tmp = (leds << LED_OFFSET_IO_0_3);
  DATA_IO_0_3 = tmp;
  
  tmp = (leds >> LED_OFFSET_IO_4_5);
  tmp &= LED_MASK;
  DATA_IO_4_5 = tmp;
}


// ---------------------- functions for timer  ---------------------
void timer_initHandle(module_handle_t *h, scarts_addr_t baseAddress) {
  h->baseAddress = baseAddress;
}

void timer_releaseHandle(module_handle_t *h) {
}

void timer_irq_ack(module_handle_t *h) {
  volatile uint8_t *reg;
  reg = (uint8_t *)(h->baseAddress+MODULE_CONFIG_BOFF);
  *reg |= (1<<MODULE_CONFIG_INTA);
}

void start_timer()
{
	TIMER_CONF_REG &= ~(1<<STOP_TIMER);
	TIMER_CONF_REG |= (1<<START_TIMER);
	}
}

void stop_timer()
{
  TIMER_CONF_REG &= ~(1<<START_TIMER);
  TIMER_CONF_REG |= (1<<STOP_TIMER);
}

void config_timer(uint32_t timer_top_match, uint8_t preescaler)
{
		TIMER_CLK_MATCH = timer_top_match;
    TIMER_PREESCALER = preescaler;
}


static module_handle_t timer_handle;

//void isr() __attribute__ ((interrupt));

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
  UART_Cfg cfg;

  // Initialize peripheral components ...
  // UART
  cfg.fclk = 50000000;
  cfg.baud = UART_CFG_BAUD_115200;
  cfg.frame.msg_len = UART_CFG_MSG_LEN_8;
  cfg.frame.parity = UART_CFG_PARITY_EVEN;
  cfg.frame.stop_bits = UART_CFG_STOP_BITS_1;
  UART_init (cfg);

  UART_write(0, "Hello", 5);
  //TIMER_BADDR |= (1<<2);
  //setLeds(R_LED1);
  //register interrupt to line 2
//  REGISTER_INTERRUPT(isr, 2);
  // unmask interrupt line 2
//  UMASKI(2);
  // globally enable interrupts
//  SEI();
   
  //setLeds(R_LED2 | G_LED0);
    // timer 80000 ticks = 1ms, 80 ticks = 1s
  config_timer(50000, 50);
//  timer_initHandle(&timer_handle, TIMER_BADDR);
//  start_timer();
  
  //TIMER_BADDR &= ~(1<<2);
	while(1);	


  return 0;
}
