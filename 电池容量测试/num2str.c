#include "num2str.h"

void Num2Str(unsigned char str[],int Num,unsigned char len)
{
   unsigned char i=0;
   while(len--){
     str[len]=Num%10+0x30;
     Num=Num/10;
     i++;
   }
   str[i++]='\0';
}

unsigned int num_pow(unsigned char m,unsigned char n)
{
  unsigned int result=1;
  while(n--)result*=m;
  return result;
}

void Float2Str(unsigned char str[],float floa,unsigned char len1,unsigned char len2)
{
   unsigned char i=0,j=0;
   unsigned int zhengshu=floa;
   unsigned int xiaoshu=(floa-zhengshu)*num_pow(10,len2);
   while(len1--){
     str[len1]=zhengshu%10+0x30;
     zhengshu=zhengshu/10;
     i++;
   }
   str[i]='.';
   while(len2--)
   {
     str[i+len2+1]=xiaoshu%10+0x30;
     xiaoshu=xiaoshu/10;
     j++;
   }
   str[i+j+1]='\0';
}

