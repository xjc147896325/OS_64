#include "lib.h"
#include "printk.h"
#include "gate.h"				 
#include "trap.h"				 
#include "memory.h"		
		   
struct Global_Memory_Descriptor memory_management_struct = {{0},0};

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

	
	load_TR(8);
	
	set_tss64(0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00);
	sys_vector_init();
	
	color_printk(RED, BLACK, "memory init xjc by 2021/03/02\n");
	init_memory();
	while(1);
}