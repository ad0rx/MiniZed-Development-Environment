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
** File Name:           mz_axi_stream.cpp
**
** Tool versions:       Vivado 2017.4
**
** Description:         MiniZed AXI-Stream Example Header File
**
** Revision:            Feb 25, 2018: 1.00 Initial version
**                      Jul 09, 2018: 1.10 Updated to use non-blocking HW
**                                         function calls
**
**----------------------------------------------------------------------------*/

#include <iostream>
#include <limits>
#include "stdint.h"
#include "sds_lib.h"
#include "mz_header.h"
#include "counter_control.h"
#include <string.h>

using namespace std;

#define PRINT_DEBUG 0

/*
** Local Function Prototypes
*/
void lf_check_buffer( uint32_t **p_buffer,
                      uint32_t   p_count_incr,
                      uint32_t   p_num_buffers,
                      uint32_t   p_buffer_depth,
                      stats_t   *p_buff_stats );

void lf_print_debug( uint32_t **p_buffer,
                     stats_t    p_buff_stats,
                     uint32_t   p_count_incr,
                     uint32_t   p_buffer_depth,
                     uint32_t   p_num_buffers );


/*
** MiniZed AXI-Stream function that configures a PL counter using AXI-Lite and
** pulls data from an AXI-Stream Data FIFO.
*/
void mz_axi_stream()
{
  /*
  ** Define pointers to the input data stream and the memory in DDR where the
  ** streaming input data will get stuffed.
  */
  uint32_t *input_stream;
  uint32_t *ps_buffer[NUM_BUFFERS];

  /*
  ** Create the counter controller
  */
  bool            first_run = true;
  char            run_again[2];
  uint32_t        init_value;
  uint32_t        increment;
  uint32_t        rate;
  counter_control counter;
  bool            success;
  stats_t         buff_stats;
  uint64_t        cycles;
  float           read_time;

  /*
  ** Allocate DDR buffers - use sds_alloc to ensure they are contiguous
  */
  for( int i = 0; i < NUM_BUFFERS; i++ )
  {
    ps_buffer[i] = (uint32_t *)sds_alloc( BUFFER_DEPTH * sizeof(uint32_t) );
  }

  /*
  ** Allocate stream buffer - not necessary since the stream buffer is in
  ** programmable logic, so just set to NULL.
  */
  input_stream = NULL;

  /*
  ** Program loop
  */
  while(1)
  {
    /*
    ** Get user inputs
    */
    cout << "Please select the initial counter value between 0 and 2147483647" << endl;
    cin  >> init_value;

    cout << "Please select a counter increment value between 1 and 1023" << endl;
    cin  >> increment;

    cout << "Please select a counter update rate between 1 and 1023" << endl;
    cout << "  1 = 75 MHz update, 2 = 37.5 MHz update, ... , 1023 = 73.314 KHz update" << endl;
    cin  >> rate;

    /*
    ** Setup the counter by
    **  1) disabling it
    **  2) clearing it
    **  3) setting rate, increment, and initial value registers
    **  4) enabling it
    */
    cout << "Disabling counter" << endl;
    counter.disable();

    cout << "Clearing counter" << endl;
    counter.clear();

    cout << "Configuring counter" << endl;
    success = counter.config( increment, rate, init_value );

    if (!success)
    {
      cout << "ERROR: Counter not configured correctly, using default values" << endl;
      cout << "  rate = 2 (37.5 MHz), increment = 1" << endl;
      increment = 1;
      rate      = 2;
    }

    /*
    ** If this is not the first time we've run the test then the PL buffer needs
    ** to get flushed of old data.
    */
    if (!first_run)
    {
      /*
      ** buffer should be full (plus additional 1026 words for data movement logic),
      ** perform read to clear
      */
      cout << "Flushing buffer" << endl;
      read_stream(input_stream, ps_buffer[0], BUFFER_DEPTH+DM_DEPTH);
    }
    else
    {
      first_run = false;
    }

    /*
    ** Read the input data stream and copy to buffers allocated in DDR memory.
    ** Kick off the HW function before enabling the counter in order to make sure
    ** data can be read from the stream buffer as soon as it is available.
    */
#pragma SDS async(1)
    read_stream(input_stream, ps_buffer[0], BUFFER_DEPTH);

    /* Enable the counter */
    cout << "Enabling counter" << endl;
    counter.enable();

    cycles = sds_clock_counter();

    for( int i = 1; i < NUM_BUFFERS; i++ )
    {
#pragma SDS async(1)
      read_stream(input_stream, ps_buffer[i], BUFFER_DEPTH);
    }

    for (int i = 0; i < NUM_BUFFERS; i++)
    {
#pragma SDS wait(1)
    }

    cycles = sds_clock_counter() - cycles;

    read_time = (float)cycles / (float)(sds_clock_frequency()) * 1.0e6f;
    cout << "It took " << read_time << " microseconds to read " << NUM_BUFFERS*BUFFER_DEPTH << " samples" << endl;

    /*
    ** Check the buffers for discontinuity
    */
    lf_check_buffer(  ps_buffer,
                      increment,
                      NUM_BUFFERS,
                      BUFFER_DEPTH,
                     &buff_stats );

    if (buff_stats.total_errors == 1)
    {
      cout << "There was 1 error detected in the buffer." << endl;
    }
    else
    {
      cout << "There were " << buff_stats.total_errors << " errors detected in the buffer." << endl;
    }

    if ( (buff_stats.total_errors > 0) || (PRINT_DEBUG == 1) )
    {
      lf_print_debug( ps_buffer, buff_stats, increment, BUFFER_DEPTH, NUM_BUFFERS );
    }

    /*
    ** Query the user to see if they want to run the test again.
    */
    while (1)
    {
      cout << endl << "Would you like to run a new test [y or n]?" << endl;
      cin  >> run_again;

      if (!strcmp(&run_again[0], "n") || !strcmp(&run_again[0], "y"))
      {
        break;
      }
      else
      {
        cout << "Input " << run_again << " not recognized, valid inputs are y or n." << endl;
      }
    }

    /*
    ** Terminate the program and release memory
    */
    if (!strcmp(&run_again[0], "n"))
    {
      cout << "Disabling counter" << endl;
      counter.disable();

      cout << "Flushing buffer" << endl;
      read_stream(input_stream, ps_buffer[0], BUFFER_DEPTH+DM_DEPTH);

      cout << "Terminating program" << endl;

      for (int i = 0; i < NUM_BUFFERS; i++)
      {
        sds_free(ps_buffer[i]);
      }

      break;
    }
  }
}

