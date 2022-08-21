/////////////////////////////////////////////////////////////////////////
////                           mzl05.c                           ////
////                                                                 ////
////                                                                 ////
//// LCD Pin connections:  PORTA                                     ////
//// (These can be changed as needed in the following defines).      ////
////  * 0: SDI                                                        ////
////  * 1: SCK                                                        ////
////  * 2: A0                                                         ////
////  * 3: RS                                                        ////
////  * 4: CS1                                                       ////
////  DATA PORTA                                                     ////
/////////////////////////////////////////////////////////////////////////
////     ��������gnd|VCC|SDI|SCK|A0|RES|CS1,CS1���1��                                                            ////
////  glcd_init(mode)                                                ////
////     * Must be called before any other function.                 ////
////       - mode can be ON or OFF to turn the LCD on or off         ////
////                                                                 ////
////  glcd_pixel(x,y,color)                                          ////
////     * Sets the pixel to the given color.                        ////
////       - color can be ON or OFF                                  ////
////                                                                 ////
////  glcd_fillScreen(color)                                         ////
////     * Fills the entire LCD with the given color.                ////
////       - color can be ON or OFF                                  ////
////                                                                 ////
////  glcd_update()                                                  ////
////     * Write the display data stored in RAM to the LCD           ////
////     * Only available if FAST_GLCD is defined                    ////
////                                                                 ////
/////////////////////////////////////////////////////////////////////////
////        (C) Copyright 1996, 2004 Custom Computer Services        ////
//// This source code may only be used by licensed users of the CCS  ////
//// C compiler.  This source code may only be distributed to other  ////
//// licensed users of the CCS C compiler.  No other use,            ////
//// reproduction or distribution is permitted without written       ////
//// permission.  Derivative programs created using this software    ////
//// in object code form are not restricted in any way.              ////
/////////////////////////////////////////////////////////////////////////
#include <iom16v.h>
#include "mzl05.h"

char glcdhalf;

/*  lcd port define: connect to PORTA of MEGA16 */
#define	SDI	 0   
#define	SCK	 1
#define	A0	 2
#define	RES	 3
#define	CS1	 4
#define LCD_PORT PORTC

/******************************************************************** */

#define SDI_H SETBIT(LCD_PORT,SDI)
#define SDI_L CLRBIT(LCD_PORT,SDI)
#define SCK_H SETBIT(LCD_PORT,SCK)    
#define SCK_L CLRBIT(LCD_PORT,SCK)   
#define A0_H SETBIT(LCD_PORT,A0)
#define A0_L CLRBIT(LCD_PORT,A0)
#define RES_H SETBIT(LCD_PORT,RES)
#define RES_L CLRBIT(LCD_PORT,RES)
#define CS1_H SETBIT(LCD_PORT,CS1)
#define CS1_L CLRBIT(LCD_PORT,CS1)

#ifndef GLCD_WIDTH
#define GLCD_WIDTH   128
#endif

#ifndef GLCD_HEIGHT
#define GLCD_HEIGHT      64
#endif

#ifndef ON
#define ON           1
#endif

#ifndef OFF
#define OFF          0
#endif

//////////////////////////////////////////////////////////////////////


char LCD_Buffer[128][4];


//========================================================================
// ����: void LCD_DataWrite(unsigned int Data)
// ����: дһ���ֽڵ���ʾ������LCD�е���ʾ����RAM����
// ����: Data д������� 
// ����: ��
// ��ע: ��
// �汾:
//      2007/01/09      First version
//========================================================================
void LCD_DataWrite(char Dat)//,_Fill_Dot_LCD
{
   char Num;
   CS1_L;
   A0_H;
   for(Num=0;Num<8;Num++)
   {
      if((Dat&0x80) == 0)   SDI_L;
      else SDI_H;
      Dat = Dat << 1;
      SCK_L;
      SCK_H;
   }
}
//========================================================================
// ����: void LCD_RegWrite(unsigned char Command)
// ����: дһ���ֽڵ�������LCD�еĿ��ƼĴ�������
// ����: Command      д������ݣ��Ͱ�λ��Ч��byte�� 
// ����: ��
// ��ע: 
// �汾:
//      2007/01/09      First version
//========================================================================
void LCD_RegWrite(char Command)
{
   char Num;
   CS1_L;
   A0_L;
   for(Num=0;Num<8;Num++)
   {
      if((Command&0x80) == 0)   SDI_L;
      else SDI_H;
      Command = Command << 1;
      SCK_L;
      SCK_H;
   }
}
//========================================================================
// ����: void LCD_Fill(unsigned int Data)
// ����: ���������Data��������������
// ����: Data   Ҫ������ɫ����
// ����: ��
// ��ע: ����LCD��ʼ�������е���
// �汾:
//      2006/10/15      First version
//      2007/01/09      V1.2 
//========================================================================
void LCD_Fill(char Data)
{
   char i,j;
   char uiTemp;
   uiTemp = GLCD_HEIGHT;
   uiTemp = uiTemp>>3;
   for(i=0;i<=uiTemp;i++)                        //��LCD������ʼ������ʾ����
   {
      LCD_RegWrite(0xb0+i);
      LCD_RegWrite(0x01);
      LCD_RegWrite(0x10);
      for(j=0;j<=GLCD_WIDTH;j++)
      {
         LCD_DataWrite(Data);
      }
   }
}
//========================================================================
// ����: void LCD_Init(void)
// ����: LCD��ʼ����������������LCD��ʼ����Ҫ���õ����Ĵ������������
//       �û����˽⣬����鿴DataSheet���и����Ĵ���������
// ����: �� 
// ����: ��
// ��ע:
// �汾:
//      2006/10/15      First version
//      2007/01/09      V1.2
//      2007/06/27      V1.21 
//========================================================================


