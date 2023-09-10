OUTPUT_FORMAT("binary")
SECTIONS
{
  text 0x7c00 :
  {
  pbr.o(.text)
  }
  data 0x7dfe :
  {
  eopbr.o(.data)
  }
}
