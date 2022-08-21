	.module num2str.c
	.area text(rom, con, rel)
	.dbfile E:\avr\iccavrproject\µç³ØÈÝÁ¿²âÊÔ\num2str.c
	.dbfunc e Num2Str _Num2Str fV
;              i -> R20
;            len -> R22
;            Num -> R10,R11
;            str -> R12,R13
	.even
_Num2Str::
	xcall push_gset4
	movw R10,R18
	movw R12,R16
	ldd R22,y+8
	.dbline -1
	.dbline 4
; #include "num2str.h"
; 
; void Num2Str(unsigned char str[],int Num,unsigned char len)
; {
	.dbline 5
;    unsigned char i=0;
	clr R20
	xjmp L3
L2:
	.dbline 6
	.dbline 7
	ldi R18,10
	ldi R19,0
	movw R16,R10
	xcall mod16s
	movw R24,R16
	adiw R24,48
	mov R30,R22
	clr R31
	add R30,R12
	adc R31,R13
	std z+0,R24
	.dbline 8
	ldi R18,10
	ldi R19,0
	movw R16,R10
	xcall div16s
	movw R10,R16
	.dbline 9
	inc R20
	.dbline 10
L3:
	.dbline 6
;    while(len--){
	mov R2,R22
	clr R3
	subi R22,1
	tst R2
	brne L2
	.dbline 11
;      str[len]=Num%10+0x30;
;      Num=Num/10;
;      i++;
;    }
;    str[i++]='\0';
	mov R2,R20
	clr R3
	subi R20,255    ; addi 1
	mov R30,R2
	clr R31
	add R30,R12
	adc R31,R13
	clr R2
	std z+0,R2
	.dbline -2
L1:
	xcall pop_gset4
	.dbline 0 ; func end
	ret
	.dbsym r i 20 c
	.dbsym r len 22 c
	.dbsym r Num 10 I
	.dbsym r str 12 pc
	.dbend
	.dbfunc e num_pow _num_pow fi
;         result -> R20,R21
;              n -> R22
;              m -> R10
	.even
_num_pow::
	xcall push_gset3
	mov R22,R18
	mov R10,R16
	.dbline -1
	.dbline 15
; }
; 
; unsigned int num_pow(unsigned char m,unsigned char n)
; {
	.dbline 16
;   unsigned int result=1;
	ldi R20,1
	ldi R21,0
	xjmp L7
L6:
	.dbline 17
	mov R18,R10
	clr R19
	movw R16,R20
	xcall empy16s
	movw R20,R16
L7:
	.dbline 17
;   while(n--)result*=m;
	mov R2,R22
	clr R3
	subi R22,1
	tst R2
	brne L6
	.dbline 18
;   return result;
	movw R16,R20
	.dbline -2
L5:
	xcall pop_gset3
	.dbline 0 ; func end
	ret
	.dbsym r result 20 i
	.dbsym r n 22 c
	.dbsym r m 10 c
	.dbend
	.dbfunc e Float2Str _Float2Str fV
;              j -> R20
;              i -> R22
;        xiaoshu -> R10,R11
;       zhengshu -> R12,R13
;           len2 -> R8
;           len1 -> y+20
;           floa -> y+16
;            str -> y+14
	.even
_Float2Str::
	xcall push_arg4
	xcall push_gset5
	sbiw R28,4
	ldd R8,y+22
	.dbline -1
	.dbline 22
; }
; 
; void Float2Str(unsigned char str[],float floa,unsigned char len1,unsigned char len2)
; {
	.dbline 23
;    unsigned char i=0,j=0;
	clr R22
	.dbline 23
	clr R20
	.dbline 24
;    unsigned int zhengshu=floa;
	movw R30,R28
	ldd R2,z+16
	ldd R3,z+17
	ldd R4,z+18
	ldd R5,z+19
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	ldi R16,<L12
	ldi R17,>L12
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall cmp32f
	brlt L10
	movw R30,R28
	ldd R2,z+16
	ldd R3,z+17
	ldd R4,z+18
	ldd R5,z+19
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	ldi R16,<L12
	ldi R17,>L12
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall sub32f
	xcall fp2int
	movw R24,R16
	subi R24,0  ; offset = 32768
	sbci R25,128
	movw R10,R24
	xjmp L11
L10:
	movw R30,R28
	ldd R16,z+16
	ldd R17,z+17
	ldd R18,z+18
	ldd R19,z+19
	xcall fp2int
	movw R10,R16
L11:
	movw R12,R10
	.dbline 25
;    unsigned int xiaoshu=(floa-zhengshu)*num_pow(10,len2);
	mov R18,R8
	ldi R16,10
	push R18
	xcall _num_pow
	pop R8
	movw R2,R16
	movw R30,R28
	ldd R4,z+16
	ldd R5,z+17
	ldd R6,z+18
	ldd R7,z+19
	st -y,R7
	st -y,R6
	st -y,R5
	st -y,R4
	ldi R16,<L15
	ldi R17,>L15
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	movw R16,R12
	lsr R17
	ror R16
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall empy32fs
	movw R16,R12
	andi R16,1
	andi R17,0
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall add32fs
	xcall sub32fs
	ldi R16,<L15
	ldi R17,>L15
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	movw R16,R2
	lsr R17
	ror R16
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall empy32fs
	movw R16,R2
	andi R16,1
	andi R17,0
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall add32fs
	xcall empy32f
	movw R30,R28
	std z+0,R16
	std z+1,R17
	std z+2,R18
	std z+3,R19
	movw R30,R28
	ldd R2,z+0
	ldd R3,z+1
	ldd R4,z+2
	ldd R5,z+3
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	ldi R16,<L12
	ldi R17,>L12
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall cmp32f
	brlt L13
	movw R30,R28
	ldd R2,z+0
	ldd R3,z+1
	ldd R4,z+2
	ldd R5,z+3
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	ldi R16,<L12
	ldi R17,>L12
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall sub32f
	xcall fp2int
	movw R24,R16
	subi R24,0  ; offset = 32768
	sbci R25,128
	movw R14,R24
	xjmp L14
L13:
	movw R30,R28
	ldd R16,z+0
	ldd R17,z+1
	ldd R18,z+2
	ldd R19,z+3
	xcall fp2int
	movw R14,R16
L14:
	movw R10,R14
	xjmp L17
L16:
	.dbline 26
	.dbline 27
	ldi R18,10
	ldi R19,0
	movw R16,R12
	xcall mod16u
	movw R24,R16
	adiw R24,48
	ldd R30,y+20
	clr R31
	ldd R0,y+14
	ldd R1,y+15
	add R30,R0
	adc R31,R1
	std z+0,R24
	.dbline 28
	ldi R18,10
	ldi R19,0
	movw R16,R12
	xcall div16u
	movw R12,R16
	.dbline 29
	inc R22
	.dbline 30
L17:
	.dbline 26
;    while(len1--){
	ldd R2,y+20
	clr R3
	mov R24,R2
	subi R24,1
	std y+20,R24
	tst R2
	brne L16
	.dbline 31
;      str[len1]=zhengshu%10+0x30;
;      zhengshu=zhengshu/10;
;      i++;
;    }
;    str[i]='.';
	mov R30,R22
	clr R31
	ldd R0,y+14
	ldd R1,y+15
	add R30,R0
	adc R31,R1
	ldi R24,46
	std z+0,R24
	xjmp L20
L19:
	.dbline 33
	.dbline 34
	mov R2,R8
	clr R3
	mov R30,R22
	clr R31
	add R30,R2
	adc R31,R3
	ldd R0,y+14
	ldd R1,y+15
	add R30,R0
	adc R31,R1
	ldi R18,10
	ldi R19,0
	movw R16,R10
	xcall mod16u
	movw R24,R16
	adiw R24,48
	std z+1,R24
	.dbline 35
	ldi R18,10
	ldi R19,0
	movw R16,R10
	xcall div16u
	movw R10,R16
	.dbline 36
	inc R20
	.dbline 37
L20:
	.dbline 32
;    while(len2--)
	mov R2,R8
	clr R3
	mov R24,R2
	subi R24,1
	mov R8,R24
	tst R2
	brne L19
	.dbline 38
;    {
;      str[i+len2+1]=xiaoshu%10+0x30;
;      xiaoshu=xiaoshu/10;
;      j++;
;    }
;    str[i+j+1]='\0';
	mov R2,R20
	clr R3
	mov R30,R22
	clr R31
	add R30,R2
	adc R31,R3
	ldd R0,y+14
	ldd R1,y+15
	add R30,R0
	adc R31,R1
	clr R2
	std z+1,R2
	.dbline -2
L9:
	adiw R28,4
	xcall pop_gset5
	adiw R28,4
	.dbline 0 ; func end
	ret
	.dbsym r j 20 c
	.dbsym r i 22 c
	.dbsym r xiaoshu 10 i
	.dbsym r zhengshu 12 i
	.dbsym r len2 8 c
	.dbsym l len1 20 c
	.dbsym l floa 16 D
	.dbsym l str 14 pc
	.dbend
	.area lit(rom, con, rel)
L15:
	.word 0x0,0x4000
L12:
	.word 0x0,0x4700
