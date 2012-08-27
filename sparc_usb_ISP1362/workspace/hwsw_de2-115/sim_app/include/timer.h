#ifndef __timer_h__
#define __timer_H__

#include <drivers/drivers.h>

#define TIMER_BADDR				((uint32_t)-480)
#define TIMER_CONF_REG 		(*(volatile int *const) (TIMER_BADDR+3)) 
#define TIMER_STATUS_REG 	(*(volatile int *const) (TIMER_BADDR+1)) 

#define TIMER_CLK_MATCH   (*(volatile int *const) (TIMER_BADDR+4))
#define TIMER_PRESCALER   (*(volatile int *const) (TIMER_BADDR+8))

#define START_TIMER	0	// bit to start inst_timer
#define STOP_TIMER	1	// bit to stop inst_timer


void timer_initHandle(module_handle_t *h, scarts_addr_t baseAddress);

void timer_releaseHandle(module_handle_t *h);

void timer_irq_ack(module_handle_t *h);

void start_timer();

void stop_timer();

void config_timer(uint32_t timer_top_match, uint8_t preescaler);


#endif //__timer_h__
