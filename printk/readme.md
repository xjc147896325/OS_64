#2020/12/23

.section .data
类似于[Section .data]定义该段位.data

.quad定义后续为4字(8字节)，64bit

.fill 

     语法：.fill repeat, size, value

     含义是反复拷贝 size个字节，重复 repeat 次，

         其中 size 和 value 是可选的，默认值分别为 1 和 0.

#12/26
今天测了，有问题，试了下例程，无问题，具体的明天再改了 
#12/27
确认了，loader的问题。会出现no kernel
cx寄存器的值不对,越界打印.

fat32.inc 里的BS_FileSysType写错
#12/28

确定了。是我自己加的那段打印有问题。

基本测试完成，目前与例程没区别。

目前到4.3 这几天很划

#21/01/01
head.S的globl写错了

没调完，调不动了，打游戏去了

#21/01/28
问题大致找到了 是kernel里的main函数地址的问题 逻辑没问题但是好像内存的对应不对


    [0x000000100125] 0008:0000000000100125 (unk. ctxt): jmp .-2 (0x0000000000100125) ; ebfe

应该是
    
    [0x000000104004] 0008:ffff800000104004 (unk. ctxt): jmp .-2(0xffff800000104004) ; ebfe

初步怀疑是连接阶段的问题 或者是加载是加载的内存不对


试了试书后的源码，有问题，编译都过不了

gcc版本有问题。。。

#21/01/31 22:13

完事了 傻逼作者TMDmakefile写错了，gcc的 编译改stdout不能单纯修改大小写，否则会当成一个文件。已解决！

#2021/02/28 

冷静下来 gcc版本很重要 今天Makefile又是再printk里的gcc编译报错“undefined reference to `__stack_chk_fail'” 栈保护问题。将gcc编译选项改为 -fno-stack-protector 编译可通过 待测试。

已测试，OK的。

