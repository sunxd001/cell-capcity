/////////////////////////////////////////////////////////////////////////
// Function Prototypes
/////////////////////////////////////////////////////////////////////////
void glcd_init(void);
void glcd_pixel(char x, char y, char color);
void glcd_fillScreen(char color);
void glcd_update(void);
/////////////////////////////////////////////////////////////////////////
#define GLCD_WIDTH   128
#define GLCD_HEIGHT      32

#define	SETBIT(x,y) (x|=(1<<y))      //set bit y in byte x
#define	CLRBIT(x,y) (x&=(~(1<<y)))   //clear bit y in byte x
#define	CHKBIT(x,y) (x&(1<<y))       //check bit y in byte x
