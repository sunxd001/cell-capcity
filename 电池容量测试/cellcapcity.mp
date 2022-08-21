NOTE: AVR Code addresses are word addresses
All other addresses (including ones in FLASH) are byte addresses

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                             lit   0054   03FE =   1022. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       0054  __lit_start
       0080  _TEXT35
       0260  _FONT
       035F  _FONT2
       0452  __lit_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                           idata   0452   0023 =     35. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       0452  __idata_start
       0475  __idata_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            text   0476   22EC =   8940. bytes (rel,con,rom)

       Addr  Global Symbol
      -----  --------------------------------
       023B  __text_start
       023B  __start
       025B  _exit
       025C  _port_init
       0269  _int0_isr
       0288  _int1_isr
       02AD  _timer0_init
       02B4  _ADInit
       02C5  _timer0_ovf_isr
       08B1  _init_devices
       0925  _main
       092C  _glcd_line
       09C3  _glcd_rect
       0A16  _glcd_bar
       0B88  _glcd_circle
       0C44  _glcd_text35
       0CDD  _glcd_text57
       0DAF  _LCD_DataWrite
       0DC3  _LCD_RegWrite
       0DD7  _LCD_Fill
       0DF5  _glcd_init
       0E17  _glcd_update
       0E61  _glcd_pixel
       0EFD  _glcd_fillScreen
       0F33  _Num2Str
       0F5E  _num_pow
       0F74  _Float2Str
       1095  _abs
       109B  push_arg4
       109D  push_arg2
       10A0  mod16s
       10A4  div16s
       10BE  mod16u
       10C0  div16u
       10C1  xdiv16u
       10DA  mod8u
       10DC  div8u
       10DD  xdiv8u
       10F2  empy16s
       1102  pop_gset2
       1105  pop_gset3
       1108  pop_gset4
       110B  pop_gset5
       110E  push_gset5
       1110  push_gset4
       1112  push_gset3
       1114  push_gset2
       1116  push_gset1
       1119  pop_gset1
       111A  pop
       112D  neg32
       1136  lpm32
       114A  push_lset
       1161  pop_lset
       1178  lsl16
       117F  lsl8
       1185  fp2int
       118E  nojump1
       1193  fp2long
       119A  nojump2
       119C  FTOI
       119E  FTOL
       11CD  int2fp
       11D3  long2fp
       11D8  ITOF
       11EC  itof2
       11EE  itof3
       11FD  save_floatregs
       1208  restore_floatregs
       1213  stk2arg1
       1218  stk2arg0
       121D  float_epilog
       1224  float_prolog
       1227  add32fs
       122A  add32f
       122F  sub32fs
       1232  sub32f
       1237  fret2
       123E  FSUB
       123F  FADD
       1284  usub24
       1288  div32fs
       128B  div32f
       12AC  fdiv10
       12B1  FDIV
       12E5  cmp32f
       12EA  FLTCP
       1316  empy32fs
       1319  empy32f
       1322  eFMUL
       133A  eumul24
       1363  savfacc1
       1366  restorefacc1
       1369  unpackfacc1
       1372  negmant
       1378  maxres
       137F  minres
       1385  ac1toac2
       138B  swapacc
       1397  unpack
       13A9  repack
       13B1  __text_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                            data   0060   0023 =     35. bytes (rel,con,ram)

       Addr  Global Symbol
      -----  --------------------------------
       0060  _adcnoloadvalue
       0060  __data_start
       0062  _adcloadvalue
       0064  _firststart
       0065  _rotate_key
       0066  _rotate_code
       0067  _rotate_dir
       0068  _stopvalue
       006A  _adccap
       0083  __data_end

Area                               Addr   Size   Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                             bss   0083   02A5 =    677. bytes (rel,con,ram)

       Addr  Global Symbol
      -----  --------------------------------
       0083  _i
       0083  __bss_start
       0085  _adccurvcount
       0086  _adccurv
       0106  _pcap
       010A  _cap
       010E  _res
       0112  _secondcount
       0114  _second
       0115  _minute
       0116  _hour
       0117  _adcbuffer
       011F  _adcfloat
       0123  _adc
       0125  _count
       0127  _LCD_Buffer
       0327  _glcdhalf
       0328  __bss_end

Area                               Start  End    Decimal Bytes (Attributes)
--------------------------------   ----   ----   ------- ----- ------------
                          vector   0000   0028 =     40. bytes (abs,ovr,rom)

Files Linked      [ module(s) ]

C:\icc\lib\crtatmega.o	[ crtatmega.s ]
main.o	[ main.c ]
myGRAPHICS.o	[ myGRAPHICS.C ]
mzl05.o	[ mzl05.c ]
num2str.o	[ num2str.c ]
<library>	[ abs.s, asave.s, div16s.s, div16u.s, div8u.s, emul16s.s, gpop2.s, gpop3.s, gpop4.s, gpop5.s, gpush.s, lneg.s ]
[ lpm32.s, lpush.s, lsl16.s, lsl8.s, fp2int.s, fpint2fp.s, fputil.s, fpadd.s, fpdiv.s, fpcmp.s, fpemul.s ]
[ fputil2.s, fputil3.s ]

User Global Definitions

ram_end = 0x45f
hwstk_size = 0x30

User Base Address Definitions

func_lit = 0x54
data = 0x60
eeprom:1.512