// Purpose:       Initialize the LCD.
//                Call before using any other LCD function.
// Inputs:        OFF - Turns the LCD off
//                ON  - Turns the LCD on
void glcd_init(void)
{
   //LCD������ʹ�õ��Ķ˿ڵĳ�ʼ��������б�Ҫ�Ļ���
//   delay_us(200);
   RES_L;
//   delay_us(200);
   RES_H;
//   delay_us(20);
   
   LCD_RegWrite(0xaf); //LCD On
   LCD_RegWrite(0x2f); //�����ϵ����ģʽ
   LCD_RegWrite(0x81); //��������ģʽ����ʾ���ȣ�
   LCD_RegWrite(0x28); //ָ������0x0000~0x003f
   LCD_RegWrite(0x24); //V5 �ڲ���ѹ���ڵ�������---27
   //LCD_RegWrite(0x24); //V5 �ڲ���ѹ���ڵ�������---27
   LCD_RegWrite(0xa1); //LCD ƫѹ����a2
   LCD_RegWrite(0xc8); //Com ɨ�跽ʽ����,����
   LCD_RegWrite(0xa0); //Segment ����ѡ��,����
   LCD_RegWrite(0xa4); //ȫ������/�䰵ָ��
   LCD_RegWrite(0xa6); //��������ʾ����ָ��
   LCD_RegWrite(0xac); //�رվ�ָ̬ʾ��
   LCD_RegWrite(0x00); //ָ������
   LCD_RegWrite(0x40 +0); //������ʾ��ʼ�ж�ӦRAM
   LCD_RegWrite(0xe0); //���ö�д��ģʽ
   ////
     
   glcd_fillScreen(OFF);                // Clear the display
   
   glcd_update();
   //delay_ms(10);
}


// Purpose:    Update the LCD with data from the display arrays

void glcd_update()
{
   char i,j;
   char uiTemp;
   if(glcdhalf==0){
     //uiTemp = GLCD_HEIGHT;
     //uiTemp = uiTemp/8/2;
	 uiTemp=4;
     for(i=0;i<uiTemp;i++)                        //��LCD������ʼ������ʾ����
     {
        LCD_RegWrite(0xb0+i);
        LCD_RegWrite(0x00);
        LCD_RegWrite(0x10);
        for(j=0;j<=GLCD_WIDTH;j++)
        {
          LCD_DataWrite(LCD_Buffer[j][i]);
        }
     }
   }
   else{
     //uiTemp = GLCD_HEIGHT;
     uiTemp = 4;
     for(i=0;i<uiTemp;i++)                        //��LCD������ʼ������ʾ����
     {
        LCD_RegWrite(0xb0+i+4);//ҳ��ַ
        LCD_RegWrite(0x00);//����ʼ��ַ
        LCD_RegWrite(0x10);
        for(j=0;j<=GLCD_WIDTH;j++)
        {
          LCD_DataWrite(LCD_Buffer[j][i]);
        }
     }
   }	 
}



// Purpose:    Turn a pixel on a graphic LCD on or off
// Inputs:     1) x - the x coordinate of the pixel
//             2) y - the y coordinate of the pixel
//             3) color - ON or OFF
void glcd_pixel(char x, char y, char color)
{
   if(glcdhalf==0){
     if(y/8<4){
	   if(color==1){
          SETBIT(LCD_Buffer[x][y/8], y%8);
       }
       else{
          CLRBIT(LCD_Buffer[x][y/8], y%8);
       }
	 }  
   }
   else{
     if(y/8>3){
	   if(color==1){
          SETBIT(LCD_Buffer[x][y/8-4], y%8);
       }
       else{
          CLRBIT(LCD_Buffer[x][y/8-4], y%8);
       }
	 }  
   } 
}


// Purpose:    Fill the LCD screen with the passed in color
// Inputs:     ON  - turn all the pixels on
//             OFF - turn all the pixels off
void glcd_fillScreen(char color)
{
   char i,j;
   if(color==1){
     for(i=0;i<GLCD_WIDTH;i++)
       for(j=0;j<4;j++)//  /2����Ϊ����������
         LCD_Buffer[i][j]=0xFF;
   }		 
   else{
     for(i=0;i<GLCD_WIDTH;i++)
       for(j=0;j<4;j++)//  GLCD_HEIGHT/8/2   /2����Ϊ����������
         LCD_Buffer[i][j]=0x00;
   }		 
   //for(i=0;i<GLCD_WIDTH/2;i++)
   //  for(j=0;j<4;j++)
   //    LCD_Buffer[i][j]=0x00;
}

