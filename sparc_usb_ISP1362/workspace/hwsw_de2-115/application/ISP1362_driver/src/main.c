
#include <inttypes.h>
#include <machine/modules.h>
#include <machine/interrupts.h>
//#include <machine/UART.h>
#include <drivers/dis7seg.h>
#include <drivers/vgatext.h>

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

//#include "system.h"
#include "basic_io.h"
//#include "sys/alt_irq.h"
#include "but_sw_led.h"

//  for USB
#include "BASICTYP.h"
#include "COMMON.h"
#include "ISR.h"
#include "USB.h"
#include "MAINLOOP.h"

#include "ISP1362_HAL.h"

//#include "altera_avalon_pio_regs.h"
//#include "alt_types.h"


#define DISP7SEG_BADDR                  ((uint32_t)-288)
#define VGATEXT_BADDR                   ((uint32_t)0xF0000100)
#define BUT_SW_LED_BADDR                ((uint32_t)-384)
#define USB_ISP1362_BADDR               ((uint32_t)-416)

//-------------------------------------------------------------------------
//  Global Variable
D13FLAGS bD13flags; //USBCHECK_DEVICE_STATES defined in COMMON.h
USBCHECK_DEVICE_STATES bUSBCheck_Device_State; //USBCHECK_DEVICE_STATES defined in COMMON.h
CONTROL_XFER ControlData; //USBCHECK_DEVICE_STATES defined in COMMON.h
IO_REQUEST idata ioRequest; //USBCHECK_DEVICE_STATES defined in COMMON.h
//-------------------------------------------------------------------------
int main(int argc, char *argv[])
{
    disable();  //usb_irq.c
    disconnect_USB();   //MAINLOOP.c
    usleep(1000000);    //basic_io.h
    Hal4D13_ResetDevice();  //HAL4D13.c
    bUSBCheck_Device_State.State_bits.DEVICE_DEFAULT_STATE = 1;
    bUSBCheck_Device_State.State_bits.DEVICE_ADDRESS_STATE = 0;
    bUSBCheck_Device_State.State_bits.DEVICE_CONFIGURATION_STATE = 0;
    bUSBCheck_Device_State.State_bits.RESET_BITS = 0;  
    usleep(1000000);    //basic_io.h
    reconnect_USB();    //MAINLOOP.c
    CHECK_CHIP_ID();    //MAINLOOP.c
    Hal4D13_AcquireD13(USB_DC_IRQ,(void*)usb_isr);  //HAL4D13.c
    enable();   //usb_irq.c
    bD13flags.bits.verbose=1;
    
    while (1)
    {
      if (bUSBCheck_Device_State.State_bits.RESET_BITS == 1)
      {
        disable();   //usb_irq.c
        break;  
      }
      if (bD13flags.bits.suspend)
      {
        disable();   //usb_irq.c
        bD13flags.bits.suspend= 0;
        enable();   //usb_irq.c
        suspend_change();   //MAINLOOP.c     
      } // Suspend Change Handler
      if (bD13flags.bits.DCP_state == USBFSM4DCP_SETUPPROC)
      {
        disable();   //usb_irq.c
        SetupToken_Handler();   //MAINLOOP.c
        enable();   //usb_irq.c
      } // Setup Token Handler 
      if ((bD13flags.bits.DCP_state == USBFSM4DCP_REQUESTPROC) && !ControlData.Abort)
      {
        disable();   //usb_irq.c
        bD13flags.bits.DCP_state = 0x00;
        DeviceRequest_Handler();   //MAINLOOP.c
        enable();   //usb_irq.c
      } // Device Request Handler
      usleep(1);
    }
  return  0;
}

