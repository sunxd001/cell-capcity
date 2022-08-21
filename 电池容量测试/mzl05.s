	.module mzl05.c
	.area text(rom, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\mzl05.c
	.dbfunc e LCD_DataWrite _LCD_DataWrite fV
;            Num -> R20
;            Dat -> R16
	.even
_LCD_DataWrite::
	xcall push_gset1
	.dbline -1
	.dbline 98
; /////////////////////////////////////////////////////////////////////////
; ////                           mzl05.c                           ////
; ////                                                                 ////
; ////                                                                 ////
; //// LCD Pin connections:  PORTA                                     ////
; //// (These can be changed as needed in the following defines).      ////
; ////  * 0: SDI                                                        ////
; ////  * 1: SCK                                                        ////
; ////  * 2: A0                                                         ////
; ////  * 3: RS                                                        ////
; ////  * 4: CS1                                                       ////
; ////  DATA PORTA                                                     ////
; /////////////////////////////////////////////////////////////////////////
; ////     面向正面gnd|VCC|SDI|SCK|A0|RES|CS1,CS1标的1脚                                                            ////
; ////  glcd_init(mode)                                                ////
; ////     * Must be called before any other function.                 ////
; ////       - mode can be ON or OFF to turn the LCD on or off         ////
; ////                                                                 ////
; ////  glcd_pixel(x,y,color)                                          ////
; ////     * Sets the pixel to the given color.                        ////
; ////       - color can be ON or OFF                                  ////
; ////                                                                 ////
; ////  glcd_fillScreen(color)                                         ////
; ////     * Fills the entire LCD with the given color.                ////
; ////       - color can be ON or OFF                                  ////
; ////                                                                 ////
; ////  glcd_update()                                                  ////
; ////     * Write the display data stored in RAM to the LCD           ////
; ////     * Only available if FAST_GLCD is defined                    ////
; ////                                                                 ////
; /////////////////////////////////////////////////////////////////////////
; ////        (C) Copyright 1996, 2004 Custom Computer Services        ////
; //// This source code may only be used by licensed users of the CCS  ////
; //// C compiler.  This source code may only be distributed to other  ////
; //// licensed users of the CCS C compiler.  No other use,            ////
; //// reproduction or distribution is permitted without written       ////
; //// permission.  Derivative programs created using this software    ////
; //// in object code form are not restricted in any way.              ////
; /////////////////////////////////////////////////////////////////////////
; #include <iom16v.h>
; #include "mzl05.h"
; 
; char glcdhalf;
; 
; /*  lcd port define: connect to PORTA of MEGA16 */
; #define	SDI	 0   
; #define	SCK	 1
; #define	A0	 2
; #define	RES	 3
; #define	CS1	 4
; #define LCD_PORT PORTC
; 
; /******************************************************************** */
; 
; #define SDI_H SETBIT(LCD_PORT,SDI)
; #define SDI_L CLRBIT(LCD_PORT,SDI)
; #define SCK_H SETBIT(LCD_PORT,SCK)    
; #define SCK_L CLRBIT(LCD_PORT,SCK)   
; #define A0_H SETBIT(LCD_PORT,A0)
; #define A0_L CLRBIT(LCD_PORT,A0)
; #define RES_H SETBIT(LCD_PORT,RES)
; #define RES_L CLRBIT(LCD_PORT,RES)
; #define CS1_H SETBIT(LCD_PORT,CS1)
; #define CS1_L CLRBIT(LCD_PORT,CS1)
; 
; #ifndef GLCD_WIDTH
; #define GLCD_WIDTH   128
; #endif
; 
; #ifndef GLCD_HEIGHT
; #define GLCD_HEIGHT      64
; #endif
; 
; #ifndef ON
; #define ON           1
; #endif
; 
; #ifndef OFF
; #define OFF          0
; #endif
; 
; //////////////////////////////////////////////////////////////////////
; 
; 
; char LCD_Buffer[128][4];
; 
; 
; //========================================================================
; // 函数: void LCD_DataWrite(unsigned int Data)
; // 描述: 写一个字节的显示数据至LCD中的显示缓冲RAM当中
; // 参数: Data 写入的数据 
; // 返回: 无
; // 备注: 无
; // 版本:
; //      2007/01/09      First version
; //========================================================================
; void LCD_DataWrite(char Dat)//,_Fill_Dot_LCD
; {
	.dbline 100
;    char Num;
;    CS1_L;
	cbi 0x15,4
	.dbline 101
;    A0_H;
	sbi 0x15,2
	.dbline 102
;    for(Num=0;Num<8;Num++)
	clr R20
	xjmp L5
L2:
	.dbline 103
;    {
	.dbline 104
;       if((Dat&0x80) == 0)   SDI_L;
	sbrc R16,7
	rjmp L6
	.dbline 104
	cbi 0x15,0
	xjmp L7
L6:
	.dbline 105
;       else SDI_H;
	sbi 0x15,0
L7:
	.dbline 106
	lsl R16
	.dbline 107
	cbi 0x15,1
	.dbline 108
	sbi 0x15,1
	.dbline 109
L3:
	.dbline 102
	inc R20
L5:
	.dbline 102
	cpi R20,8
	brlo L2
	.dbline -2
L1:
	xcall pop_gset1
	.dbline 0 ; func end
	ret
	.dbsym r Num 20 c
	.dbsym r Dat 16 c
	.dbend
	.dbfunc e LCD_RegWrite _LCD_RegWrite fV
;            Num -> R20
;        Command -> R16
	.even
_LCD_RegWrite::
	xcall push_gset1
	.dbline -1
	.dbline 121
;       Dat = Dat << 1;
;       SCK_L;
;       SCK_H;
;    }
; }
; //========================================================================
; // 函数: void LCD_RegWrite(unsigned char Command)
; // 描述: 写一个字节的数据至LCD中的控制寄存器当中
; // 参数: Command      写入的数据，低八位有效（byte） 
; // 返回: 无
; // 备注: 
; // 版本:
; //      2007/01/09      First version
; //========================================================================
; void LCD_RegWrite(char Command)
; {
	.dbline 123
;    char Num;
;    CS1_L;
	cbi 0x15,4
	.dbline 124
;    A0_L;
	cbi 0x15,2
	.dbline 125
;    for(Num=0;Num<8;Num++)
	clr R20
	xjmp L12
L9:
	.dbline 126
;    {
	.dbline 127
;       if((Command&0x80) == 0)   SDI_L;
	sbrc R16,7
	rjmp L13
	.dbline 127
	cbi 0x15,0
	xjmp L14
L13:
	.dbline 128
;       else SDI_H;
	sbi 0x15,0
L14:
	.dbline 129
	lsl R16
	.dbline 130
	cbi 0x15,1
	.dbline 131
	sbi 0x15,1
	.dbline 132
L10:
	.dbline 125
	inc R20
L12:
	.dbline 125
	cpi R20,8
	brlo L9
	.dbline -2
L8:
	xcall pop_gset1
	.dbline 0 ; func end
	ret
	.dbsym r Num 20 c
	.dbsym r Command 16 c
	.dbend
	.dbfunc e LCD_Fill _LCD_Fill fV
;         uiTemp -> R20
;              i -> R22
;              j -> R12
;           Data -> R10
	.even
_LCD_Fill::
	xcall push_gset4
	mov R10,R16
	.dbline -1
	.dbline 145
;       Command = Command << 1;
;       SCK_L;
;       SCK_H;
;    }
; }
; //========================================================================
; // 函数: void LCD_Fill(unsigned int Data)
; // 描述: 会屏填充以Data的数据至各点中
; // 参数: Data   要填充的颜色数据
; // 返回: 无
; // 备注: 仅在LCD初始化程序当中调用
; // 版本:
; //      2006/10/15      First version
; //      2007/01/09      V1.2 
; //========================================================================
; void LCD_Fill(char Data)
; {
	.dbline 148
;    char i,j;
;    char uiTemp;
;    uiTemp = GLCD_HEIGHT;
	ldi R20,32
	.dbline 149
;    uiTemp = uiTemp>>3;
	lsr R20
	lsr R20
	lsr R20
	.dbline 150
;    for(i=0;i<=uiTemp;i++)                        //往LCD中填充初始化的显示数据
	clr R22
	xjmp L19
L16:
	.dbline 151
;    {
	.dbline 152
;       LCD_RegWrite(0xb0+i);
	mov R16,R22
	subi R16,80    ; addi 176
	xcall _LCD_RegWrite
	.dbline 153
;       LCD_RegWrite(0x01);
	ldi R16,1
	xcall _LCD_RegWrite
	.dbline 154
;       LCD_RegWrite(0x10);
	ldi R16,16
	xcall _LCD_RegWrite
	.dbline 155
;       for(j=0;j<=GLCD_WIDTH;j++)
	clr R12
	xjmp L23
L20:
	.dbline 156
	.dbline 157
	mov R16,R10
	xcall _LCD_DataWrite
	.dbline 158
L21:
	.dbline 155
	inc R12
L23:
	.dbline 155
	ldi R24,128
	cp R24,R12
	brsh L20
	.dbline 159
L17:
	.dbline 150
	inc R22
L19:
	.dbline 150
	cp R20,R22
	brsh L16
	.dbline -2
L15:
	xcall pop_gset4
	.dbline 0 ; func end
	ret
	.dbsym r uiTemp 20 c
	.dbsym r i 22 c
	.dbsym r j 12 c
	.dbsym r Data 10 c
	.dbend
	.dbfunc e glcd_init _glcd_init fV
	.even
_glcd_init::
	.dbline -1
	.dbline 180
;       {
;          LCD_DataWrite(Data);
;       }
;    }
; }
; //========================================================================
; // 函数: void LCD_Init(void)
; // 描述: LCD初始化程序，在里面会完成LCD初始所需要设置的许多寄存器，具体如果
; //       用户想了解，建议查看DataSheet当中各个寄存器的意义
; // 参数: 无 
; // 返回: 无
; // 备注:
; // 版本:
; //      2006/10/15      First version
; //      2007/01/09      V1.2
; //      2007/06/27      V1.21 
; //========================================================================
; 
; 
; // Purpose:       Initialize the LCD.
; //                Call before using any other LCD function.
; // Inputs:        OFF - Turns the LCD off
; //                ON  - Turns the LCD on
; void glcd_init(void)
; {
	.dbline 183
;    //LCD驱动所使用到的端口的初始化（如果有必要的话）
; //   delay_us(200);
;    RES_L;
	cbi 0x15,3
	.dbline 185
; //   delay_us(200);
;    RES_H;
	sbi 0x15,3
	.dbline 188
; //   delay_us(20);
;    
;    LCD_RegWrite(0xaf); //LCD On
	ldi R16,175
	xcall _LCD_RegWrite
	.dbline 189
;    LCD_RegWrite(0x2f); //设置上电控制模式
	ldi R16,47
	xcall _LCD_RegWrite
	.dbline 190
;    LCD_RegWrite(0x81); //电量设置模式（显示亮度）
	ldi R16,129
	xcall _LCD_RegWrite
	.dbline 191
;    LCD_RegWrite(0x28); //指令数据0x0000~0x003f
	ldi R16,40
	xcall _LCD_RegWrite
	.dbline 192
;    LCD_RegWrite(0x24); //V5 内部电压调节电阻设置---27
	ldi R16,36
	xcall _LCD_RegWrite
	.dbline 194
;    //LCD_RegWrite(0x24); //V5 内部电压调节电阻设置---27
;    LCD_RegWrite(0xa1); //LCD 偏压设置a2
	ldi R16,161
	xcall _LCD_RegWrite
	.dbline 195
;    LCD_RegWrite(0xc8); //Com 扫描方式设置,反向
	ldi R16,200
	xcall _LCD_RegWrite
	.dbline 196
;    LCD_RegWrite(0xa0); //Segment 方向选择,正常
	ldi R16,160
	xcall _LCD_RegWrite
	.dbline 197
;    LCD_RegWrite(0xa4); //全屏点亮/变暗指令
	ldi R16,164
	xcall _LCD_RegWrite
	.dbline 198
;    LCD_RegWrite(0xa6); //正向反向显示控制指令
	ldi R16,166
	xcall _LCD_RegWrite
	.dbline 199
;    LCD_RegWrite(0xac); //关闭静态指示器
	ldi R16,172
	xcall _LCD_RegWrite
	.dbline 200
;    LCD_RegWrite(0x00); //指令数据
	clr R16
	xcall _LCD_RegWrite
	.dbline 201
;    LCD_RegWrite(0x40 +0); //设置显示起始行对应RAM
	ldi R16,64
	xcall _LCD_RegWrite
	.dbline 202
;    LCD_RegWrite(0xe0); //设置读写改模式
	ldi R16,224
	xcall _LCD_RegWrite
	.dbline 205
;    ////
;      
;    glcd_fillScreen(OFF);                // Clear the display
	clr R16
	xcall _glcd_fillScreen
	.dbline 207
;    
;    glcd_update();
	xcall _glcd_update
	.dbline -2
L24:
	.dbline 0 ; func end
	ret
	.dbend
	.dbfunc e glcd_update _glcd_update fV
;         uiTemp -> R20
;              i -> R22
;              j -> R10
	.even
_glcd_update::
	xcall push_gset3
	.dbline -1
	.dbline 215
;    //delay_ms(10);
; }
; 
; 
; // Purpose:    Update the LCD with data from the display arrays
; 
; void glcd_update()
; {
	.dbline 218
;    char i,j;
;    char uiTemp;
;    if(glcdhalf==0){
	lds R2,_glcdhalf
	tst R2
	brne L26
	.dbline 218
	.dbline 221
;      //uiTemp = GLCD_HEIGHT;
;      //uiTemp = uiTemp/8/2;
; 	 uiTemp=4;
	ldi R20,4
	.dbline 222
;      for(i=0;i<uiTemp;i++)                        //往LCD中填充初始化的显示数据
	clr R22
	xjmp L31
L28:
	.dbline 223
;      {
	.dbline 224
;         LCD_RegWrite(0xb0+i);
	mov R16,R22
	subi R16,80    ; addi 176
	xcall _LCD_RegWrite
	.dbline 225
;         LCD_RegWrite(0x00);
	clr R16
	xcall _LCD_RegWrite
	.dbline 226
;         LCD_RegWrite(0x10);
	ldi R16,16
	xcall _LCD_RegWrite
	.dbline 227
;         for(j=0;j<=GLCD_WIDTH;j++)
	clr R10
	xjmp L35
L32:
	.dbline 228
	.dbline 229
	ldi R24,4
	mul R24,R10
	movw R2,R0
	ldi R24,<_LCD_Buffer
	ldi R25,>_LCD_Buffer
	add R2,R24
	adc R3,R25
	mov R30,R22
	clr R31
	add R30,R2
	adc R31,R3
	ldd R16,z+0
	xcall _LCD_DataWrite
	.dbline 230
L33:
	.dbline 227
	inc R10
L35:
	.dbline 227
	ldi R24,128
	cp R24,R10
	brsh L32
	.dbline 231
L29:
	.dbline 222
	inc R22
L31:
	.dbline 222
	cp R22,R20
	brlo L28
	.dbline 232
;         {
;           LCD_DataWrite(LCD_Buffer[j][i]);
;         }
;      }
;    }
	xjmp L27
L26:
	.dbline 233
;    else{
	.dbline 235
;      //uiTemp = GLCD_HEIGHT;
;      uiTemp = 4;
	ldi R20,4
	.dbline 236
;      for(i=0;i<uiTemp;i++)                        //往LCD中填充初始化的显示数据
	clr R22
	xjmp L39
L36:
	.dbline 237
;      {
	.dbline 238
;         LCD_RegWrite(0xb0+i+4);//页地址
	mov R16,R22
	subi R16,76    ; addi 180
	xcall _LCD_RegWrite
	.dbline 239
;         LCD_RegWrite(0x00);//列起始地址
	clr R16
	xcall _LCD_RegWrite
	.dbline 240
;         LCD_RegWrite(0x10);
	ldi R16,16
	xcall _LCD_RegWrite
	.dbline 241
;         for(j=0;j<=GLCD_WIDTH;j++)
	clr R10
	xjmp L43
L40:
	.dbline 242
	.dbline 243
	ldi R24,4
	mul R24,R10
	movw R2,R0
	ldi R24,<_LCD_Buffer
	ldi R25,>_LCD_Buffer
	add R2,R24
	adc R3,R25
	mov R30,R22
	clr R31
	add R30,R2
	adc R31,R3
	ldd R16,z+0
	xcall _LCD_DataWrite
	.dbline 244
L41:
	.dbline 241
	inc R10
L43:
	.dbline 241
	ldi R24,128
	cp R24,R10
	brsh L40
	.dbline 245
L37:
	.dbline 236
	inc R22
L39:
	.dbline 236
	cp R22,R20
	brlo L36
	.dbline 246
L27:
	.dbline -2
L25:
	xcall pop_gset3
	.dbline 0 ; func end
	ret
	.dbsym r uiTemp 20 c
	.dbsym r i 22 c
	.dbsym r j 10 c
	.dbend
	.dbfunc e glcd_pixel _glcd_pixel fV
;          color -> y+4
;              y -> R20
;              x -> R22
	.even
_glcd_pixel::
	xcall push_gset2
	mov R20,R18
	mov R22,R16
	.dbline -1
	.dbline 256
;         {
;           LCD_DataWrite(LCD_Buffer[j][i]);
;         }
;      }
;    }	 
; }
; 
; 
; 
; // Purpose:    Turn a pixel on a graphic LCD on or off
; // Inputs:     1) x - the x coordinate of the pixel
; //             2) y - the y coordinate of the pixel
; //             3) color - ON or OFF
; void glcd_pixel(char x, char y, char color)
; {
	.dbline 257
;    if(glcdhalf==0){
	lds R2,_glcdhalf
	tst R2
	breq X0
	xjmp L45
X0:
	.dbline 257
	.dbline 258
;      if(y/8<4){
	mov R24,R20
	lsr R24
	lsr R24
	lsr R24
	cpi R24,4
	brlo X1
	xjmp L46
X1:
	.dbline 258
	.dbline 259
; 	   if(color==1){
	ldd R24,y+4
	cpi R24,1
	brne L49
	.dbline 259
	.dbline 260
;           SETBIT(LCD_Buffer[x][y/8], y%8);
	ldi R24,4
	mul R24,R22
	movw R2,R0
	ldi R24,<_LCD_Buffer
	ldi R25,>_LCD_Buffer
	add R2,R24
	adc R3,R25
	ldi R18,8
	ldi R19,0
	mov R16,R20
	clr R17
	xcall div16s
	movw R4,R16
	add R4,R2
	adc R5,R3
	ldi R17,8
	mov R16,R20
	xcall mod8u
	mov R17,R16
	ldi R16,1
	xcall lsl8
	movw R30,R4
	ldd R2,z+0
	or R2,R16
	std z+0,R2
	.dbline 261
;        }
	xjmp L46
L49:
	.dbline 262
;        else{
	.dbline 263
;           CLRBIT(LCD_Buffer[x][y/8], y%8);
	ldi R24,4
	mul R24,R22
	movw R2,R0
	ldi R24,<_LCD_Buffer
	ldi R25,>_LCD_Buffer
	add R2,R24
	adc R3,R25
	ldi R18,8
	ldi R19,0
	mov R16,R20
	clr R17
	xcall div16s
	movw R4,R16
	add R4,R2
	adc R5,R3
	ldi R17,8
	mov R16,R20
	xcall mod8u
	mov R17,R16
	ldi R16,1
	xcall lsl8
	mov R2,R16
	com R2
	movw R30,R4
	ldd R3,z+0
	and R3,R2
	std z+0,R3
	.dbline 264
;        }
	.dbline 265
; 	 }  
	.dbline 266
;    }
	xjmp L46
L45:
	.dbline 267
;    else{
	.dbline 268
;      if(y/8>3){
	ldi R24,3
	mov R2,R20
	lsr R2
	lsr R2
	lsr R2
	cp R24,R2
	brlo X2
	xjmp L51
X2:
	.dbline 268
	.dbline 269
; 	   if(color==1){
	ldd R24,y+4
	cpi R24,1
	brne L53
	.dbline 269
	.dbline 270
;           SETBIT(LCD_Buffer[x][y/8-4], y%8);
	ldi R24,4
	mul R24,R22
	movw R2,R0
	ldi R24,<_LCD_Buffer
	ldi R25,>_LCD_Buffer
	add R2,R24
	adc R3,R25
	ldi R18,8
	ldi R19,0
	mov R16,R20
	clr R17
	xcall div16s
	movw R24,R16
	sbiw R24,4
	add R24,R2
	adc R25,R3
	movw R2,R24
	ldi R17,8
	mov R16,R20
	xcall mod8u
	mov R17,R16
	ldi R16,1
	xcall lsl8
	movw R30,R2
	ldd R4,z+0
	or R4,R16
	std z+0,R4
	.dbline 271
;        }
	xjmp L54
L53:
	.dbline 272
;        else{
	.dbline 273
;           CLRBIT(LCD_Buffer[x][y/8-4], y%8);
	ldi R24,4
	mul R24,R22
	movw R2,R0
	ldi R24,<_LCD_Buffer
	ldi R25,>_LCD_Buffer
	add R2,R24
	adc R3,R25
	ldi R18,8
	ldi R19,0
	mov R16,R20
	clr R17
	xcall div16s
	movw R24,R16
	sbiw R24,4
	add R24,R2
	adc R25,R3
	movw R2,R24
	ldi R17,8
	mov R16,R20
	xcall mod8u
	mov R17,R16
	ldi R16,1
	xcall lsl8
	mov R4,R16
	com R4
	movw R30,R2
	ldd R5,z+0
	and R5,R4
	std z+0,R5
	.dbline 274
;        }
L54:
	.dbline 275
; 	 }  
L51:
	.dbline 276
L46:
	.dbline -2
L44:
	xcall pop_gset2
	.dbline 0 ; func end
	ret
	.dbsym l color 4 c
	.dbsym r y 20 c
	.dbsym r x 22 c
	.dbend
	.dbfunc e glcd_fillScreen _glcd_fillScreen fV
;              i -> R20
;              j -> R22
;          color -> R16
	.even
_glcd_fillScreen::
	xcall push_gset2
	.dbline -1
	.dbline 284
;    } 
; }
; 
; 
; // Purpose:    Fill the LCD screen with the passed in color
; // Inputs:     ON  - turn all the pixels on
; //             OFF - turn all the pixels off
; void glcd_fillScreen(char color)
; {
	.dbline 286
;    char i,j;
;    if(color==1){
	cpi R16,1
	brne L56
	.dbline 286
	.dbline 287
;      for(i=0;i<GLCD_WIDTH;i++)
	clr R20
	xjmp L61
L58:
	.dbline 288
;        for(j=0;j<4;j++)//  /2是因为分上下两屏
	clr R22
	xjmp L65
L62:
	.dbline 289
	ldi R24,4
	mul R24,R20
	movw R2,R0
	ldi R24,<_LCD_Buffer
	ldi R25,>_LCD_Buffer
	add R2,R24
	adc R3,R25
	mov R30,R22
	clr R31
	add R30,R2
	adc R31,R3
	ldi R24,255
	std z+0,R24
L63:
	.dbline 288
	inc R22
L65:
	.dbline 288
	cpi R22,4
	brlo L62
L59:
	.dbline 287
	inc R20
L61:
	.dbline 287
	cpi R20,128
	brlo L58
	.dbline 290
;          LCD_Buffer[i][j]=0xFF;
;    }		 
	xjmp L57
L56:
	.dbline 291
;    else{
	.dbline 292
;      for(i=0;i<GLCD_WIDTH;i++)
	clr R20
	xjmp L69
L66:
	.dbline 293
;        for(j=0;j<4;j++)//  GLCD_HEIGHT/8/2   /2是因为分上下两屏
	clr R22
	xjmp L73
L70:
	.dbline 294
	ldi R24,4
	mul R24,R20
	movw R2,R0
	ldi R24,<_LCD_Buffer
	ldi R25,>_LCD_Buffer
	add R2,R24
	adc R3,R25
	mov R30,R22
	clr R31
	add R30,R2
	adc R31,R3
	clr R2
	std z+0,R2
L71:
	.dbline 293
	inc R22
L73:
	.dbline 293
	cpi R22,4
	brlo L70
L67:
	.dbline 292
	inc R20
L69:
	.dbline 292
	cpi R20,128
	brlo L66
	.dbline 295
L57:
	.dbline -2
L55:
	xcall pop_gset2
	.dbline 0 ; func end
	ret
	.dbsym r i 20 c
	.dbsym r j 22 c
	.dbsym r color 16 c
	.dbend
	.area bss(ram, con, rel)
	.dbfile E:\avr\iccavrproject\电池容量测试\mzl05.c
_LCD_Buffer::
	.blkb 512
	.dbsym e LCD_Buffer _LCD_Buffer A[512:128:4]c
_glcdhalf::
	.blkb 1
	.dbsym e glcdhalf _glcdhalf c
