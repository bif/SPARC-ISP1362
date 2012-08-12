#ifndef BUT_SW_LED_H
#define BUT_SW_LED_H

#define BUT_SW_LED_BADDR ((uint32_t)-384)
#define BUT_SW_LED_STATUS (*(volatile int *const) (BUT_SW_LED_BADDR))
#define DATA_IO_0_3   (*(volatile int *const) (BUT_SW_LED_BADDR+4))
#define DATA_IO_4_5   (*(volatile int *const) (BUT_SW_LED_BADDR+5))

#define SWITCH_MASK ((uint32_t) 0x3FFFF)

#define BUTTON1	0
#define BUTTON2 1
#define BUTTON3 2

#define SW0 0
#define SW1 1
#define SW2 2
#define SW3 3
#define SW4 4
#define SW5 5
#define SW6 6
#define SW7 7
#define SW8 8
#define SW9 9
#define SW10 10
#define SW11 11
#define SW12 12
#define SW13 13
#define SW14 14
#define SW15 15
#define SW16 16
#define SW17 17

#define R_LED0 0
#define R_LED1 1
#define R_LED2 2
#define R_LED3 3
#define R_LED4 4
#define R_LED5 5
#define R_LED6 6
#define R_LED7 7
#define R_LED8 8
#define R_LED9 9
#define R_LED10 10
#define R_LED11 11
#define R_LED12 12
#define R_LED13 13
#define R_LED14 14
#define R_LED15 15
#define R_LED16 16
#define R_LED17 17

#define G_LED0 0
#define G_LED1 1
#define G_LED2 2
#define G_LED3 3
#define G_LED4 4
#define G_LED5 5
#define G_LED6 6
#define G_LED7 7
#define G_LED8 8

#define SW_ON 1
#define SW_FF 2

uint32_t sw_old;

extern uint32_t getButtonStatus(void);
extern uint8_t getSwitchStatus(uint32_t sw_nbr);
extern void setLeds(uint32_t leds);

#endif 
