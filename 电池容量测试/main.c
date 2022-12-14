//DIY低成本电池容量测试仪，测试原理：测试有负载与无负载间的电压差，
//通过已知外部电阻计算电池内阻。通过每隔一秒测一下电压，通过已知外部放电电阻计算电流
//累积计算毫安时
//电源为USB5V
//12864接PORTC，* 0: SDI  1: SCK  2: A0  3: RS  4: CS1 
//12864     面向正面gnd|VCC|SDI|SCK|A0|RES|CS1,CS1标的1脚
//电池接PORTA 0，通过1K+1K分压接入AD，AD参考源为内部2.56V参考源，PORTA置为AD转换器，可同时测8路电池  
//电池通过6.8水泥电阻放电
//继电器接PORTD 7，用于控制电池放电启停
//旋转编码器K关接INT 0，PORTD 2,用于操作放电启停
//旋转编码器A接INT 1，PORTD 3，B接PORT D 4，用于调整放电截止电压，
//注意施转编码器各脚需接104电容到地，通过510电阻到各脚
//开发平台ICCAVR 6.31A，使用了num2str-数字转字符串,mygraphic-抽象图形库,mzl05-针对铭正同创mzl05-12864的硬件层接口
// Target : M16
// Crystal: 8M外部晶振

//发现问题，AD接地仍有电压，可能电AREF没有外接电容，好象不是，PORTA=0x00后解决，但比万用表高0.1

#include <iom16v.h>
#include <macros.h>
#include <eeprom.h>
#include "num2str.h"
#include "mzl05.h"
#include "myGRAPHICS.h"
extern char glcdhalf;//由于M16内存局限每次只刷新半个屏幕
int count;//timer0计数

int adc;//ADC转换结果
float adcfloat;//ADC转换结的浮点表示
int adcnoloadvalue=0,adcloadvalue=0;//无载电压与有载电压，用于计算内阻
unsigned char firststart=0;//第一次进入有载

unsigned char adcbuffer[8];//ADC字符串结果 

unsigned char rotate_key=0;//旋转编码器开关状态
unsigned char rotate_code=0;//PIND,用于判断旋转方向
unsigned char rotate_dir=0;//旋转编码器方向

unsigned char hour,minute,second;
unsigned int secondcount;

unsigned int stopvalue=512;//停止放电电压
//unsigned char tempunsignedchar;

float res;//电池内阻

float cap;//电池容量
unsigned int adccap=0;//电池容量整数表示
float pcap;//以功率计算容量

unsigned char adccurv[128];//放电电压曲线，每分钟一记，可记2小时
unsigned char adccurvcount;
unsigned int i;
void port_init(void)
{
 	PORTA = 0x00;
 	DDRA  = 0x00;
 	PORTB = 0xFF;
 	DDRB  = 0xFF;
 	PORTC = 0xFF;
 	DDRC  = 0xFF;
 	PORTD = 0x7F;
	DDRD  = 0x80;//PORTD PIN7为继电器控制
}
//外部中断0
#pragma interrupt_handler int0_isr:2
void int0_isr(void)
{
  if(rotate_key==0){//未放电状态
    PORTD |=1<<7;   //关闭常开触点，开始放电
	rotate_key=1;   //记录标志
	hour=minute=second=0;  //初始化计时器
	firststart=1;   //第一次进入放电状态
  }else{
    PORTD &=~(1<<7); //断开继电器
	rotate_key=0;    //记录标志
  }
}
//外部中断1
//在旋转编码器A相下降沿查看B相电平，如果是高++
#pragma interrupt_handler int1_isr:3
void int1_isr(void)
{ 
  rotate_code=PIND;  
  if((rotate_code & 0x10) == 0x10){
    stopvalue++;	
  }else{
    stopvalue--;    
  }
  //tempunsignedchar=stopvalue % 256;
  //EEPROMwrite(1,tempunsignedchar);
  //tempunsignedchar=stopvalue / 256;
  //EEPROMwrite(2,tempunsignedchar);
}

