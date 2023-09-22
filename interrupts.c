#include "interrupts.h"
#include "serial.h"
#include "string.h"
#include "panic.h"

struct __attribute__((__packed__)) gate_descriptor {
  unsigned int offset_lo : 16;
  unsigned int segment_selector : 16;
  unsigned int : 5;
  unsigned int zero_0 : 3;
  unsigned int gate_type : 4;
  unsigned int zero_1 : 1;
  unsigned int dpl : 2;
  unsigned int p : 1;
  unsigned int offset_hi : 16;
};

struct __attribute__((__packed__)) idt_descriptor {
  unsigned int size_minus_one : 16;
  struct gate_descriptor* offset;
};

#define IDT_SIZE 256
static struct gate_descriptor idt[IDT_SIZE];

/* the interrupt attribute will return using iret instead of ret */
__attribute__((interrupt))
static void division_by_zero(void *p)
{
  serial_puts("division by zero");
  panic();
}

__attribute__((interrupt))
static void invalid_opcode(void *p)
{
  serial_puts("invalid opcode");
  panic();
}

__attribute__((interrupt))
static void no_handler(void *p)
{
  serial_puts("unhandled interrupt");
  panic();
}

static void register_interrupt_handler(int vector, void* handler) {
  struct gate_descriptor gd;
  gd.offset_lo = (unsigned int)handler & 0xFFFF;
  gd.segment_selector = 0x8;
  gd.zero_0 = 0;
  gd.gate_type = 0xe; /* 0xe = 1110, interrupt gate */
  gd.zero_1 = 0;
  gd.dpl = 0;
  gd.p = 1;
  gd.offset_hi = ((unsigned int)handler & 0xFFFF0000) >> 16;

  idt[vector] = gd;
}

void register_interrupts() {
  for (int i = 0; i < IDT_SIZE; i++) {
    register_interrupt_handler(i, &no_handler);
    
  }
  register_interrupt_handler(0, &division_by_zero);
  register_interrupt_handler(6, &invalid_opcode);
  
  struct idt_descriptor idtd;
  idtd.size_minus_one = sizeof(idt) - 1;
  idtd.offset = idt;

  asm("lidt %0" : : "m" (idtd));
  serial_puts("register_interrupts() done");
}
