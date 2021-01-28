void Start_Kernel(void)
{
	int* addr = (int*)0xffff800000a00000;
	int i = 0;
	
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
	while(1);
}