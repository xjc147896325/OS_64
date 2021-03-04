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




#2021/03/02

内存查询 2M*1022
![avatar](.\123.png)

#2021/03/03
解释一下1022怎么来的，首先是统计RAM，也就是type=1.其次2M对其，就是1ul<<11即2的21次方，2048。所以第一个RAM不满足，因为器不满2M（651264 < 1048576）。所以就是第二个RAM，length = 7fef0000，后面f0000，20位，还差一位，所以7fe右移1位，即3fe，即1022。

后面bits_map那个和这个算法不一样。吃个饭回来再写。

**bits_map：**

bits_map与memory_management_struct.end_brk有关，end_brk等于_end，这是lds链接文件里的变量，在bss后。

TotalMem在上面显示后重置了，是从地址0到最后的1的结束地址，本次为7fff0000。memory_management_struct.pages_size = TotalMem >> PAGE_2M_SHIFT。bits_size， 即bits_map的大小， 其大小为最后一块可用内存地址/ 每一页的大小， 即：所有内存划分为页的页数。右移21位，为1111111111（bin），**u1s1不知道为啥变成0x800了**(4号解释了)，莫名其妙+了1。length是0x100不解释了吧，8位一字节。懂啥意思8，前面的地址，一共0x800（2048）页的空间（单位是bit），一个对应一比特，一共0x100字节。

**page：**

下面的page在其之后，顺应地址加上0x100，但是为啥加了0x1000?**悟了！！！！！！！4K对齐！！0x100（256）省略了，4k是0x1000！！！！！！（对了嗷，之前是因为csdn那个没有4k对齐，后续补上了）**pages_size也是800个2M，也就是800个page，一个page结构体占4个long一个指针地址，一共40字节。

**zone：**
zone的地址同样加起来，zones_size初始化为0，后面在处理时有自加，后面初始化zone时第一个因为不满2M字节舍去，第二个满足，所以zone_zise为1。zones_length初始化时为5个size，后面在统计完size后会处理回来，变成一个，最终是80字节（0x50）。

zone的起始地址为第三个内存块（第二个type1）以2M对齐，所以是0x200000，结束为内存块起始地址加上长度然后2M对齐。length一减然后2M对齐。pages_group（struct page结构体数组指针）为 基地址+起点所在页的数量[说实话没咋懂（现在懂了8）]，提示：3fe＝1022，不用解释了8。start_code，end_code，end_data，end_brk对应链接脚本里的几个段。

得到GDT即cr3里的地址，后面指来指去。


    *(memory_management_struct.bits_map + ((p->PHY_address >> PAGE_2M_SHIFT) >> 6)) ^= 1UL << (p->PHY_address >> PAGE_2M_SHIFT) % 64;


重复1022次

**解释1：**把当前struct page结构体所代表的物理地址转换成bits_map映射位图中对应的位。这里的bits_map之中，每个变量都是一个unsigned long 类型的 64位整数每一位可以表示该位所对应的page是否使用


**解释2：**会把当前struct page结构体所代表的物理地址转换成bits_map映射位图
中对应的位。由于此前已将bits_map映射位图全部置位，那么此刻再将可用物理页对应的位和1执行异或操作，以将对应的可用物理页标注为未被使用。

**main函数里的那2个bits_map的意思：**很关键，首先，一个bits_map是64个page（8字节），一共有32个（32*8=256字节）。

缕完了啊，全完事了。附：[https://blog.csdn.net/qq_17853613/article/details/109635180](https://blog.csdn.net/qq_17853613/article/details/109635180 "参考")

![avatar](.\234.png)



#2021/03/04

现在是12:25,我已经傻逼了很久了。

引用下csdn那个：
> 这里大家可能存在一个疑问：为什么这里统计出来有2048页，上面统计出来有1022页?有这个疑问的人一看就是前面没仔细看�，前面在统计页数的时候，统计的是可用的页数。这里在记录页数的时候，统计方法是可用地址的最后一块的地址 / 每一页的大小，两种统计方法完全不同。

看下图，首先memory_management_struct.e820_length这个**不是第二个type1！！！**是最后一个可用地址.这就是为啥是2048而不是1022。懂了么。后面的0x100就不多说了吧。基本初始化部分理清了。但是bits_map的赋值，清零还没咋太理解。

![avatar](.\345.png)