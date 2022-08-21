CC = iccavr
CFLAGS =  -IC:\icc\include\ -e -DATMEGA -DATMega16  -l -g -Mavr_enhanced 
ASFLAGS = $(CFLAGS)  -Wa-g
LFLAGS =  -LC:\icc\lib\ -g -ucrtatmega.o -bfunc_lit:0x54.0x4000 -dram_end:0x45f -bdata:0x60.0x45f -dhwstk_size:48 -beeprom:1.512 -fihx_coff -S2
FILES = main.o myGRAPHICS.o mzl05.o num2str.o 

cellcapcity:	$(FILES)
	$(CC) -o cellcapcity $(LFLAGS) @cellcapcity.lk   -llpatmega -lcatmega
main.o: C:/icc/include/iom16v.h C:/icc/include/macros.h C:/icc/include/eeprom.h E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘/num2str.h E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘/mzl05.h E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘/myGRAPHICS.h
main.o:	E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘\main.c
	$(CC) -c $(CFLAGS) E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘\main.c
myGRAPHICS.o: C:/icc/include/math.h E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘/mzl05.h E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘/myGRAPHICS.h
myGRAPHICS.o:	E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘\myGRAPHICS.C
	$(CC) -c $(CFLAGS) E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘\myGRAPHICS.C
mzl05.o: C:/icc/include/iom16v.h E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘/mzl05.h
mzl05.o:	E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘\mzl05.c
	$(CC) -c $(CFLAGS) E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘\mzl05.c
num2str.o: E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘/num2str.h
num2str.o:	E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘\num2str.c
	$(CC) -c $(CFLAGS) E:\avr\iccavrproject\µÁ≥ÿ»›¡ø≤‚ ‘\num2str.c
