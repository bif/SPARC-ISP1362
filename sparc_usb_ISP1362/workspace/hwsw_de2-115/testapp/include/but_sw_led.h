#ifndef BUT_SW_LED_H
#define BUT_SW_LED_H

#define BUT_SW_LED_BADDR ((uint32_t)-384)
#define BUT_SW_LED_STATUS (*(volatile int *const) (BUT_SW_LED_BADDR))
#define DATA_IO_0_3   (*(volatile int *const) (BUT_SW_LED_BADDR+4))
#define DATA_IO_4_5   (*(volatile int *const) (BUT_SW_LED_BADDR+8))

#define SWITCH_MASK ((uint32_t) 0x3FFFF)

#define BUTTON1	0
#define BUTTON2 1
#define BUTTON3 2

#define SW_ON 1
#define SW_OFF 0
#define SW_OFFSET 3
#define LED_OFFSET 21

extern uint32_t getButtonStatus(void);
extern uint8_t getSwitchStatus(uint32_t sw_nbr);
extern void setLeds(uint32_t leds);

#endif 
