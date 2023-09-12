#include "serial.h"
#include "panic.h"

#define SERIAL_PORT 0x3f8
#define SERIAL_PORT_DATA (SERIAL_PORT + 0)
#define SERIAL_PORT_INT_ENABLE (SERIAL_PORT + 1)
#define SERIAL_PORT_BAUD_LO (SERIAL_PORT + 0)
#define SERIAL_PORT_BAUD_HI (SERIAL_PORT + 1)
#define SERIAL_PORT_INT_ID (SERIAL_PORT + 2)
#define SERIAL_PORT_LCR (SERIAL_PORT + 3)
#define SERIAL_PORT_MCR (SERIAL_PORT + 4)
#define SERIAL_PORT_LSR (SERIAL_PORT + 5)
#define SERIAL_PORT_MSR (SERIAL_PORT + 6)

static void outb(short port, char byte) {
  asm ("outb %0, %1\n"
       : : "a" (byte), "d" (port));
}

static char inb(short port) {
  char byte;
  asm ("inb %1, %0\n"
       : "=a" (byte) : "d" (port));
  return byte;
}

void serial_init() {
  // Disable interrupts
  outb(SERIAL_PORT_INT_ENABLE, 0);

  // Set baud rate to max
  outb(SERIAL_PORT_LCR, 0x80);
  outb(SERIAL_PORT_BAUD_LO, 1);
  outb(SERIAL_PORT_BAUD_HI, 0);

  // Set 8N1
  outb(SERIAL_PORT_LCR, 0x03);

  // Not sure what this does
  outb(SERIAL_PORT_MCR, 0x0F);
}

void serial_putc(char byte) {
  while (1) {
    char lsr = inb(SERIAL_PORT_LSR);
    if (lsr & 0xe == 0) {
      panic();
    }
    else if (lsr & 0x20) {
      outb(SERIAL_PORT_DATA, byte);
      return;
    }
  }
}

void serial_puts(const char* str) {
  while(*str != '\0') {
    serial_putc(*str++);
  }
}

char serial_getc() {
  while (1) {
    char lsr = inb(SERIAL_PORT_LSR);
    if (lsr & 0xe == 0) {
      panic();
    }
    else if (lsr & 0x1) {
      return inb(SERIAL_PORT_DATA);
    }
  }
}

char* serial_getline(char* buf, int len) {
  const char *end = buf + len;
  char c = '\0';
  while(buf != end && c != '\n') {
    c =serial_getc();
    *buf++ = c;
  }
  return buf;
}
