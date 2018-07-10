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
** File Name:           read_stream.cpp
**
** Tool versions:       Vivado 2017.4
**
** Description:         Hardware accelerator "shunt" that connects to an AXI
**                      stream data FIFO in programmable logic and allows direct
**                      access by SDSoC application.
**
** Revision:            Feb 25, 2018: 1.00 Initial version
**                      Jul 09, 2018: 1.10 Updated to read a variable amount of
**                                         data from the stream buffer
**
**----------------------------------------------------------------------------*/

#include <iostream>
#include "stdint.h"
#include "mz_header.h"

/*******************************************************************************
** Function    : read_stream
** Description : Reads data from a PL buffer
**------------------------------------------------------------------------------
** Parameter:            Description:
** [I ] p_stream         Input buffer
** [I ] p_init_value     Inital value from data stream
** [I ] p_flush          Flag indicating that the data stream should be flushed
** [ O] p_buffer         Output buffer
**------------------------------------------------------------------------------
** Return Value:
**   None
*******************************************************************************/
void read_stream( uint32_t *p_stream,
                  uint32_t *p_buffer,
                  uint32_t  p_samples)
{
#pragma HLS dataflow

  /*
  ** Variables
  */
  uint32_t temp; /* Temp variable */

  /*
  ** Read data from the PL FIFO and write to memory pointed to by p_buffer input.
  */
  for (uint32_t i = 0; i < p_samples; i++)
  {
#pragma HLS pipeline
#pragma HLS loop_tripcount min=4096 max=5122
    temp = *p_stream;
    p_buffer[i] = temp;
  }

}
