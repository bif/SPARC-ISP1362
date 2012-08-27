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

void start_timer()
{
	TIMER_CONF_REG &= ~(1<<STOP_TIMER);
	TIMER_CONF_REG |= (1<<START_TIMER);
}

void stop_timer()
{
  TIMER_CONF_REG &= ~(1<<START_TIMER);
  TIMER_CONF_REG |= (1<<STOP_TIMER);
}

void config_timer(uint32_t timer_top_match, uint8_t prescaler)
{
		TIMER_CLK_MATCH = timer_top_match;
    TIMER_PRESCALER = prescaler;
}
