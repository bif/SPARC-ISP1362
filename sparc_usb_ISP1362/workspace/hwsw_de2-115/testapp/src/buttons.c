#include <stdint.h>
#include "buttons.h"

uint32_t getKeys(void)
{
	uint32_t ret;
	
	ret = 0;

	if(!(BUTTONS_DATA & (1<<1)))
		ret |= (1<<KEY1);
	if(!(BUTTONS_DATA & (1<<2)))
		ret |= (1<<KEY2);
	if(!(BUTTONS_DATA & (1<<3)))
		ret |= (1<<KEY3);
	
	return ret;
}

/*uint32_t switchVal()
{
	return (uint32_t) (BUTTONS_DATA >> 8);
}
*/
