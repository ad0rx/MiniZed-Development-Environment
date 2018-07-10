/*----------------------------------------------------------------------------
**      _____
**     *     *
**    *____   *____
**   * *===*   *==*
**  *___*===*___**  AVNET
**       *======*
**        *====*
**----------------------------------------------------------------------------
**
** This design is the property of Avnet.  Publication of this
** design is not authorized without written consent from Avnet.
**
** Disclaimer:
**    Avnet, Inc. makes no warranty for the use of this code or design.
**    This code is provided  "As Is". Avnet, Inc assumes no responsibility for
**    any errors, which may appear in this code, nor does it make a commitment
**    to update the information contained herein. Avnet, Inc specifically
**    disclaims any implied warranties of fitness for a particular purpose.
**
**                     Copyright(c) 2018 Avnet, Inc.
**                             All rights reserved.
**
**----------------------------------------------------------------------------
**
** Create Date:         Feb 25, 2018
** File Name:           counter_control.h
**
** Tool versions:       Vivado 2017.4
**
** Description:         Programmable counter driver
**
** Revision:            Feb 25, 2018: 1.00 Initial version
**                      Jul 09, 2018: 1.10 Updated for use with Linux O/S
**
**----------------------------------------------------------------------------*/

#ifndef COUNTER_CONTROL_H_
#define COUNTER_CONTROL_H_

#include <iostream>
#include "stdint.h"

extern "C" {
  #include "uio_shim.h"
}

using namespace std;

/*
** +--------------------------------------------------------------------------------------------------------------+
** | REGISTER DESCRIPTION                                                                                         |
** |--------------------------------------------------------------------------------------------------------------|
** | REGISTER     | REGISTER NAME         | DESCRIPTION                                                           |
** |--------------+-----------------------+-----------------------------------------------------------------------|
** | COUNT_CLEAR  | Clear                 | Clears the counter, write 1 then 0 to clear and release               |
** |--------------+-----------------------+-----------------------------------------------------------------------|
** | COUNT_ENABLE | Enable                | Enables the counter, write 1 to enable and 0 to disable               |
** |--------------+-----------------------+-----------------------------------------------------------------------|
** | COUNT_UPDATE | Update Parameters     | Writing a 1 to this register causes the increment, rate, and initial  |
** |              |                       | values to get updated.  Must be set to 0 after writing a 1            |
** |--------------+-----------------------+-----------------------------------------------------------------------|
** | COUNT_INCR   | Increment Value       | 10-bit counter increment.  Setting to 1 causes the count to increment |
** |              |                       | by 1, setting it to 2 causes the count to increment by 2, etc.        |
** |--------------+-----------------------+-----------------------------------------------------------------------|
** | COUNT_RATE   | Count Rate            | 10-bit counter rate register.  Sets the counter update rate. A value  |
** |              |                       | 1 sets the rate to 75 MHz, 2 = 37.5 MHz ... 1023 = 73.33 KHz.         |
** |--------------+-----------------------+-----------------------------------------------------------------------|
** | COUNT_INIT   | Initial Counter Value |  32-bit initial value                                                 |
** +--------------------------------------------------------------------------------------------------------------+
*/

#define COUNTER_BASE   0x43C00000 /* Counter Base Address           */
#define COUNTER_CLEAR  0x00000000 /* Clear register                 */
#define COUNTER_ENABLE 0x00000004 /* Enable register                */
#define COUNTER_UPDATE 0x00000008 /* Update Parameters register     */
#define COUNTER_INCR   0x0000000C /* Increment Value register       */
#define COUNTER_RATE   0x00000010 /* Count Rate register            */
#define COUNTER_INIT   0x00000014 /* Initial Counter Value register */

#define COUNTER_DEV_PATH "/dev/uio0" /* Counter device path */

class counter_control
{

  struct uio_shim_t* uio_shim;

  public :

    /* Default Constructor */
    counter_control() : uio_shim(0)
    {
      /* Allocate memory for the shim object */
      uio_shim = (struct uio_shim_t*) calloc(1, sizeof(struct uio_shim_t));

      if (!uio_shim)
      {
        printf("Failed to allocate memory for uio_shim\n");
        exit(1);
      }

      /* Initialize the uio_shim driver and uio_shim object */
      if (uio_shim_init(uio_shim, COUNTER_DEV_PATH, 0x10000u))
      {
        printf("Failed to initaialize uio_shim driver\n");
        exit(1);
      }

    } /* end constructor */

    /* Destructor */
    ~counter_control()
    {
      if (uio_shim->is_inited)
      {
        uio_shim_free(uio_shim);
      }
    } /* end destructor */

    /*******************************************************************************
    ** Function    : clear
    ** Description : Clears the counter
    **------------------------------------------------------------------------------
    ** Return Value:
    **   None
    *******************************************************************************/
    inline void clear()
    {
      uio_shim_write(uio_shim, COUNTER_CLEAR, 1);
      uio_shim_write(uio_shim, COUNTER_CLEAR, 0);
    }

    /*******************************************************************************
    ** Function    : disable
    ** Description : Disables the counter
    **------------------------------------------------------------------------------
    ** Return Value:
    **   None
    *******************************************************************************/
    inline void disable()
    {
      uio_shim_write(uio_shim, COUNTER_ENABLE, 0);
    }

    /*******************************************************************************
    ** Function    : enable
    ** Description : Enables the counter
    **------------------------------------------------------------------------------
    ** Return Value:
    **   None
    *******************************************************************************/
    inline void enable()
    {
      uio_shim_write(uio_shim, COUNTER_ENABLE, 1);
    }

    /*******************************************************************************
    ** Function    : config
    ** Description : Configures the counter
    **------------------------------------------------------------------------------
    ** Parameter:            Description:
    ** [I ] p_count_incr     Counter increment value
    ** [I ] p_count_rate     Counter update rate
    ** [I ] p_init_value     Initial counter value
    **------------------------------------------------------------------------------
    ** Return Value:
    **   success (bool) - true when configuration parameters fall within valid range
    **                    false when parameters are outside of valid range
    *******************************************************************************/
    inline bool config(uint32_t p_count_incr, uint32_t p_count_rate, uint32_t p_init_val)
    {
      bool success = true;
      uint32_t count_incr_q = p_count_incr;
      uint32_t count_rate_q = p_count_rate;

      /* range check input parameters */
      if ( (p_count_incr == 0) || (p_count_incr >= 1024) ||
           (p_count_rate == 0) || (p_count_rate >= 1024) )
      {
        success = false;
      }

      /* use default values */
      if (!success)
      {
        count_incr_q = 1;
        count_rate_q = 2;
      }

      uio_shim_write(uio_shim, COUNTER_INCR, count_incr_q);
      uio_shim_write(uio_shim, COUNTER_RATE, count_rate_q);
      uio_shim_write(uio_shim, COUNTER_INIT, p_init_val);
      uio_shim_write(uio_shim, COUNTER_UPDATE, 1);
      uio_shim_write(uio_shim, COUNTER_UPDATE, 0);

      return success;
    }

};

#endif /* COUNTER_CONTROL_H_ */
