NOTE: AVR Code addresses are word addresses
All other addresses (including ones in FLASH) are byte addresses

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                             lit   0054   03C0 =    960. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       0054  _TEXT35
       0054  __lit_start
       0234  _FONT
       0333  _FONT2
       0414  __lit_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                           idata   0414   0012 =     18. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       0414  __idata_start
       0426  __idata_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            text   0426   0EC8 =   3784. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       0213  __text_start
       0213  __start
       0233  _exit
       0234  _glcd_line
       02CB  _glcd_rect
       031E  _glcd_bar
       0490  _glcd_circle
       054C  _glcd_text35
       05E5  _glcd_text57
       06B7  _LCD_DataWrite
       06CB  _LCD_RegWrite
       06DF  _LCD_Fill
       06FD  _glcd_init
       071F  _glcd_update
       0769  _glcd_pixel
       0805  _glcd_fillScreen
       083B  _port_init
       0845  _init_devices
       084D  _main
       08D2  _abs
       08D8  push_arg4
       08DA  push_arg2
       08DD  mod16s
       08E1  div16s
       08FB  mod16u
       08FD  div16u
       08FE  xdiv16u
       0917  mod8u
       0919  div8u
       091A  xdiv8u
       092F  empy16s
       093F  pop_gset2
       0942  pop_gset3
       0945  pop_gset4
       0948  pop_gset5
       094B  push_gset5
       094D  push_gset4
       094F  push_gset3
       0951  push_gset2
       0953  push_gset1
       0956  pop_gset1
       0957  pop
       096A  lsl16
       0971  lsl8
       0977  __text_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            data   0060   0012 =     18. bytes (rel,con,ram)

       Addr  Global Symbol
      -----  --------------------------------
       0060  __data_start
       0072  __data_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                             bss   0072   0201 =    513. bytes (rel,con,ram)

       Addr  Global Symbol
      -----  --------------------------------
       0072  __bss_start
       0072  _LCD_Buffer
       0272  _glcdhalf
       0273  __bss_end

Area                               Start  End    Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                          vector   0000   0004 =      4. bytes (abs,ovr,rom)

Files Linked      [ module(s) ]

C:\icc\lib\crtatmega.o	[ crtatmega.s ]
myGRAPHICS.o	[ myGRAPHICS.C ]
mzl05.o	[ mzl05.c ]
main.o	[ main.c ]
<library>	[ abs.s, asave.s, div16s.s, div16u.s, div8u.s, emul16s.s, gpop2.s, gpop3.s, gpop4.s, gpop5.s, gpush.s, lsl16.s ]
[ lsl8.s ]

User Global Definitions

ram_end = 0x45f
hwstk_size = 0x20

User Base Address Definitions

func_lit = 0x54
data = 0x60
eeprom:1.512

