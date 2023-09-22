#include "string.h"

static char digit_to_char(int digit) {
  return digit < 10 ? '0' + digit : 'a' + (digit-10);
}

size_t str_uint32(int base, uint32_t value, char* buf, size_t max_len)
{
  char rev[sizeof(uint32_t)*8];
  char* rev_p = rev;
  uint32_t x = value;
  do {
    int rest = x % base;
    *rev_p++ = digit_to_char(rest);
  } while ((x = x / base) > 0);
  
  char* cur = buf;
  while (rev_p > rev &&
	 cur < buf + max_len) {
    *cur++ = *--rev_p;
  }

  return cur - buf;
}
