#ifndef UIO_SHIM_H
#define UIO_SHIM_H

#include <errno.h>
#include <getopt.h>
#include <inttypes.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/timeb.h>

struct uio_shim_t {

  // Filesystem Path e.g. /dev/uio0
  const char* dev_path;

  // Set to 1 after initialization
  uint32_t is_inited;

  // Length of address space used in mmap call
  size_t length;

  // File descriptor for opening dev_path
  int fd;

  // Pointer to mmap-ed memory
  void* ptr;

};


int uio_shim_init (struct uio_shim_t* uio_shim);
int uio_shim_free (struct uio_shim_t* uio_shim);

int uio_shim_read (struct uio_shim_t* uio_shim, uint32_t offset, uint32_t* read_data);
int uio_shim_write (struct uio_shim_t* uio_shim, uint32_t offset, uint32_t write_data);

void uio_shim_display (struct uio_shim_t* uio_shim);

#endif
