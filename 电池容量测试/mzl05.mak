CC = iccavr
CFLAGS =  -IC:\icc\include\ -e -DATMEGA -DATMega16  -l -g -Mavr_enhanced 
ASFLAGS = $(CFLAGS)  -Wa-g
LFLAGS =  -LC:\icc\lib\ -g -ucrtatmega.o -bfunc_lit:0x54.0x4000 -dram_end:0x45f -bdata:0x60.0x45f -dhwstk_size:32 -beeprom:1.512 -fihx_coff -S2
FILES = myGRAPHICS.o mzl05.o main.o 

mzl05:	$(FILES)
	$(CC) -o mzl05 $(LFLAGS) @mzl05.lk   -llpatmega -lcatmega
myGRAPHICS.o: C:/icc/include/math.h E:\avr\iccavrproject\mzl0512864/mzl05.h E:\avr\iccavrproject\mzl0512864/myGRAPHICS.h
myGRAPHICS.o:	E:\avr\iccavrproject\mzl0512864\myGRAPHICS.C
	$(CC) -c $(CFLAGS) E:\avr\iccavrproject\mzl0512864\myGRAPHICS.C
mzl05.o: C:/icc/include/iom16v.h E:\avr\iccavrproject\mzl0512864/mzl05.h
mzl05.o:	E:\avr\iccavrproject\mzl0512864\mzl05.c
	$(CC) -c $(CFLAGS) E:\avr\iccavrproject\mzl0512864\mzl05.c
main.o: C:/icc/include/iom16v.h C:/icc/include/macros.h E:\avr\iccavrproject\mzl0512864/mzl05.h E:\avr\iccavrproject\mzl0512864/myGRAPHICS.h
main.o:	E:\avr\iccavrproject\mzl0512864\main.c
	$(CC) -c $(CFLAGS) E:\avr\iccavrproject\mzl0512864\main.c
