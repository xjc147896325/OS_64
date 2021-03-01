#include "lib.h"
#include "printk.h"

void Start_Kernel(void)
{
	int* addr = (int*)0xffff800000a00000;
	int i = 0;
	

	Pos.XResolution = 1440;
	Pos.YResolution = 900;

	Pos.XPosition = 0;
	Pos.YPosition = 0;

	Pos.XCharSize = 8;
	Pos.YCharSize = 16;

	Pos.FB_addr = (int *)0xffff800000a00000; //帧缓存起始地址
	Pos.FB_length = (Pos.XResolution * Pos.YResolution * 4);//8*16个bit 4个BYTE

	for(i = 0; i < 20*1440; i++)
	{
		*((char*)addr + 0) = 0x00;
		*((char*)addr + 1) = 0x00;
		*((char*)addr + 2) = 0xff;
		*((char*)addr + 3) = 0x00;
		addr++;
	}
		
	for(i = 0; i < 20*1440; i++)
	{
		*((char*)addr + 0) = 0x00;
		*((char*)addr + 1) = 0xff;
		*((char*)addr + 2) = 0x00;
		*((char*)addr + 3) = 0x00;
		addr++;
	}
	
	for(i = 0; i < 20*1440; i++)
	{
		*((char*)addr + 0) = 0xff;
		*((char*)addr + 1) = 0x00;
		*((char*)addr + 2) = 0x00;
		*((char*)addr + 3) = 0x00;
		addr++;
	}	
	
	for(i = 0; i < 20*1440; i++)
	{
		*((char*)addr + 0) = 0xff;
		*((char*)addr + 1) = 0xff;
		*((char*)addr + 2) = 0xff;
		*((char*)addr + 3) = 0x00;
		addr++;
	}
	
	color_printk(GREEN,BLACK,"Hello\t\t XJC at 2021/02/28!\n");
	
	i = 1 / 0;
	
	while(1);
}