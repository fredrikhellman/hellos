#pragma once

/**
 * Initialize serial port COM1 at baud rate 115200. No interrupts.
 */
void serial_init();

/**
 * Put character to serial port.
 */
void serial_putc(char byte);

/**
 * Put null-terminated string to serial port.
 */
void serial_puts(const char* str);

/**
 * Get character from serial port.
 */
char serial_getc();

/**
 * Get line from serial port. Reads characters until len characters
 * have been read or '\n' has been read, whichver occurs first.
 *
 * buf     Buffer
 * len     Maximum length to read
 * return  Pointer to character after the last read character.
 */
char* serial_getline(char* buf, int len);
