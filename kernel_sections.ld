OUTPUT_FORMAT("binary")
SECTIONS
{
  text 0x10000 :
  {
  kernel.o(.text)
  }
  data :
  {
  eok.o(.data)
  }
}