void timer0_init(void) //定时器初始化程序
{
TCCR0 = 0x00; //停止定时器
//TCNT0 = 0x3A; //设置初始值,75us，合计0.075X256=20ms//3A好用，计算值44
TCNT0=0xCF;//75us/4
TCCR0 = 0x02; //开动定时器,可能是主频/8
}
void ADInit(void)
{
    ADMUX|=(1<<REFS1)|(1<<REFS0);  //选择内部2.56V为ADC的参考电压
    ADMUX&=~(1<<ADLAR);  //转换结果右对齐
	ADMUX&=~(1<<MUX4);
	ADMUX&=~(1<<MUX3);
	ADMUX&=~(1<<MUX2);
	ADMUX&=~(1<<MUX1);
	ADMUX&=~(1<<MUX0);        //选择通道ADC0
	ADCSRA|=(1<<ADPS2)|(1<<ADPS0);
	ADCSRA&=~(1<<ADPS1);  //时钟分频系数为64
	ADCSRA|=(1<<ADEN);//使能AD
	ADCSRA&=~(1<<ADATE);//不自动转换
	ADCSRA&=~(1<<ADIE);//禁用AD中断
}
#pragma interrupt_handler timer0_ovf_isr:10 
void timer0_ovf_isr(void) //定时器溢出中断程序,大约49*8机器周期中断一次
{
  //TCNT0 = 0x3A; //从新调入初始值
  TCNT0=0xCF;
  secondcount++;
  if(rotate_key==1)//如果开始测量容量，记时，开始计算容量
  if(secondcount>10933){//大约一秒，可能还要调一下
    secondcount=0;
	second++;
	if(second>59){
	  second=0;minute++;
	  if(minute % 2 == 0){ //两分钟记录一次，最多记256分钟，4小时16分
	    adccurv[adccurvcount]=63-(unsigned char)(adccap/16);
	    adccurvcount++;
		if(adccurvcount>127)adccurvcount=127;
	  }	
	}
	if(minute>59){
	  minute=0;hour++;
	}
	//adccap来自前一次测试时的电压，电压/电阻等于电流，每一秒累加电流*时间等于mAh
	cap+=(((float)adccap*2.0*2.56*1000.0)/1024.0)/6.8; //ma,计算mAs
	pcap+=(((float)adccap*2.0*2.56*100.0)/1024.0)*(((float)adccap*2.0*2.56*10.0)/1024.0)/6.8; //ma,计算mWs      
	//cap=(((adccap*2.0*2.56/1024.0)/6.8)*1000.0)  //ma
	//    *(hour+minute/60.0+second/3600.0);//hour
  }
  count++; //每中断一次加1
  if (count>4096) //需要估算时间
  { //AD转换
    
	ADCSRA|=(1<<ADSC);  //启动一次AD转换
	while(!(ADCSRA &(1<<ADIF))){
	};//ADIF 为1时表示AD转换完成
	adc=ADCL;
	adc|=(int)(ADCH<<8);
	adccap=adc;//随时采集电压用于计算容量
	ADCSRA|=(1<<ADIF);
	//AD转换结束
	if(rotate_key==0)adcnoloadvalue=adc;
	if(rotate_key==1 && firststart==1){
	  firststart=0;
	  adcloadvalue=adc;
	  //计算内阻,(无载电压-带载电压)/电流
	  res=(((adcnoloadvalue-adcloadvalue)*2.0*2.56)/1024.0)  //电压差
	      /((adcloadvalue*2.0*2.56/1024.0)/6.8);//电流，6.8为水泥电阻阻值
	  cap=0.0;//初始化容量
	  pcap=0.0;	  
	  for(i=0;i<128;i++)adccurv[i]=0;//初始化曲线
	  adccurvcount=0;
	}
	//如果电压低于终止电压，停计容量，断继电器
	if(adc<stopvalue && rotate_key==1){
	  PORTD &=~(1<<7);
	  rotate_key=0;
	}
	adcfloat=2.56*adc/1024.0;
	adcfloat=adcfloat*2;//真实电路中电压被分压1/2
	
	Float2Str(adcbuffer,adcfloat,1,3);//格式化成为字符串
	 
	glcdhalf=0;
	glcd_fillScreen(0);
	//当前电压
	glcd_text57(2,2,adcbuffer,2,1);
	//是否开始，如果已经开始测容量显示stop
	if(rotate_key==1)
	  glcd_text57(96,2,"stop",1,1);
	else
	  glcd_text57(96,2,"start",1,1);  
 	//时钟
	Num2Str(adcbuffer,hour,2);
	glcd_text57(80,12,adcbuffer,1,1);
	glcd_text57(92,12,":",1,1);
	Num2Str(adcbuffer,minute,2);
	glcd_text57(98,12,adcbuffer,1,1);
	glcd_text57(110,12,":",1,1);
	Num2Str(adcbuffer,second,2);
	glcd_text57(116,12,adcbuffer,1,1);
	//时钟end
	//终止电压
	adcfloat=2.56*stopvalue/1024.0;
	adcfloat=adcfloat*2;//真实电路中电压被分压1/2
	Float2Str(adcbuffer,adcfloat,1,3);
	glcd_text57(96,24,adcbuffer,1,1);
	//终止电压end
	//内阻
	Float2Str(adcbuffer,res,1,3);
	glcd_text57(2,18,adcbuffer,2,1);
	glcd_text57(60,23,"R",1,1);
	//内阻end
	//容量
	Float2Str(adcbuffer,cap/3600.0,5,1);
	glcd_text57(2,34,adcbuffer,2,1);
	glcd_text57(80,39,"mAh",1,1);
	Float2Str(adcbuffer,pcap/3600.0,5,1);
	glcd_text57(2,52,adcbuffer,1,1);
	glcd_text57(80,52,"mWh",1,1);
	//容量end
	for(i=0;i<adccurvcount;i++){
	  glcd_pixel(i,adccurv[i],1);
	}
	//glcd_line(1,1,64,63,1);
	glcd_update();
	glcdhalf=1;
	glcd_fillScreen(0);
	glcd_text57(2,2,adcbuffer,2,1);
	if(rotate_key==1)
	  glcd_text57(96,2,"stop",1,1);
	else
	  glcd_text57(96,2,"start",1,1);
	//终止电压
	adcfloat=2.56*stopvalue/1024.0;
	adcfloat=adcfloat*2;//真实电路中电压被分压1/2
	Float2Str(adcbuffer,adcfloat,1,3);
	glcd_text57(96,24,adcbuffer,1,1);
	//终止电压end
	//内阻
	Float2Str(adcbuffer,res,1,3);
	glcd_text57(2,18,adcbuffer,2,1);
	glcd_text57(60,23,"R",1,1);
	//内阻end
	//容量
	Float2Str(adcbuffer,cap/3600.0,5,1);
	glcd_text57(2,34,adcbuffer,2,1);
	glcd_text57(80,39,"mAh",1,1);
	Float2Str(adcbuffer,pcap/3600.0,5,1);
	glcd_text57(2,52,adcbuffer,1,1);
	glcd_text57(80,52,"mWh",1,1);
	//容量end
	for(i=0;i<adccurvcount;i++){
	  glcd_pixel(i,adccurv[i],1);
	}
	//glcd_line(1,1,64,63,1);
	glcd_update();
	count=0;
		
  }
  
}

