OUTPUT_FORMAT("binary")
SECTIONS
{
  text 0x10000 :
  {
  *(.text_start)
  *(.text)
  *(.rodata)
  }
  data :
  {
  *(.data)
  *(.bss)
  eok.o(.eok)
  }
}
