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
                  uint32_t  p_init_value,
                  uint32_t  p_flush,
                  uint32_t *p_buffer )
{
#pragma HLS dataflow

  /*
  ** Variables
  */
  int      c;                      /* Local counter */
  bool     init_found;             /* Initial value found flag */
  uint32_t l_flush;                /* Local copy of p_flush input flag */
  uint32_t l_init_value;           /* Local copy of p_init_value input */
  uint32_t l_buffer[BUFFER_DEPTH]; /* Local buffer for storing data */
  uint32_t temp;                   /* Temp variable */

  /*
  ** Initialize variables
  */
  c            = 0;
  init_found   = false;
  l_flush      = p_flush;
  l_init_value = p_init_value;

  /*
  ** Read data from the PL FIFO and copy to local memory.  If we are flushing
  ** the data-path then look for the first sample value and throw away values
  ** that do not match.  After a match is found start copying every sample
  ** from the PL FIFO.
  */
  for (int i = 0; i < 2*BUFFER_DEPTH; i++)
  {
#pragma HLS pipeline
#pragma HLS loop_tripcount max=8192

    if (c == BUFFER_DEPTH)
    {
      break;
    }

    if (l_flush == 0)
    {
      l_buffer[c] = *p_stream;
      c++;
    }
    else
    {
      if (init_found)
      {
        l_buffer[c] = *p_stream;
        c++;
      }
      else
      {
        temp = *p_stream;

        if (temp == l_init_value)
        {
          init_found = true;
          l_buffer[c] = temp;
          c++;
        }
      }
    }
  }

  /*
  ** Copy data from local-buffer to output
  */
  for (int i = 0; i < BUFFER_DEPTH; i++)
  {
#pragma HLS pipeline
#pragma HLS loop_tripcount max=4096
    p_buffer[i] = l_buffer[i];
  }

}