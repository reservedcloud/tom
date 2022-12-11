ENTRY(_entry)

SECTIONS
{
  . = 0x7E00;

  .text ALIGN(4K):
  {
    *(.text)
    *(.rodata*)
    *(.data)
    _bss_begin = (. + 4095) & (~ 4095); /* 4K align */
  }

  .bss ALIGN(4K):
  {
    *(COMMON)
    *(.bss)
    _bss_end = (. + 4095) & (~ 4095); /* 4K align */
  }
}