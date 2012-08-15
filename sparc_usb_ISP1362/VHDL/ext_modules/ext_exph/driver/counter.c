/*
 * Project: Spear2
 * Author : Jakob Lechner
 * Copyright (c) TU Wien, ECS Group, 2009
 * 
 * Description: Driver for simple counter module
 *
 */

#define COUNTER_BASE (0xFFFFFEC0)
#define COUNTER_STATUS (*(volatile uint16_t *const) (COUNTER_BASE)) 
#define COUNTER_CONFIG_C (*(volatile uint8_t *const) (COUNTER_BASE+3))
#define COUNTER_VALUE (*(volatile uint32_t *const) (Counter_BASE+4)) 

#define CMD_COUNT 0
#define CMD_CLEAR 1

void counter_start()
{
  COUNTER_CONFIG_C = (1 << CMD_CLEAR);
  COUNTER_CONFIG_C = (1 << CMD_COUNT);
}

void counter_stop()
{
  COUNTER_CONFIG_C = 0;
}

void counter_resume()
{
  COUNTER_CONFIG_C = (1 << CMD_COUNT);
}

void counter_reset()
{
  COUNTER_CONFIG_C = (1 << CMD_CLEAR);
}

uint32_t counter_getValue()
{
  return COUNTER_VALUE;
}
