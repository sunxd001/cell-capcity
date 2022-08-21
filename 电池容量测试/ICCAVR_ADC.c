#include<iom16v.h> 
#include<AVRdef.h> 
unsigned char tab[]={0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f}; //数码管0~9 
 void display(unsigned char smg); 
unsigned char temp; 
 void delay_1ms(unsigned int z) 
{ 
    unsigned int i,j; 
   for(i=0;i<z;i++) 
     for(j=0;j<150;j++); 
} 
 void main() 
{ 
    DDRC=0xff; 
  PORTC=0; //PC输出数码管段选 
  DDRD=0xff; 
  PORTD=0; //PD5~PD7为数码管位选 
    ADCSRA=0; //关闭ADC 
  ADMUX=(1<<ADLAR)|(1<<REFS0)|(1); //左对齐，参考电压AVCC,通道1 
  ADCSRA=(1<<ADEN)|(1<<ADSC)|(1<<ADIE)|(7); //使能adc和中断，预分频128，启动ADC，不设置连续转化模式（|(1<<ADATE)） 
   //SFIOR=0;//连续转换模式 
  SEI(); 
   while(1) 
  { 
      display(temp); //动态显示数码管 
  } 
} 
#pragma interrupt_handler adc:iv_ADC 
 void adc() 
{ 
    temp=ADCH; //读取转换的数据 
  ADCSRA|=0X40; //重新启动ADC,设置ADCSRA的ADATE和连续转换模式时不用 
} 
 void display(unsigned char smg) //3位数码管动态显示 
{ 
    unsigned char bai,shi,ge; 
  bai=smg/100; //百位 
  shi=smg%100/10; //十位 
  ge=smg%10; //个位 
  PORTC=tab[bai]; 
  PORTD=0x80; 
  PORTD=0; 
  delay_1ms(2); 
  PORTC=tab[shi]; 
  PORTD=0x40; 
  PORTD=0; 
  delay_1ms(2); 
  PORTC=tab[ge]; 
  PORTD=0x20; 
  PORTD=0; 
  delay_1ms(1); 
}