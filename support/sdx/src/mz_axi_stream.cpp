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
** File Name:           mz_axi_stream.cpp
**
** Tool versions:       Vivado 2017.4
**
** Description:         MiniZed AXI-Stream Example Header File
**
** Revision:            Feb 25, 2018: 1.00 Initial version
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
  uint32_t        flush_flag;
  float           read_time;

  /*
  ** Allocate DDR buffers - use sds_alloc to ensure they are contiguous
  */
  for( int i = 0; i < NUM_BUFFERS; i++ )
  {
    ps_buffer[i] = (uint32_t *)sds_alloc( BUFFER_DEPTH * sizeof(uint32_t) );
  }

  /*
  ** Allocate stream buffer - not really necessary since the stream buffer is in
  ** programmable logic, but defined here for totality.
  */
  input_stream = (uint32_t *)sds_alloc( BUFFER_DEPTH * sizeof(uint32_t) );

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
    cout << init_value << endl;

    cout << "Please select a counter increment value between 1 and 1023" << endl;
    cin  >> increment;
    cout << increment << endl;

    cout << "Please select a counter update rate between 1 and 1023" << endl;
    cout << "  1 = 75 MHz update, 2 = 37.5 MHz update, ... , 1023 = 73.314 KHz update" << endl;
    cin  >> rate;
    cout << rate << endl;

    /*
    ** Setup the counter by
    **  1) disabling it
    **  2) clearing it
    **  3) setting rate, increment, and initial value registers
    **  4) enabling it
    */
    cout << "Disabling Counter" << endl;
    counter.disable();

    cout << "Clearing Counter" << endl;
    counter.clear();

    cout << "Configuring Counter" << endl;
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
      /* buffer should be full, perform read to clear */
      cout << "Flushing buffer" << endl;
      flush_flag = 1;
      read_stream(input_stream, init_value, 0, ps_buffer[0]);

      /* Enable counter and set flush flag to clear any remaining data in the interface logic */
      cout << "Enabling Counter" << endl;
      counter.enable();
    }
    else
    {
      cout << "Enabling Counter" << endl;
      first_run = false;
      flush_flag = 0;
      counter.enable();
    }

    /*
    ** Read the input data stream and copy to buffers allocated in DDR memory
    */
    cycles = sds_clock_counter();

    read_stream(input_stream, init_value, flush_flag, ps_buffer[0]);

    for( int i = 1; i < NUM_BUFFERS; i++ )
    {
      read_stream(input_stream, init_value, 0, ps_buffer[i]);
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
      cout << "There was " << buff_stats.total_errors << " error detected in the buffer." << endl;
    }
    else
    {
      cout << "There were " << buff_stats.total_errors << " errors detected in the buffer." << endl;
    }

    if ( (buff_stats.total_errors > 0) || (PRINT_DEBUG == 1) )
    {
      lf_print_debug( ps_buffer, buff_stats, increment, BUFFER_DEPTH, NUM_BUFFERS );
    }

    cout << endl << "Would you like to run a new test [y or n]?" << endl;
    cin  >> run_again;
    cout << run_again << endl;

    /*
    ** Terminate the program and release memory
    */
    if (!strcmp(&run_again[0], "n"))
    {
      cout << "Terminating program" << endl;

      for (int i = 0; i < NUM_BUFFERS; i++)
      {
        sds_free(ps_buffer[i]);
      }

      sds_free(input_stream);

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
