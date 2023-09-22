#include "serial.h"
#include "panic.h"
#include "interrupts.h"
#include "string.h"

void invalid_reference() {
  asm("int $6");
}

__attribute__ ((section (".text_start")))
void start()  {
  /* stack pointer is unchanged since real mode... */
  char buf[10];
  serial_init();
  serial_puts("namn: ");
  char *end = serial_getline(buf, 9);
  *end = '\0';
  serial_puts("hej ");
  serial_puts(buf);

  register_interrupts();
  invalid_reference();
  panic();
}