/*******************************************************************************
** Function    : lf_check_buffer
** Description : Local function to check the buffer continuity.
**               Counts the number of errors found in the buffer and outputs
**               that in the p_buffer_errors variable.
**------------------------------------------------------------------------------
** Parameter:            Description:
** [I ] p_buffer         Input buffer
** [I ] p_count_incr     Counter increment factor
** [I ] p_num_buffers    Number of buffers
** [I ] p_buffer_depth   Buffer depth in samples
** [ O] p_buff_stats     Buffer error statistics
**------------------------------------------------------------------------------
** Return Value:
**   None
*******************************************************************************/
void lf_check_buffer( uint32_t **p_buffer,
                      uint32_t   p_count_incr,
                      uint32_t   p_num_buffers,
                      uint32_t   p_buffer_depth,
                      stats_t   *p_buff_stats )
{

  uint32_t prev_sample = 0;
  int      error_found;

  p_buff_stats->total_errors = 0;

  for (uint32_t i = 0; i < p_num_buffers; i ++)
  {
    p_buff_stats->buff_errors[i] = 0;

    for (uint32_t k = 0; k < p_buffer_depth; k++)
    {
      if ((i == 0) && (k == 0))
      {
        prev_sample = p_buffer[i][k];
      }
      else
      {
        error_found = ((p_buffer[i][k] - prev_sample) != p_count_incr);
        p_buff_stats->total_errors += error_found;
        p_buff_stats->buff_errors[i] += error_found;
        prev_sample = p_buffer[i][k];
      }
    }
  }
}

/*******************************************************************************
** Function    : lf_print_debug
** Description : Local function to print buffer debug information
**------------------------------------------------------------------------------
** Parameter:            Description:
** [I ] p_buffer         Input buffer
** [I ] p_buff_stats     Buffer error statistics
** [I ] p_count_incr     Counter increment factor
** [I ] p_num_buffers    Number of buffers
** [I ] p_buffer_depth   Buffer depth in samples
**------------------------------------------------------------------------------
** Return Value:
**   None
*******************************************************************************/
void lf_print_debug( uint32_t **p_buffer,
                     stats_t    p_buff_stats,
                     uint32_t   p_count_incr,
                     uint32_t   p_buffer_depth,
                     uint32_t   p_num_buffers )

{
  for (uint32_t i = 0; i < p_num_buffers; i++)
  {
    cout << "  Buffer " << i << ":" << endl;
    cout << "    First sample         = " << p_buffer[i][0] << endl;
    cout << "    Last sample          = " << p_buffer[i][p_buffer_depth-1] << endl;
    cout << "    Increment            = " << p_count_incr << endl;
    cout << "    Buffer depth         = " << p_buffer_depth << endl;
    cout << "    Expected last sample = " << p_buffer[i][0] + p_count_incr*(p_buffer_depth - 1) << endl;
    cout << "    Error count          = " << p_buff_stats.buff_errors[i] << endl;
  }

}
