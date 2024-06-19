/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
//#include <termios.h>
//#include <sys/ioctl.h>
#include "xil_io.h"
#include "xparameters.h"
#include "xgpio.h"

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xbasic_types.h"
#include "xparameters.h"


Xuint32 *baseaddr_p = (Xuint32 *)XPAR_IMGGEN3_0_S00_AXI_BASEADDR;
Xuint32 *gpio = (Xuint32 *)XPAR_AXI_GPIO_0_BASEADDR;


int main()
{
    init_platform();


    while(1) {

    	if (*(gpio+1) == 2) {
    		*(baseaddr_p+2) = 0;
    	} else {
    		*(baseaddr_p+2) = 1;
    	}


		if (*gpio == 2) {
			if(*baseaddr_p < 470) {
				usleep(20000);
				*baseaddr_p = (*baseaddr_p) + 10;
			}


		} else if (*gpio == 1) {
			if (*baseaddr_p > 49) {
				usleep(20000);
				*baseaddr_p = (*baseaddr_p) - 10;
			}
		}

		if (*gpio == 8) {
			if(*(baseaddr_p+1) < 470) {
				usleep(20000);
				*(baseaddr_p+1) = *(baseaddr_p+1) + 10;
			}


		} else if (*gpio == 4) {
			if(*(baseaddr_p+1) > 49) {
				usleep(20000);
				*(baseaddr_p+1) = *(baseaddr_p+1) - 10;
			}

		}


    }

    cleanup_platform();
    return 0;
}


