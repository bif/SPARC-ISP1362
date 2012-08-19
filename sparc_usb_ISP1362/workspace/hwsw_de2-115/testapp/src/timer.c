#include "timer.h"

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
			TIMER_CONF_REG |= (1<<CMI);
		else
			TIMER_CONF_REG &= ~(1<<CMI);
	}
	if(timer == TIMER_I) {
		TIMER_INST_MATCH = value;
 		if(int_on)
			TIMER_CONF_REG |= (1<<IMI);
		else
			TIMER_CONF_REG &= ~(1<<IMI);
	}
}

uint32_t timer_getValue(uint8_t timer)
{
	if(timer == TIMER_C) {
		return TIMER_CLK_CNT;
	} else {
		if(timer == TIMER_I) {
			return TIMER_INST_CNT;
		} else {
			return 0xFFFFFFFF; 
		}
	}
}

