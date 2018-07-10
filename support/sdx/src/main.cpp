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
** File Name:           main.cpp
**
** Tool versions:       Vivado 2017.4
**
** Description:         Main program for MiniZed AXI-Stream example project
**
** Revision:            Feb 25, 2018: 1.00 Initial version
**
**----------------------------------------------------------------------------*/

#include <iostream>
#include "mz_header.h"

int main()
{
  mz_axi_stream();
  std::cout << "Program execution complete" << std::endl;
  return 0;
}