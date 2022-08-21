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
////     面向正面gnd|VCC|SDI|SCK|A0|RES|CS1,CS1标的1脚                                                            ////
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
// 函数: void LCD_DataWrite(unsigned int Data)
// 描述: 写一个字节的显示数据至LCD中的显示缓冲RAM当中
// 参数: Data 写入的数据 
// 返回: 无
// 备注: 无
// 版本:
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
// 函数: void LCD_RegWrite(unsigned char Command)
// 描述: 写一个字节的数据至LCD中的控制寄存器当中
// 参数: Command      写入的数据，低八位有效（byte） 
// 返回: 无
// 备注: 
// 版本:
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
// 函数: void LCD_Fill(unsigned int Data)
// 描述: 会屏填充以Data的数据至各点中
// 参数: Data   要填充的颜色数据
// 返回: 无
// 备注: 仅在LCD初始化程序当中调用
// 版本:
//      2006/10/15      First version
//      2007/01/09      V1.2 
//========================================================================
void LCD_Fill(char Data)
{
   char i,j;
   char uiTemp;
   uiTemp = GLCD_HEIGHT;
   uiTemp = uiTemp>>3;
   for(i=0;i<=uiTemp;i++)                        //往LCD中填充初始化的显示数据
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
// 函数: void LCD_Init(void)
// 描述: LCD初始化程序，在里面会完成LCD初始所需要设置的许多寄存器，具体如果
//       用户想了解，建议查看DataSheet当中各个寄存器的意义
// 参数: 无 
// 返回: 无
// 备注:
// 版本:
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
   //LCD驱动所使用到的端口的初始化（如果有必要的话）
//   delay_us(200);
   RES_L;
//   delay_us(200);
   RES_H;
//   delay_us(20);
   
   LCD_RegWrite(0xaf); //LCD On
   LCD_RegWrite(0x2f); //设置上电控制模式
   LCD_RegWrite(0x81); //电量设置模式（显示亮度）
   LCD_RegWrite(0x28); //指令数据0x0000~0x003f
   LCD_RegWrite(0x24); //V5 内部电压调节电阻设置---27
   //LCD_RegWrite(0x24); //V5 内部电压调节电阻设置---27
   LCD_RegWrite(0xa1); //LCD 偏压设置a2
   LCD_RegWrite(0xc8); //Com 扫描方式设置,反向
   LCD_RegWrite(0xa0); //Segment 方向选择,正常
   LCD_RegWrite(0xa4); //全屏点亮/变暗指令
   LCD_RegWrite(0xa6); //正向反向显示控制指令
   LCD_RegWrite(0xac); //关闭静态指示器
   LCD_RegWrite(0x00); //指令数据
   LCD_RegWrite(0x40 +0); //设置显示起始行对应RAM
   LCD_RegWrite(0xe0); //设置读写改模式
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
     for(i=0;i<uiTemp;i++)                        //往LCD中填充初始化的显示数据
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
     for(i=0;i<uiTemp;i++)                        //往LCD中填充初始化的显示数据
     {
        LCD_RegWrite(0xb0+i+4);//页地址
        LCD_RegWrite(0x00);//列起始地址
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
       for(j=0;j<4;j++)//  /2是因为分上下两屏
         LCD_Buffer[i][j]=0xFF;
   }		 
   else{
     for(i=0;i<GLCD_WIDTH;i++)
       for(j=0;j<4;j++)//  GLCD_HEIGHT/8/2   /2是因为分上下两屏
         LCD_Buffer[i][j]=0x00;
   }		 
   //for(i=0;i<GLCD_WIDTH/2;i++)
   //  for(j=0;j<4;j++)
   //    LCD_Buffer[i][j]=0x00;
}