//call this routine to initialise all peripherals
void init_devices(void)
{
 	//stop errant interrupts until set up
 	CLI(); //disable all interrupts
 	port_init();
    
 	MCUCR |= 1<<ISC11;
	MCUCR &= ~(1<<ISC10); //外部中断1为下降沿触发，用于旋转编码器
	MCUCR |= 1<<ISC01;
	MCUCR &= ~(1<<ISC00);//外部中断0为下降沿触发，用于旋转编码器开关
	
 	GICR  = 0b11000000;//外部中断使能1，0
	SFIOR&=~BIT(PUD);//使能上拉电阻
 	TIMSK = 0x01; //timer interrupt sources,enable timer0
	timer0_init();
	ADInit();
 	SEI(); //re-enable interrupts
 	//all peripherals are now initialised
	rotate_key=0;
	hour=0;
	minute=0;
	second=0;
	secondcount=0;
	
	//tempunsignedchar=EEPROMread(1);
	//stopvalue=(unsigned int)tempunsignedchar;
	//tempunsignedchar=EEPROMread(2);
	//stopvalue=stopvalue+(unsigned int)tempunsignedchar*256;
	stopvalue=512;
	adcnoloadvalue=adcloadvalue=0;
    firststart=0;
	
	cap=0.0;
	pcap=0.0;
	
	for(i=0;i<128;i++)adccurv[i]=0;
	adccurvcount=0;
}

void main(void)
{
 	init_devices();
	
	glcd_init();
	glcd_update();
 	//glcd_fillScreen(0x01);
		
	
 	//insert your functional code here...
 	while (1)
 	{
		;
 	}
}

