#include "timer.h"

void start_timer(uint8_t timer)
{
	if(timer == TIMER_C) {
		TIMER_CONF_REG &= ~(1<<STOP_C);
		TIMER_CONF_REG |= (1<<START_C);
	}
	if(timer == TIMER_I) {
		TIMER_CONF_REG &= ~(1<<STOP_I);
		TIMER_CONF_REG |= (1<<START_I);
	}
}

void stop_timer(uint8_t timer)
{
	if(timer == TIMER_C) {
		TIMER_CONF_REG &= ~(1<<START_C);
		TIMER_CONF_REG |= (1<<STOP_C);
	}
	if(timer == TIMER_I) {
		TIMER_CONF_REG &= ~(1<<START_I);
		TIMER_CONF_REG |= (1<<STOP_I);
	}
}

void config_timer(uint8_t timer, uint32_t value, uint8_t int_on)
{
	if(timer == TIMER_C) {
		TIMER_CLK_MATCH = value;
		if(int_on)
			TIMER_CONF_REG |= (1<<	
	}
	if(timer == TIMER_I) {
		TIMER_INST_MATCH = value; 
	}
}

uint32_t timer_getValue(uint8_t timer)
{
	if(timer == TIMER_C) {

	}
	if(timer == TIMER_I) {

	}
}

