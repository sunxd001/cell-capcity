#include<iom16v.h> 
#include<AVRdef.h> 
unsigned char tab[]={0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f}; //�����0~9 
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
  PORTC=0; //PC�������ܶ�ѡ 
  DDRD=0xff; 
  PORTD=0; //PD5~PD7Ϊ�����λѡ 
    ADCSRA=0; //�ر�ADC 
  ADMUX=(1<<ADLAR)|(1<<REFS0)|(1); //����룬�ο���ѹAVCC,ͨ��1 
  ADCSRA=(1<<ADEN)|(1<<ADSC)|(1<<ADIE)|(7); //ʹ��adc���жϣ�Ԥ��Ƶ128������ADC������������ת��ģʽ��|(1<<ADATE)�� 
   //SFIOR=0;//����ת��ģʽ 
  SEI(); 
   while(1) 
  { 
      display(temp); //��̬��ʾ����� 
  } 
} 
#pragma interrupt_handler adc:iv_ADC 
 void adc() 
{ 
    temp=ADCH; //��ȡת�������� 
  ADCSRA|=0X40; //��������ADC,����ADCSRA��ADATE������ת��ģʽʱ���� 
} 
 void display(unsigned char smg) //3λ����ܶ�̬��ʾ 
{ 
    unsigned char bai,shi,ge; 
  bai=smg/100; //��λ 
  shi=smg%100/10; //ʮλ 
  ge=smg%10; //��λ 
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