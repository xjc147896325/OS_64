#include "lib.h"
#include "printk.h"
#include "gate.h"				 
#include "trap.h"				 
#include "memory.h"		
#include "task.h"			
		   
/*
		static var 
*/

		 
struct Global_Memory_Descriptor memory_management_struct = {{0},0};

void Start_Kernel(void)
{
	int* addr = (int*)0xffff800000a00000;
	int i = 0;
	
	//struct Page * page = NULL;

	Pos.XResolution = 1440;
	Pos.YResolution = 900;

	Pos.XPosition = 0;
	Pos.YPosition = 0;

	Pos.XCharSize = 8;
	Pos.YCharSize = 16;

	Pos.FB_addr = (int *)0xffff800000a00000; //帧缓存起始地址
	Pos.FB_length = (Pos.XResolution * Pos.YResolution * 4 + PAGE_4K_SIZE - 1) & PAGE_4K_MASK;//8*16个bit 4个BYTE

	
	load_TR(8);
	
	set_tss64(_stack_start, _stack_start, _stack_start, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00, 0xffff800000007c00);	
	
	sys_vector_init();
	
	memory_management_struct.start_code = (unsigned long)& _text;
	memory_management_struct.end_code   = (unsigned long)& _etext;
	memory_management_struct.end_data   = (unsigned long)& _edata;
	memory_management_struct.end_brk    = (unsigned long)& _end;
	
	color_printk(RED, BLACK, "memory init xjc by 2021/03/02\n");
	init_memory();
	
	color_printk(RED, BLACK, "interrupt init \n");
	init_interrupt();
	
	color_printk(RED, BLACK, "task init \n");
	task_init();
	
	color_printk(RED, BLACK, "task init has done\n");
	while(1);
}