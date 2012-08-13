#include <stdint.h>
#include "but_sw_led.h"

uint32_t sw_old;

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

void setLeds(uint32_t leds)
{
	uint32_t tmp;
	
	tmp = 0;
	tmp |= (leds << LED_OFFSET);

	DATA_IO_0_3 = 0xFFFF;	

}

