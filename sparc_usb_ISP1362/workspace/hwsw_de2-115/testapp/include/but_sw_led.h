#ifndef BUT_SW_LED_H
#define BUT_SW_LED_H

#define BUT_SW_LED_BADDR ((uint32_t)-384)
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

extern uint32_t getButtonStatus(void);
extern uint8_t getSwitchStatus(uint32_t sw_nbr);
extern void setLeds(uint32_t leds);

#endif 
