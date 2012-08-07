#ifndef BUTTONS_H
#define BUTTONS_H

#define BUTTONS_BADDR ((uint32_t)-384)
#define BUTTONS_STATUS (*(volatile int *const) (BUTTONS_BADDR))
#define BUTTONS_DATA   (*(volatile int *const) (BUTTONS_BADDR+4))

typedef enum {KEY1,KEY2,KEY3} keys_t;
extern uint32_t getKeys(void);
//extern uint32_t switchVal();

#endif 
