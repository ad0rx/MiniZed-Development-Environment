#include "uio_shim.h"

#define DEFAULT_WIDTH     4

int uio_shim_init (struct uio_shim_t* uio_shim,
		const char* dev_path,
		size_t length) {

	// Initialize the shim object
	uio_shim->dev_path = dev_path;
	uio_shim->length   = length;

  uio_shim->fd = open(uio_shim->dev_path, O_RDWR|O_SYNC);
  if (uio_shim->fd < 1) {
    perror("uioctl");
    fprintf(stderr, "Couldn't open UIO device file: %s\n", uio_shim->dev_path);
    return EXIT_FAILURE;
  }

  uio_shim->ptr = mmap(NULL, uio_shim->length, PROT_READ|PROT_WRITE, MAP_SHARED, uio_shim->fd, 0);
  if (uio_shim->ptr == MAP_FAILED) {
    perror("mmap");
    fprintf(stderr, "Couldn't mmap.\n");
    return EXIT_FAILURE;
  }

  uio_shim->is_inited = 1;

  return EXIT_SUCCESS;
}

int uio_shim_free (struct uio_shim_t* uio_shim)
{
  munmap (uio_shim->ptr, uio_shim->length);
  close (uio_shim->fd);
  return EXIT_SUCCESS;
}

int uio_shim_read (struct uio_shim_t* uio_shim, uint32_t offset, uint32_t* read_data)
{
  *read_data = *((unsigned*)(((uint32_t*) uio_shim->ptr) + (offset/DEFAULT_WIDTH)));
  return EXIT_SUCCESS;
}

int uio_shim_write (struct uio_shim_t* uio_shim, uint32_t offset, uint32_t write_data)
{

  *((unsigned*)(((uint32_t*) uio_shim->ptr) + (offset/DEFAULT_WIDTH))) = write_data;
  return EXIT_SUCCESS;
}

void uio_shim_display (struct uio_shim_t* uio_shim)
{
  printf ("dev_path : %s\n", uio_shim->dev_path);
  printf ("is_inited: %d\n", uio_shim->is_inited);
  printf ("length   : %d\n", uio_shim->length);
  printf ("fd       : %d\n", uio_shim->fd);
  printf ("ptr      : %p\n", uio_shim->ptr);

  return;
}
