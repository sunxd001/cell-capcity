	.module main.c
	.area data(ram, con, rel)
_adcnoloadvalue::
	.blkb 2
	.area idata
	.word 0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbsym e adcnoloadvalue _adcnoloadvalue I
_adcloadvalue::
	.blkb 2
	.area idata
	.word 0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbsym e adcloadvalue _adcloadvalue I
_firststart::
	.blkb 1
	.area idata
	.byte 0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbsym e firststart _firststart c
_rotate_key::
	.blkb 1
	.area idata
	.byte 0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbsym e rotate_key _rotate_key c
_rotate_code::
	.blkb 1
	.area idata
	.byte 0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbsym e rotate_code _rotate_code c
_rotate_dir::
	.blkb 1
	.area idata
	.byte 0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbsym e rotate_dir _rotate_dir c
_stopvalue::
	.blkb 2
	.area idata
	.word 512
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbsym e stopvalue _stopvalue i
_adccap::
	.blkb 2
	.area idata
	.word 0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbsym e adccap _adccap i
	.area text(rom, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbfunc e port_init _port_init fV
	.even
_port_init::
	.dbline -1
	.dbline 55
; //DIY低成本电池容量测试仪，测试原理：测试有负载与无负载间的电压差，
; //通过已知外部电阻计算电池内阻。通过每隔一秒测一下电压，通过已知外部放电电阻计算电流
; //累积计算毫安时
; //电源为USB5V
; //12864接PORTC，* 0: SDI  1: SCK  2: A0  3: RS  4: CS1 
; //12864     面向正面gnd|VCC|SDI|SCK|A0|RES|CS1,CS1标的1脚
; //电池接PORTA 0，通过1K+1K分压接入AD，AD参考源为内部2.56V参考源，PORTA置为AD转换器，可同时测8路电池  
; //电池通过6.8水泥电阻放电
; //继电器接PORTD 7，用于控制电池放电启停
; //旋转编码器K关接INT 0，PORTD 2,用于操作放电启停
; //旋转编码器A接INT 1，PORTD 3，B接PORT D 4，用于调整放电截止电压，
; //注意施转编码器各脚需接104电容到地，通过510电阻到各脚
; //开发平台ICCAVR 6.31A，使用了num2str-数字转字符串,mygraphic-抽象图形库,mzl05-针对铭正同创mzl05-12864的硬件层接口
; // Target : M16
; // Crystal: 8M外部晶振
; 
; //发现问题，AD接地仍有电压，可能电AREF没有外接电容，好象不是，PORTA=0x00后解决，但比万用表高0.1
; 
; #include <iom16v.h>
; #include <macros.h>
; #include <eeprom.h>
; #include "num2str.h"
; #include "mzl05.h"
; #include "myGRAPHICS.h"
; extern char glcdhalf;//由于M16内存局限每次只刷新半个屏幕
; int count;//timer0计数
; 
; int adc;//ADC转换结果
; float adcfloat;//ADC转换结的浮点表示
; int adcnoloadvalue=0,adcloadvalue=0;//无载电压与有载电压，用于计算内阻
; unsigned char firststart=0;//第一次进入有载
; 
; unsigned char adcbuffer[8];//ADC字符串结果 
; 
; unsigned char rotate_key=0;//旋转编码器开关状态
; unsigned char rotate_code=0;//PIND,用于判断旋转方向
; unsigned char rotate_dir=0;//旋转编码器方向
; 
; unsigned char hour,minute,second;
; unsigned int secondcount;
; 
; unsigned int stopvalue=512;//停止放电电压
; //unsigned char tempunsignedchar;
; 
; float res;//电池内阻
; 
; float cap;//电池容量
; unsigned int adccap=0;//电池容量整数表示
; float pcap;//以功率计算容量
; 
; unsigned char adccurv[128];//放电电压曲线，每分钟一记，可记2小时
; unsigned char adccurvcount;
; unsigned int i;
; void port_init(void)
; {
	.dbline 56
;  	PORTA = 0x00;
	clr R2
	out 0x1b,R2
	.dbline 57
;  	DDRA  = 0x00;
	out 0x1a,R2
	.dbline 58
;  	PORTB = 0xFF;
	ldi R24,255
	out 0x18,R24
	.dbline 59
;  	DDRB  = 0xFF;
	out 0x17,R24
	.dbline 60
;  	PORTC = 0xFF;
	out 0x15,R24
	.dbline 61
;  	DDRC  = 0xFF;
	out 0x14,R24
	.dbline 62
;  	PORTD = 0x7F;
	ldi R24,127
	out 0x12,R24
	.dbline 63
; 	DDRD  = 0x80;//PORTD PIN7为继电器控制
	ldi R24,128
	out 0x11,R24
	.dbline -2
L1:
	.dbline 0 ; func end
	ret
	.dbend
	.area vector(rom, abs)
	.org 4
	jmp _int0_isr
	.area text(rom, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbfunc e int0_isr _int0_isr fV
	.even
_int0_isr::
	st -y,R2
	st -y,R24
	in R2,0x3f
	st -y,R2
	.dbline -1
	.dbline 68
; }
; //外部中断0
; #pragma interrupt_handler int0_isr:2
; void int0_isr(void)
; {
	.dbline 69
;   if(rotate_key==0){//未放电状态
	lds R2,_rotate_key
	tst R2
	brne L3
	.dbline 69
	.dbline 70
;     PORTD |=1<<7;   //关闭常开触点，开始放电
	sbi 0x12,7
	.dbline 71
; 	rotate_key=1;   //记录标志
	ldi R24,1
	sts _rotate_key,R24
	.dbline 72
; 	hour=minute=second=0;  //初始化计时器
	clr R2
	sts _second,R2
	sts _minute,R2
	sts _hour,R2
	.dbline 73
; 	firststart=1;   //第一次进入放电状态
	sts _firststart,R24
	.dbline 74
	xjmp L4
L3:
	.dbline 74
	.dbline 75
	cbi 0x12,7
	.dbline 76
	clr R2
	sts _rotate_key,R2
	.dbline 77
L4:
	.dbline -2
L2:
	ld R2,y+
	out 0x3f,R2
	ld R24,y+
	ld R2,y+
	.dbline 0 ; func end
	reti
	.dbend
	.area vector(rom, abs)
	.org 8
	jmp _int1_isr
	.area text(rom, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbfunc e int1_isr _int1_isr fV
	.even
_int1_isr::
	st -y,R2
	st -y,R24
	st -y,R25
	in R2,0x3f
	st -y,R2
	.dbline -1
	.dbline 83
;   }else{
;     PORTD &=~(1<<7); //断开继电器
; 	rotate_key=0;    //记录标志
;   }
; }
; //外部中断1
; //在旋转编码器A相下降沿查看B相电平，如果是高++
; #pragma interrupt_handler int1_isr:3
; void int1_isr(void)
; { 
	.dbline 84
;   rotate_code=PIND;  
	in R2,0x10
	sts _rotate_code,R2
	.dbline 85
;   if((rotate_code & 0x10) == 0x10){
	mov R24,R2
	andi R24,16
	cpi R24,16
	brne L6
	.dbline 85
	.dbline 86
;     stopvalue++;	
	lds R24,_stopvalue
	lds R25,_stopvalue+1
	adiw R24,1
	sts _stopvalue+1,R25
	sts _stopvalue,R24
	.dbline 87
	xjmp L7
L6:
	.dbline 87
	.dbline 88
	lds R24,_stopvalue
	lds R25,_stopvalue+1
	sbiw R24,1
	sts _stopvalue+1,R25
	sts _stopvalue,R24
	.dbline 89
L7:
	.dbline -2
L5:
	ld R2,y+
	out 0x3f,R2
	ld R25,y+
	ld R24,y+
	ld R2,y+
	.dbline 0 ; func end
	reti
	.dbend
	.dbfunc e timer0_init _timer0_init fV
	.even
_timer0_init::
	.dbline -1
	.dbline 97
;   }else{
;     stopvalue--;    
;   }
;   //tempunsignedchar=stopvalue % 256;
;   //EEPROMwrite(1,tempunsignedchar);
;   //tempunsignedchar=stopvalue / 256;
;   //EEPROMwrite(2,tempunsignedchar);
; }
; 
; void timer0_init(void) //定时器初始化程序
; {
	.dbline 98
; TCCR0 = 0x00; //停止定时器
	clr R2
	out 0x33,R2
	.dbline 100
; //TCNT0 = 0x3A; //设置初始值,75us，合计0.075X256=20ms//3A好用，计算值44
; TCNT0=0xCF;//75us/4
	ldi R24,207
	out 0x32,R24
	.dbline 101
; TCCR0 = 0x02; //开动定时器,可能是主频/8
	ldi R24,2
	out 0x33,R24
	.dbline -2
L8:
	.dbline 0 ; func end
	ret
	.dbend
	.dbfunc e ADInit _ADInit fV
	.even
_ADInit::
	.dbline -1
	.dbline 104
; }
; void ADInit(void)
; {
	.dbline 105
;     ADMUX|=(1<<REFS1)|(1<<REFS0);  //选择内部2.56V为ADC的参考电压
	in R24,0x7
	ori R24,192
	out 0x7,R24
	.dbline 106
;     ADMUX&=~(1<<ADLAR);  //转换结果右对齐
	cbi 0x7,5
	.dbline 107
; 	ADMUX&=~(1<<MUX4);
	cbi 0x7,4
	.dbline 108
; 	ADMUX&=~(1<<MUX3);
	cbi 0x7,3
	.dbline 109
; 	ADMUX&=~(1<<MUX2);
	cbi 0x7,2
	.dbline 110
; 	ADMUX&=~(1<<MUX1);
	cbi 0x7,1
	.dbline 111
; 	ADMUX&=~(1<<MUX0);        //选择通道ADC0
	cbi 0x7,0
	.dbline 112
; 	ADCSRA|=(1<<ADPS2)|(1<<ADPS0);
	in R24,0x6
	ori R24,5
	out 0x6,R24
	.dbline 113
; 	ADCSRA&=~(1<<ADPS1);  //时钟分频系数为64
	cbi 0x6,1
	.dbline 114
; 	ADCSRA|=(1<<ADEN);//使能AD
	sbi 0x6,7
	.dbline 115
; 	ADCSRA&=~(1<<ADATE);//不自动转换
	cbi 0x6,5
	.dbline 116
; 	ADCSRA&=~(1<<ADIE);//禁用AD中断
	cbi 0x6,3
	.dbline -2
L9:
	.dbline 0 ; func end
	ret
	.dbend
	.area vector(rom, abs)
	.org 36
	jmp _timer0_ovf_isr
	.area text(rom, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.dbfunc e timer0_ovf_isr _timer0_ovf_isr fV
	.even
_timer0_ovf_isr::
	xcall push_lset
	sbiw R28,9
	.dbline -1
	.dbline 120
; }
; #pragma interrupt_handler timer0_ovf_isr:10 
; void timer0_ovf_isr(void) //定时器溢出中断程序,大约49*8机器周期中断一次
; {
	.dbline 122
;   //TCNT0 = 0x3A; //从新调入初始值
;   TCNT0=0xCF;
	ldi R24,207
	out 0x32,R24
	.dbline 123
;   secondcount++;
	lds R24,_secondcount
	lds R25,_secondcount+1
	adiw R24,1
	sts _secondcount+1,R25
	sts _secondcount,R24
	.dbline 124
;   if(rotate_key==1)//如果开始测量容量，记时，开始计算容量
	lds R24,_rotate_key
	cpi R24,1
	breq X0
	xjmp L11
X0:
	.dbline 125
;   if(secondcount>10933){//大约一秒，可能还要调一下
	ldi R24,10933
	ldi R25,42
	lds R2,_secondcount
	lds R3,_secondcount+1
	cp R24,R2
	cpc R25,R3
	brlo X1
	xjmp L13
X1:
	.dbline 125
	.dbline 126
;     secondcount=0;
	clr R2
	clr R3
	sts _secondcount+1,R3
	sts _secondcount,R2
	.dbline 127
; 	second++;
	lds R24,_second
	subi R24,255    ; addi 1
	sts _second,R24
	.dbline 128
; 	if(second>59){
	ldi R24,59
	lds R2,_second
	cp R24,R2
	brsh L15
	.dbline 128
	.dbline 129
; 	  second=0;minute++;
	clr R2
	sts _second,R2
	.dbline 129
	lds R24,_minute
	subi R24,255    ; addi 1
	sts _minute,R24
	.dbline 130
; 	  if(minute % 2 == 0){ //两分钟记录一次，最多记256分钟，4小时16分
	ldi R17,2
	mov R16,R24
	xcall mod8u
	tst R16
	brne L17
	.dbline 130
	.dbline 131
; 	    adccurv[adccurvcount]=63-(unsigned char)(adccap/16);
	lds R2,_adccap
	lds R3,_adccap+1
	lsr R3
	ror R2
	lsr R3
	ror R2
	lsr R3
	ror R2
	lsr R3
	ror R2
	ldi R24,63
	sub R24,R2
	ldi R30,<_adccurv
	ldi R31,>_adccurv
	lds R26,_adccurvcount
	clr R27
	add R26,R30
	adc R27,R31
	st x,R24
	.dbline 132
; 	    adccurvcount++;
	lds R24,_adccurvcount
	subi R24,255    ; addi 1
	sts _adccurvcount,R24
	.dbline 133
; 		if(adccurvcount>127)adccurvcount=127;
	ldi R24,127
	lds R2,_adccurvcount
	cp R24,R2
	brsh L19
	.dbline 133
	sts _adccurvcount,R24
L19:
	.dbline 134
; 	  }	
L17:
	.dbline 135
; 	}
L15:
	.dbline 136
; 	if(minute>59){
	ldi R24,59
	lds R2,_minute
	cp R24,R2
	brsh L21
	.dbline 136
	.dbline 137
; 	  minute=0;hour++;
	clr R2
	sts _minute,R2
	.dbline 137
	lds R24,_hour
	subi R24,255    ; addi 1
	sts _hour,R24
	.dbline 138
; 	}
L21:
	.dbline 140
; 	//adccap来自前一次测试时的电压，电压/电阻等于电流，每一秒累加电流*时间等于mAh
; 	cap+=(((float)adccap*2.0*2.56*1000.0)/1024.0)/6.8; //ma,计算mAs
	lds R4,_cap+2
	lds R5,_cap+2+1
	lds R2,_cap
	lds R3,_cap+1
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	ldi R16,<L23
	ldi R17,>L23
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	ldi R16,<L24
	ldi R17,>L24
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	ldi R16,<L25
	ldi R17,>L25
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	ldi R16,<L26
	ldi R17,>L26
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	lds R16,_adccap
	lds R17,_adccap+1
	lsr R17
	ror R16
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall empy32fs
	lds R16,_adccap
	lds R17,_adccap+1
	andi R16,1
	andi R17,0
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall add32fs
	xcall empy32fs
	xcall empy32fs
	xcall empy32fs
	ldi R16,<L27
	ldi R17,>L27
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32fs
	ldi R16,<L28
	ldi R17,>L28
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32fs
	xcall add32f
	sts _cap+1,R17
	sts _cap,R16
	sts _cap+2+1,R19
	sts _cap+2,R18
	.dbline 141
; 	pcap+=(((float)adccap*2.0*2.56*100.0)/1024.0)*(((float)adccap*2.0*2.56*10.0)/1024.0)/6.8; //ma,计算mWs      
	ldi R16,<L24
	ldi R17,>L24
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	ldi R16,<L25
	ldi R17,>L25
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	ldi R16,<L26
	ldi R17,>L26
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	lds R16,_adccap
	lds R17,_adccap+1
	lsr R17
	ror R16
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall empy32fs
	lds R16,_adccap
	lds R17,_adccap+1
	andi R16,1
	andi R17,0
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall add32fs
	xcall empy32fs
	xcall empy32f
	movw R30,R28
	std z+5,R16
	std z+6,R17
	std z+7,R18
	std z+8,R19
	lds R4,_pcap+2
	lds R5,_pcap+2+1
	lds R2,_pcap
	lds R3,_pcap+1
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	ldi R16,<L29
	ldi R17,>L29
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	movw R30,R28
 ; stack offset 8
	ldd R2,z+13
	ldd R3,z+14
	ldd R4,z+15
	ldd R5,z+16
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	xcall empy32fs
	ldi R16,<L27
	ldi R17,>L27
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32fs
	ldi R16,<L30
	ldi R17,>L30
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	movw R30,R28
 ; stack offset 12
	ldd R2,z+17
	ldd R3,z+18
	ldd R4,z+19
	ldd R5,z+20
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	xcall empy32fs
	ldi R16,<L27
	ldi R17,>L27
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32fs
	xcall empy32fs
	ldi R16,<L28
	ldi R17,>L28
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32fs
	xcall add32f
	sts _pcap+1,R17
	sts _pcap,R16
	sts _pcap+2+1,R19
	sts _pcap+2,R18
	.dbline 144
; 	//cap=(((adccap*2.0*2.56/1024.0)/6.8)*1000.0)  //ma
; 	//    *(hour+minute/60.0+second/3600.0);//hour
;   }
L13:
L11:
	.dbline 145
;   count++; //每中断一次加1
	lds R24,_count
	lds R25,_count+1
	adiw R24,1
	sts _count+1,R25
	sts _count,R24
	.dbline 146
;   if (count>4096) //需要估算时间
	ldi R24,4096
	ldi R25,16
	lds R2,_count
	lds R3,_count+1
	cp R24,R2
	cpc R25,R3
	brlt X2
	xjmp L31
X2:
	.dbline 147
;   { //AD转换
	.dbline 149
;     
; 	ADCSRA|=(1<<ADSC);  //启动一次AD转换
	sbi 0x6,6
L33:
	.dbline 150
	.dbline 151
L34:
	.dbline 150
; 	while(!(ADCSRA &(1<<ADIF))){
	sbis 0x6,4
	rjmp L33
	.dbline 151
; 	};//ADIF 为1时表示AD转换完成
	.dbline 152
; 	adc=ADCL;
	in R2,0x4
	clr R3
	sts _adc+1,R3
	sts _adc,R2
	.dbline 153
; 	adc|=(int)(ADCH<<8);
	in R2,0x5
	clr R3
	mov R3,R2
	clr R2
	lds R4,_adc
	lds R5,_adc+1
	or R4,R2
	or R5,R3
	sts _adc+1,R5
	sts _adc,R4
	.dbline 154
; 	adccap=adc;//随时采集电压用于计算容量
	movw R2,R4
	sts _adccap+1,R3
	sts _adccap,R2
	.dbline 155
; 	ADCSRA|=(1<<ADIF);
	sbi 0x6,4
	.dbline 157
; 	//AD转换结束
; 	if(rotate_key==0)adcnoloadvalue=adc;
	lds R2,_rotate_key
	tst R2
	brne L36
	.dbline 157
	movw R2,R4
	sts _adcnoloadvalue+1,R3
	sts _adcnoloadvalue,R2
L36:
	.dbline 158
; 	if(rotate_key==1 && firststart==1){
	lds R24,_rotate_key
	cpi R24,1
	breq X3
	xjmp L38
X3:
	lds R24,_firststart
	cpi R24,1
	breq X4
	xjmp L38
X4:
	.dbline 158
	.dbline 159
; 	  firststart=0;
	clr R2
	sts _firststart,R2
	.dbline 160
; 	  adcloadvalue=adc;
	lds R2,_adc
	lds R3,_adc+1
	sts _adcloadvalue+1,R3
	sts _adcloadvalue,R2
	.dbline 162
; 	  //计算内阻,(无载电压-带载电压)/电流
; 	  res=(((adcnoloadvalue-adcloadvalue)*2.0*2.56)/1024.0)  //电压差
	ldi R16,<L24
	ldi R17,>L24
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	ldi R16,<L25
	ldi R17,>L25
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	lds R2,_adcloadvalue
	lds R3,_adcloadvalue+1
	lds R16,_adcnoloadvalue
	lds R17,_adcnoloadvalue+1
	sub R16,R2
	sbc R17,R3
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall empy32fs
	xcall empy32fs
	ldi R16,<L27
	ldi R17,>L27
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32fs
	ldi R16,<L24
	ldi R17,>L24
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	ldi R16,<L25
	ldi R17,>L25
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	lds R16,_adcloadvalue
	lds R17,_adcloadvalue+1
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall empy32fs
	xcall empy32fs
	ldi R16,<L27
	ldi R17,>L27
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32fs
	ldi R16,<L28
	ldi R17,>L28
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32fs
	xcall div32f
	sts _res+1,R17
	sts _res,R16
	sts _res+2+1,R19
	sts _res+2,R18
	.dbline 164
; 	      /((adcloadvalue*2.0*2.56/1024.0)/6.8);//电流，6.8为水泥电阻阻值
; 	  cap=0.0;//初始化容量
	ldi R16,<L40
	ldi R17,>L40
	xcall lpm32
	sts _cap+1,R17
	sts _cap,R16
	sts _cap+2+1,R19
	sts _cap+2,R18
	.dbline 165
; 	  pcap=0.0;	  
	ldi R16,<L40
	ldi R17,>L40
	xcall lpm32
	sts _pcap+1,R17
	sts _pcap,R16
	sts _pcap+2+1,R19
	sts _pcap+2,R18
	.dbline 166
	clr R2
	clr R3
	sts _i+1,R3
	sts _i,R2
	xjmp L44
L41:
	.dbline 166
	ldi R24,<_adccurv
	ldi R25,>_adccurv
	lds R30,_i
	lds R31,_i+1
	add R30,R24
	adc R31,R25
	clr R2
	std z+0,R2
L42:
	.dbline 166
	lds R24,_i
	lds R25,_i+1
	adiw R24,1
	sts _i+1,R25
	sts _i,R24
L44:
	.dbline 166
; 	  for(i=0;i<128;i++)adccurv[i]=0;//初始化曲线
	lds R24,_i
	lds R25,_i+1
	cpi R24,128
	ldi R30,0
	cpc R25,R30
	brlo L41
	.dbline 167
; 	  adccurvcount=0;
	clr R2
	sts _adccurvcount,R2
	.dbline 168
; 	}
L38:
	.dbline 170
; 	//如果电压低于终止电压，停计容量，断继电器
; 	if(adc<stopvalue && rotate_key==1){
	lds R2,_stopvalue
	lds R3,_stopvalue+1
	lds R4,_adc
	lds R5,_adc+1
	cp R4,R2
	cpc R5,R3
	brsh L45
	lds R24,_rotate_key
	cpi R24,1
	brne L45
	.dbline 170
	.dbline 171
; 	  PORTD &=~(1<<7);
	cbi 0x12,7
	.dbline 172
; 	  rotate_key=0;
	clr R2
	sts _rotate_key,R2
	.dbline 173
; 	}
L45:
	.dbline 174
; 	adcfloat=2.56*adc/1024.0;
	ldi R16,<L24
	ldi R17,>L24
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	lds R16,_adc
	lds R17,_adc+1
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall empy32fs
	ldi R16,<L27
	ldi R17,>L27
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32f
	sts _adcfloat+1,R17
	sts _adcfloat,R16
	sts _adcfloat+2+1,R19
	sts _adcfloat+2,R18
	.dbline 175
; 	adcfloat=adcfloat*2;//真实电路中电压被分压1/2
	ldi R16,<L47
	ldi R17,>L47
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	lds R4,_adcfloat+2
	lds R5,_adcfloat+2+1
	lds R2,_adcfloat
	lds R3,_adcfloat+1
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	xcall empy32f
	sts _adcfloat+1,R17
	sts _adcfloat,R16
	sts _adcfloat+2+1,R19
	sts _adcfloat+2,R18
	.dbline 177
; 	
; 	Float2Str(adcbuffer,adcfloat,1,3);//格式化成为字符串
	ldi R24,3
	std y+4,R24
	ldi R24,1
	std y+2,R24
	std y+0,R18
	std y+1,R19
	movw R18,R16
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Float2Str
	.dbline 179
; 	 
; 	glcdhalf=0;
	clr R2
	sts _glcdhalf,R2
	.dbline 180
; 	glcd_fillScreen(0);
	clr R16
	xcall _glcd_fillScreen
	.dbline 182
; 	//当前电压
; 	glcd_text57(2,2,adcbuffer,2,1);
	ldi R24,1
	std y+4,R24
	ldi R24,2
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,2
	ldi R16,2
	xcall _glcd_text57
	.dbline 184
; 	//是否开始，如果已经开始测容量显示stop
; 	if(rotate_key==1)
	lds R24,_rotate_key
	cpi R24,1
	brne L48
	.dbline 185
; 	  glcd_text57(96,2,"stop",1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L50
	ldi R25,>L50
	std y+1,R25
	std y+0,R24
	ldi R18,2
	ldi R16,96
	xcall _glcd_text57
	xjmp L49
L48:
	.dbline 187
; 	else
; 	  glcd_text57(96,2,"start",1,1);  
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L51
	ldi R25,>L51
	std y+1,R25
	std y+0,R24
	ldi R18,2
	ldi R16,96
	xcall _glcd_text57
L49:
	.dbline 189
;  	//时钟
; 	Num2Str(adcbuffer,hour,2);
	ldi R24,2
	std y+0,R24
	lds R18,_hour
	clr R19
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Num2Str
	.dbline 190
; 	glcd_text57(80,12,adcbuffer,1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,12
	ldi R16,80
	xcall _glcd_text57
	.dbline 191
; 	glcd_text57(92,12,":",1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L52
	ldi R25,>L52
	std y+1,R25
	std y+0,R24
	ldi R18,12
	ldi R16,92
	xcall _glcd_text57
	.dbline 192
; 	Num2Str(adcbuffer,minute,2);
	ldi R24,2
	std y+0,R24
	lds R18,_minute
	clr R19
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Num2Str
	.dbline 193
; 	glcd_text57(98,12,adcbuffer,1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,12
	ldi R16,98
	xcall _glcd_text57
	.dbline 194
; 	glcd_text57(110,12,":",1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L52
	ldi R25,>L52
	std y+1,R25
	std y+0,R24
	ldi R18,12
	ldi R16,110
	xcall _glcd_text57
	.dbline 195
; 	Num2Str(adcbuffer,second,2);
	ldi R24,2
	std y+0,R24
	lds R18,_second
	clr R19
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Num2Str
	.dbline 196
; 	glcd_text57(116,12,adcbuffer,1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,12
	ldi R16,116
	xcall _glcd_text57
	.dbline 199
; 	//时钟end
; 	//终止电压
; 	adcfloat=2.56*stopvalue/1024.0;
	ldi R16,<L24
	ldi R17,>L24
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	ldi R16,<L26
	ldi R17,>L26
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	lds R16,_stopvalue
	lds R17,_stopvalue+1
	lsr R17
	ror R16
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall empy32fs
	lds R16,_stopvalue
	lds R17,_stopvalue+1
	andi R16,1
	andi R17,0
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall add32fs
	xcall empy32fs
	ldi R16,<L27
	ldi R17,>L27
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32f
	sts _adcfloat+1,R17
	sts _adcfloat,R16
	sts _adcfloat+2+1,R19
	sts _adcfloat+2,R18
	.dbline 200
; 	adcfloat=adcfloat*2;//真实电路中电压被分压1/2
	ldi R16,<L47
	ldi R17,>L47
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	lds R4,_adcfloat+2
	lds R5,_adcfloat+2+1
	lds R2,_adcfloat
	lds R3,_adcfloat+1
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	xcall empy32f
	sts _adcfloat+1,R17
	sts _adcfloat,R16
	sts _adcfloat+2+1,R19
	sts _adcfloat+2,R18
	.dbline 201
; 	Float2Str(adcbuffer,adcfloat,1,3);
	ldi R24,3
	std y+4,R24
	ldi R24,1
	std y+2,R24
	std y+0,R18
	std y+1,R19
	movw R18,R16
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Float2Str
	.dbline 202
; 	glcd_text57(96,24,adcbuffer,1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,24
	ldi R16,96
	xcall _glcd_text57
	.dbline 205
; 	//终止电压end
; 	//内阻
; 	Float2Str(adcbuffer,res,1,3);
	ldi R24,3
	std y+4,R24
	ldi R24,1
	std y+2,R24
	lds R4,_res+2
	lds R5,_res+2+1
	lds R2,_res
	lds R3,_res+1
	std y+0,R4
	std y+1,R5
	movw R18,R2
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Float2Str
	.dbline 206
; 	glcd_text57(2,18,adcbuffer,2,1);
	ldi R24,1
	std y+4,R24
	ldi R24,2
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,18
	ldi R16,2
	xcall _glcd_text57
	.dbline 207
; 	glcd_text57(60,23,"R",1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L53
	ldi R25,>L53
	std y+1,R25
	std y+0,R24
	ldi R18,23
	ldi R16,60
	xcall _glcd_text57
	.dbline 210
; 	//内阻end
; 	//容量
; 	Float2Str(adcbuffer,cap/3600.0,5,1);
	ldi R24,1
	std y+4,R24
	ldi R24,5
	std y+2,R24
	lds R4,_cap+2
	lds R5,_cap+2+1
	lds R2,_cap
	lds R3,_cap+1
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	ldi R16,<L54
	ldi R17,>L54
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32f
	std y+0,R18
	std y+1,R19
	movw R18,R16
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Float2Str
	.dbline 211
; 	glcd_text57(2,34,adcbuffer,2,1);
	ldi R24,1
	std y+4,R24
	ldi R24,2
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,34
	ldi R16,2
	xcall _glcd_text57
	.dbline 212
; 	glcd_text57(80,39,"mAh",1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L55
	ldi R25,>L55
	std y+1,R25
	std y+0,R24
	ldi R18,39
	ldi R16,80
	xcall _glcd_text57
	.dbline 213
; 	Float2Str(adcbuffer,pcap/3600.0,5,1);
	ldi R24,1
	std y+4,R24
	ldi R24,5
	std y+2,R24
	lds R4,_pcap+2
	lds R5,_pcap+2+1
	lds R2,_pcap
	lds R3,_pcap+1
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	ldi R16,<L54
	ldi R17,>L54
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32f
	std y+0,R18
	std y+1,R19
	movw R18,R16
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Float2Str
	.dbline 214
; 	glcd_text57(2,52,adcbuffer,1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,52
	ldi R16,2
	xcall _glcd_text57
	.dbline 215
; 	glcd_text57(80,52,"mWh",1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L56
	ldi R25,>L56
	std y+1,R25
	std y+0,R24
	ldi R18,52
	ldi R16,80
	xcall _glcd_text57
	.dbline 217
	clr R2
	clr R3
	sts _i+1,R3
	sts _i,R2
	xjmp L60
L57:
	.dbline 217
	.dbline 218
	ldi R24,1
	std y+0,R24
	ldi R24,<_adccurv
	ldi R25,>_adccurv
	lds R30,_i
	lds R31,_i+1
	add R30,R24
	adc R31,R25
	ldd R18,z+0
	lds R16,_i
	xcall _glcd_pixel
	.dbline 219
L58:
	.dbline 217
	lds R24,_i
	lds R25,_i+1
	adiw R24,1
	sts _i+1,R25
	sts _i,R24
L60:
	.dbline 217
; 	//容量end
; 	for(i=0;i<adccurvcount;i++){
	lds R2,_adccurvcount
	clr R3
	lds R4,_i
	lds R5,_i+1
	cp R4,R2
	cpc R5,R3
	brlo L57
	.dbline 221
; 	  glcd_pixel(i,adccurv[i],1);
; 	}
; 	//glcd_line(1,1,64,63,1);
; 	glcd_update();
	xcall _glcd_update
	.dbline 222
; 	glcdhalf=1;
	ldi R24,1
	sts _glcdhalf,R24
	.dbline 223
; 	glcd_fillScreen(0);
	clr R16
	xcall _glcd_fillScreen
	.dbline 224
; 	glcd_text57(2,2,adcbuffer,2,1);
	ldi R24,1
	std y+4,R24
	ldi R24,2
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,2
	ldi R16,2
	xcall _glcd_text57
	.dbline 225
; 	if(rotate_key==1)
	lds R24,_rotate_key
	cpi R24,1
	brne L61
	.dbline 226
; 	  glcd_text57(96,2,"stop",1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L50
	ldi R25,>L50
	std y+1,R25
	std y+0,R24
	ldi R18,2
	ldi R16,96
	xcall _glcd_text57
	xjmp L62
L61:
	.dbline 228
; 	else
; 	  glcd_text57(96,2,"start",1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L51
	ldi R25,>L51
	std y+1,R25
	std y+0,R24
	ldi R18,2
	ldi R16,96
	xcall _glcd_text57
L62:
	.dbline 230
; 	//终止电压
; 	adcfloat=2.56*stopvalue/1024.0;
	ldi R16,<L24
	ldi R17,>L24
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	ldi R16,<L26
	ldi R17,>L26
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	lds R16,_stopvalue
	lds R17,_stopvalue+1
	lsr R17
	ror R16
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall empy32fs
	lds R16,_stopvalue
	lds R17,_stopvalue+1
	andi R16,1
	andi R17,0
	xcall int2fp
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall add32fs
	xcall empy32fs
	ldi R16,<L27
	ldi R17,>L27
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32f
	sts _adcfloat+1,R17
	sts _adcfloat,R16
	sts _adcfloat+2+1,R19
	sts _adcfloat+2,R18
	.dbline 231
; 	adcfloat=adcfloat*2;//真实电路中电压被分压1/2
	ldi R16,<L47
	ldi R17,>L47
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	lds R4,_adcfloat+2
	lds R5,_adcfloat+2+1
	lds R2,_adcfloat
	lds R3,_adcfloat+1
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	xcall empy32f
	sts _adcfloat+1,R17
	sts _adcfloat,R16
	sts _adcfloat+2+1,R19
	sts _adcfloat+2,R18
	.dbline 232
; 	Float2Str(adcbuffer,adcfloat,1,3);
	ldi R24,3
	std y+4,R24
	ldi R24,1
	std y+2,R24
	std y+0,R18
	std y+1,R19
	movw R18,R16
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Float2Str
	.dbline 233
; 	glcd_text57(96,24,adcbuffer,1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,24
	ldi R16,96
	xcall _glcd_text57
	.dbline 236
; 	//终止电压end
; 	//内阻
; 	Float2Str(adcbuffer,res,1,3);
	ldi R24,3
	std y+4,R24
	ldi R24,1
	std y+2,R24
	lds R4,_res+2
	lds R5,_res+2+1
	lds R2,_res
	lds R3,_res+1
	std y+0,R4
	std y+1,R5
	movw R18,R2
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Float2Str
	.dbline 237
; 	glcd_text57(2,18,adcbuffer,2,1);
	ldi R24,1
	std y+4,R24
	ldi R24,2
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,18
	ldi R16,2
	xcall _glcd_text57
	.dbline 238
; 	glcd_text57(60,23,"R",1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L53
	ldi R25,>L53
	std y+1,R25
	std y+0,R24
	ldi R18,23
	ldi R16,60
	xcall _glcd_text57
	.dbline 241
; 	//内阻end
; 	//容量
; 	Float2Str(adcbuffer,cap/3600.0,5,1);
	ldi R24,1
	std y+4,R24
	ldi R24,5
	std y+2,R24
	lds R4,_cap+2
	lds R5,_cap+2+1
	lds R2,_cap
	lds R3,_cap+1
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	ldi R16,<L54
	ldi R17,>L54
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32f
	std y+0,R18
	std y+1,R19
	movw R18,R16
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Float2Str
	.dbline 242
; 	glcd_text57(2,34,adcbuffer,2,1);
	ldi R24,1
	std y+4,R24
	ldi R24,2
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,34
	ldi R16,2
	xcall _glcd_text57
	.dbline 243
; 	glcd_text57(80,39,"mAh",1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L55
	ldi R25,>L55
	std y+1,R25
	std y+0,R24
	ldi R18,39
	ldi R16,80
	xcall _glcd_text57
	.dbline 244
; 	Float2Str(adcbuffer,pcap/3600.0,5,1);
	ldi R24,1
	std y+4,R24
	ldi R24,5
	std y+2,R24
	lds R4,_pcap+2
	lds R5,_pcap+2+1
	lds R2,_pcap
	lds R3,_pcap+1
	st -y,R5
	st -y,R4
	st -y,R3
	st -y,R2
	ldi R16,<L54
	ldi R17,>L54
	xcall lpm32
	st -y,R19
	st -y,R18
	st -y,R17
	st -y,R16
	xcall div32f
	std y+0,R18
	std y+1,R19
	movw R18,R16
	ldi R16,<_adcbuffer
	ldi R17,>_adcbuffer
	xcall _Float2Str
	.dbline 245
; 	glcd_text57(2,52,adcbuffer,1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<_adcbuffer
	ldi R25,>_adcbuffer
	std y+1,R25
	std y+0,R24
	ldi R18,52
	ldi R16,2
	xcall _glcd_text57
	.dbline 246
; 	glcd_text57(80,52,"mWh",1,1);
	ldi R24,1
	std y+4,R24
	std y+2,R24
	ldi R24,<L56
	ldi R25,>L56
	std y+1,R25
	std y+0,R24
	ldi R18,52
	ldi R16,80
	xcall _glcd_text57
	.dbline 248
	clr R2
	clr R3
	sts _i+1,R3
	sts _i,R2
	xjmp L66
L63:
	.dbline 248
	.dbline 249
	ldi R24,1
	std y+0,R24
	ldi R24,<_adccurv
	ldi R25,>_adccurv
	lds R30,_i
	lds R31,_i+1
	add R30,R24
	adc R31,R25
	ldd R18,z+0
	lds R16,_i
	xcall _glcd_pixel
	.dbline 250
L64:
	.dbline 248
	lds R24,_i
	lds R25,_i+1
	adiw R24,1
	sts _i+1,R25
	sts _i,R24
L66:
	.dbline 248
	lds R2,_adccurvcount
	clr R3
	lds R4,_i
	lds R5,_i+1
	cp R4,R2
	cpc R5,R3
	brlo L63
	.dbline 252
	xcall _glcd_update
	.dbline 253
	clr R2
	clr R3
	sts _count+1,R3
	sts _count,R2
	.dbline 255
L31:
	.dbline -2
L10:
	adiw R28,9
	xcall pop_lset
	.dbline 0 ; func end
	reti
	.dbend
	.dbfunc e init_devices _init_devices fV
	.even
_init_devices::
	.dbline -1
	.dbline 261
; 	//容量end
; 	for(i=0;i<adccurvcount;i++){
; 	  glcd_pixel(i,adccurv[i],1);
; 	}
; 	//glcd_line(1,1,64,63,1);
; 	glcd_update();
; 	count=0;
; 		
;   }
;   
; }
; 
; //call this routine to initialise all peripherals
; void init_devices(void)
; {
	.dbline 263
;  	//stop errant interrupts until set up
;  	CLI(); //disable all interrupts
	cli
	.dbline 264
;  	port_init();
	xcall _port_init
	.dbline 266
;     
;  	MCUCR |= 1<<ISC11;
	in R24,0x35
	ori R24,8
	out 0x35,R24
	.dbline 267
; 	MCUCR &= ~(1<<ISC10); //外部中断1为下降沿触发，用于旋转编码器
	in R24,0x35
	andi R24,251
	out 0x35,R24
	.dbline 268
; 	MCUCR |= 1<<ISC01;
	in R24,0x35
	ori R24,2
	out 0x35,R24
	.dbline 269
; 	MCUCR &= ~(1<<ISC00);//外部中断0为下降沿触发，用于旋转编码器开关
	in R24,0x35
	andi R24,254
	out 0x35,R24
	.dbline 271
; 	
;  	GICR  = 0b11000000;//外部中断使能1，0
	ldi R24,192
	out 0x3b,R24
	.dbline 272
; 	SFIOR&=~BIT(PUD);//使能上拉电阻
	in R24,0x30
	andi R24,251
	out 0x30,R24
	.dbline 273
;  	TIMSK = 0x01; //timer interrupt sources,enable timer0
	ldi R24,1
	out 0x39,R24
	.dbline 274
; 	timer0_init();
	xcall _timer0_init
	.dbline 275
; 	ADInit();
	xcall _ADInit
	.dbline 276
;  	SEI(); //re-enable interrupts
	sei
	.dbline 278
;  	//all peripherals are now initialised
; 	rotate_key=0;
	clr R2
	sts _rotate_key,R2
	.dbline 279
; 	hour=0;
	sts _hour,R2
	.dbline 280
; 	minute=0;
	sts _minute,R2
	.dbline 281
; 	second=0;
	sts _second,R2
	.dbline 282
; 	secondcount=0;
	clr R3
	sts _secondcount+1,R3
	sts _secondcount,R2
	.dbline 288
; 	
; 	//tempunsignedchar=EEPROMread(1);
; 	//stopvalue=(unsigned int)tempunsignedchar;
; 	//tempunsignedchar=EEPROMread(2);
; 	//stopvalue=stopvalue+(unsigned int)tempunsignedchar*256;
; 	stopvalue=512;
	ldi R24,512
	ldi R25,2
	sts _stopvalue+1,R25
	sts _stopvalue,R24
	.dbline 289
; 	adcnoloadvalue=adcloadvalue=0;
	sts _adcloadvalue+1,R3
	sts _adcloadvalue,R2
	sts _adcnoloadvalue+1,R3
	sts _adcnoloadvalue,R2
	.dbline 290
;     firststart=0;
	sts _firststart,R2
	.dbline 292
; 	
; 	cap=0.0;
	ldi R16,<L40
	ldi R17,>L40
	xcall lpm32
	sts _cap+1,R17
	sts _cap,R16
	sts _cap+2+1,R19
	sts _cap+2,R18
	.dbline 293
; 	pcap=0.0;
	ldi R16,<L40
	ldi R17,>L40
	xcall lpm32
	sts _pcap+1,R17
	sts _pcap,R16
	sts _pcap+2+1,R19
	sts _pcap+2,R18
	.dbline 295
	clr R2
	clr R3
	sts _i+1,R3
	sts _i,R2
	xjmp L71
L68:
	.dbline 295
	ldi R24,<_adccurv
	ldi R25,>_adccurv
	lds R30,_i
	lds R31,_i+1
	add R30,R24
	adc R31,R25
	clr R2
	std z+0,R2
L69:
	.dbline 295
	lds R24,_i
	lds R25,_i+1
	adiw R24,1
	sts _i+1,R25
	sts _i,R24
L71:
	.dbline 295
; 	
; 	for(i=0;i<128;i++)adccurv[i]=0;
	lds R24,_i
	lds R25,_i+1
	cpi R24,128
	ldi R30,0
	cpc R25,R30
	brlo L68
	.dbline 296
; 	adccurvcount=0;
	clr R2
	sts _adccurvcount,R2
	.dbline -2
L67:
	.dbline 0 ; func end
	ret
	.dbend
	.dbfunc e main _main fV
	.even
_main::
	.dbline -1
	.dbline 300
; }
; 
; void main(void)
; {
	.dbline 301
;  	init_devices();
	xcall _init_devices
	.dbline 303
; 	
; 	glcd_init();
	xcall _glcd_init
	.dbline 304
; 	glcd_update();
	xcall _glcd_update
L73:
	.dbline 310
	.dbline 311
	.dbline 312
L74:
	.dbline 309
	xjmp L73
X5:
	.dbline -2
L72:
	.dbline 0 ; func end
	ret
	.dbend
	.area bss(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
_i::
	.blkb 2
	.dbsym e i _i i
_adccurvcount::
	.blkb 1
	.dbsym e adccurvcount _adccurvcount c
_adccurv::
	.blkb 128
	.dbsym e adccurv _adccurv A[128:128]c
_pcap::
	.blkb 4
	.dbsym e pcap _pcap D
_cap::
	.blkb 4
	.dbsym e cap _cap D
_res::
	.blkb 4
	.dbsym e res _res D
_secondcount::
	.blkb 2
	.dbsym e secondcount _secondcount i
_second::
	.blkb 1
	.dbsym e second _second c
_minute::
	.blkb 1
	.dbsym e minute _minute c
_hour::
	.blkb 1
	.dbsym e hour _hour c
_adcbuffer::
	.blkb 8
	.dbsym e adcbuffer _adcbuffer A[8:8]c
_adcfloat::
	.blkb 4
	.dbsym e adcfloat _adcfloat D
_adc::
	.blkb 2
	.dbsym e adc _adc I
_count::
	.blkb 2
	.dbsym e count _count I
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
L56:
	.blkb 4
	.area idata
	.byte 'm,'W,'h,0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
L55:
	.blkb 4
	.area idata
	.byte 'm,'A,'h,0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.area lit(rom, con, rel)
L54:
	.word 0x0,0x4561
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
L53:
	.blkb 2
	.area idata
	.byte 'R,0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
L52:
	.blkb 2
	.area idata
	.byte 58,0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
L51:
	.blkb 6
	.area idata
	.byte 's,'t,'a,'r,'t,0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
L50:
	.blkb 5
	.area idata
	.byte 's,'t,'o,'p,0
	.area data(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\main.c
	.area lit(rom, con, rel)
L47:
	.word 0x0,0x4000
L40:
	.word 0x0,0x0
L30:
	.word 0x0,0x4120
L29:
	.word 0x0,0x42c8
L28:
	.word 0x999a,0x40d9
L27:
	.word 0x0,0x4480
L26:
	.word 0x0,0x4000
L25:
	.word 0x0,0x4000
L24:
	.word 0xd70a,0x4023
L23:
	.word 0x0,0x447a
