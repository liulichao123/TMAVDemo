//
//  CommonTool.m
//  TMAVDemo
//
//  Created by 天明 on 2017/8/3.
//  Copyright © 2017年 天明. All rights reserved.
//

#import "CommonTool.h"

@implementation CommonTool
//MARK: 大小端检测
int checkBigLittle() {
    short int x;
    char x0, x1;
    x = 0x1122;
    x0 = *((char *)&x);          //把x的低位地址的值赋给x0;
    x1 = *((char *)&x + 1);      //把x的高位地址的值赋给x1;
    if( x0 == 0x11 && x1 == 0x22)
        printf(" This is big-endian \n");
    else if( x0 == 0x22 && x1 == 0x11)
        printf("This is little-endian \n");
    else
        printf("呵呵,你这个方法有误啊\n");
    return 0;
}

//MARK: 将十六进制的数转换成double型(带有大端转小端)
double hexToDouble(unsigned char * rs) {
    char cValue[8];
    char temp;
    //小端反转
    memcpy(&cValue, rs, 8);
    for (int i = 0; i < 4; i++) {
        temp =  cValue[i];
        cValue[i] = cValue[7-i];
        cValue[7-i] = temp;
    }
    double value = *((double*)cValue);
    return value;
}

//MARK: 将十六进制的数转换成double型 ------由于太过笨重未使用，可以直接利用 char *指针赋值
//十六进制转double辅助函数
unsigned int getbitu(const unsigned char *buff, int pos, int len)
{
    
    unsigned int bits=0;
    int i;
    for (i=pos;i<pos+len;i++)
    {
        bits=(bits<<1)+((buff[i/8]>>(7-i%8))&1u);
    }
    return bits;
}
//将十六进制的数转换成double型
double HexToDouble(const unsigned char* buf)
{
    
    double value = 0;
    unsigned int i = 0;
    unsigned int num,temp;
    int num2;
    bool flags1 = false;
    bool flags2 = false;
    
    num = getbitu(buf,i,1);             i += 1;
    num2 = getbitu(buf,i,11) - 1023;    i += 11;
    
    if(num2 >= 0)
    {
        flags2 = true;
        while(1)
        {
            flags1 = true;
            if(flags2)
            {
                flags2 = false;
                value += 1 * pow(2,num2); num2--;
            }
            
            temp = getbitu(buf,i,1);    i += 1;
            value += temp * pow(2,num2); num2--;
            if(num2 < 0 || i == 64);
            break;
        }
    }
    while(1)
    {
        if(flags1)
        {
            temp = getbitu(buf,i,1);    i += 1;
            value += temp * pow(2,num2); num2--;
        }
        else
        {
            flags1 = true;
            value += 1 * pow(2,num2); num2--;
        }
        
        if(i == 64)
            break;
    }
    
    if(num == 1)
        value *= -1;
    
    return value;
}
@end
