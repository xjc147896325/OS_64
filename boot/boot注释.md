

 1行： 
- 
后续程序放在0x7c00处(汇编伪指令baiORG作用是定义程序或du数据块的起始地址，指zhi示此语句后面dao的程序或数zhuan据块以nn为起始地址连续存放在shu程序存储器中。
ORG是Origin的缩写：起始地址，源。在汇编语言源程序的开始通常都用一条ORG伪指令来实现规定程序的起始地址。如果不用ORG规定则汇编得到的目标程序将从0000H开始。)

3~11行：
-
助记符(EQU 伪指令把一个符号名称与一个整数表达式或一个任意文本连接起来，它有 3 种格式：

1. name EQU expression
1. name EQU symbol
1. name EQU <text>)

BaseOfLoader基址和OffsetOfLoader偏移量组成起始物理地址为BaseOfLoader << 4 + OffsetOfLoader = 0x10000

RootDirSectors为根目录所占用扇区数，(BPB_RootEntCnt * 32 + BPB_BytesPerSec - 1) / BPB_BtyesPerSec = (224 * 32 + 512 - 1) / 512 = 14

SectorNumOfRootDirStart为根目录起始扇区号，为保留扇区 + FAT表扇区数*FAT表份数 = 1 + 9 * 2 = 19

SectorNumOfFAT1Srart表示FAT1的起始扇区号，在FAT1前只有一个保留扇区(引导扇区)，其扇区号为0。

SectorBalance 用于平衡文件(或者目录)起始簇号与数据区起始簇号差值。

13~33行:
-
15~33会写道img里作为FAT12文件系统的引导扇区，nop是为了凑够三个字节

 BS_OEMName。记录制造商的名字，亦可自行为文件系统命名。

 BPB_SecPerClus。描述了每簇扇区数。由于每个扇区的容量只有512 B，过小的扇区容量可
能会导致软盘读写次数过于频繁，从而引入簇（ Cluster）这个概念。簇将2的整数次方个扇区
作为一个“原子”数据存储单元，也就是说簇是FAT类文件系统的最小数据存储单位。

 BPB_RsvdSecCnt。指定保留扇区的数量，此域值不能为0。保留扇区起始于FAT12文件系统
的第一个扇区，对于FAT12而言此位必须为1，也就意味着引导扇区包含在保留扇区内，所以
FAT表从软盘的第二个扇区开始。

 BPB_NumFATs。指定FAT12文件系统中FAT表的份数，任何FAT类文件系统都建议此域设置为
2。设置为2主要是为了给FAT表准备一个备份表，因此FAT表1与FAT表2内的数据是一样的，
FAT表2是FAT表1的数据备份表。

 BPB_RootEntCnt。指定根目录可容纳的目录项数。对于FAT12文件系统而言，这个数值乘以
32必须是BPB_BytesPerSec的偶数倍。

 BPB_TotSec16。记录着总扇区数。这里的总扇区数包括保留扇区（内含引导扇区）、 FAT表、根
目录区以及数据区占用的全部扇区数，如果此域值为0，那么BPB_TotSec32字段必须是非0值。

 BPB_Media。描述存储介质类型。对于不可移动的存储介质而言，标准值是0xF8。对于可移
动的存储介质，常用值为0xF0，此域的合法值是0xF0、 0xF8、 0xF9、 0xFA、 0xFB、 0xFC、
0xFD、 0xFE、 0xFF。另外提醒一点，无论该字段写入了什么数值，同时也必须向FAT[0]的低
字节写入相同值。

 BPB_FATSz16。记录着FAT表占用的扇区数。 FAT表1和FAT表2拥有相同的容量，它们的容量
均由此值记录。

 BS_VolLab。指定卷标。它就是Windows或Linux系统中显示的磁盘名。

 BS_FileSysType。描述文件系统类型。此处的文件系统类型值为'FAT12 '，这个类型值只
是一个字符串而已，操作系统并不使用该字段来鉴别FAT类文件系统的类型。

35~82行:
-
启动程序:

37~41 搞搞寄存器，把sp(堆栈指针寄存器)指到0x7c00

45~50 按理说48~50应该不执行的，但是实际使用好像执行了 int10h，ah = 6h

56~59 设置光标 int10h，ah = 2h

63~73 设置显示信息 int10h，ah=13h

77~78 复位软盘 清空ah和dl
		
82    把起始扇区号写到SectorNo的地址里

84~98：
-
Label_Search_In_Boot_Dir_Begin:

比较循环次数是否为0，为0时跳转到Label_No_LoaderBin，
否则，继续执行，将[RootDirSizeForLoop]-1。

# <font color = 'green'><b>不跳转 ：</b></font>#

把es赋0，bx赋8000h，ax给SectorNumOfRootDirStart，cl赋1
***call Func_ReadOneSector***



----------
194行~222行：
-

**196~212：**

把基址指针寄存器(BP)压栈，把堆栈指针寄存器(SP)放到放到BP，把esp减2，把cl(1)给[BP(SP) - 2]，把bx(8000h)压栈，把bl赋每磁道扇区数，ax/bl，结果在al，余数为ah，把余数自加1放到cl，把商放到dh，al右移1位，把其放到ch里，让dh与0x01做与，bx出栈恢复，将int 13h的驱动器号(BS_DrvNum)。

**214~222：**

将2移至ah，把[BP(SP) - 2] (1)给al，触发13h中断(读扇区，出口参数：CF＝0——操作成功，AH＝00H，AL＝传输的扇区数，否则，AH＝状态代码，ES:BX＝缓冲区的地址)，jc(当运算产生进位标志时，即CF=1时，跳转到目标程序处。 )读完无事发生，出问题重来。sp+2，bp出栈

ret，回call那。

> 模块Func_ReadOneSector在读取软盘之前，会先保存栈帧寄存器和栈寄存器的数值，从栈中
> 开辟两个字节的存储空间（将栈指针向下移动两个字节），由于此时代码bp – 2与ESP寄存器均指向
> 同一内存地址，所以CL寄存器的值就保存在刚开辟的栈空间里。而后，使用AX寄存器（待读取的磁
> 盘起始扇区号）除以BL寄存器（每磁道扇区数），计算出目标磁道号（商： AL寄存器）和目标磁道内
> 的起始扇区号（余数： AH寄存器），考虑到磁道内的起始扇区号从1开始计数，故此将余数值加1，即
> inc ah。紧接着，再按照公式(3-1)计算出磁道号（也叫柱面号）与磁头号，将计算结果保存在对应
> 寄存器内。最后，执行INT 13h中断服务程序从软盘扇区读取数据到内存中，当数据读取成功（ CF标
> 志位被复位）后恢复调用现场。

----------

**95行~98行：**
将LoaderFileName放到si(源变址寄存器,常保存存储单元地址)里，
8000h放到di(目的变址寄存器,常保存存储单元地址)里，CLD(cld使DF 复位，即是让DF=0)，然后将10h放dx里。dx为512/32 为每个扇区可容纳目录项数。【32还没搞懂】

100行~105行:
-

将dx与0比较，如果正常执行到这无问题，不会跳转，跳转到这可能会再次跳转。

dx自减。将11(LOADER  BIN)赋给cx，

107行~116行:
-
如果cx为0(全部匹配)进入Label_FileName_Found，否则继续执行。

cx自减，lodsb(LODSB/LODSW是块装入指令，其具体操作是把SI指向的存储单元读入累加器,LODSB就读入AL，然后SI自动增加或减小1或2)，此时al为LOADER的名字的地址，es:bs为读出来的存放的内存的地址，218行最后使用过，不是上面的。

如果一样零位置一，进入jz的Label_Go_On，否则进入Label_Different。

**Label_Go_On：**

di自加1，继续检测下一个字符，如果全部相同且扇区没检测完，进入Label_FileName_Found。
> 特别注意，因为FAT12文件系统的文件名是不区分大小写字母的，即使将小写字母命名的文件复
制到FAT12文件系统内，文件系统也会为其创建大写字母的文件名和目录项。而小写字母文件名只作
为其显示名，真正的数据内容皆保存在大写字母对应的目录项。所以这里应该搜索大写字母的文件名
字符串。

----------
152行~164行:
-

> 在Label_FileName_Found模块中，程序会先取得目录项DIR_FstClus字段的数值，并通过配置
> ES寄存器和BX寄存器来指定loader.bin程序在内存中的起始地址，再根据loader.bin程序的起始簇号计
> 算出其对应的扇区号。为了增强人机交互效果，此处还使用BIOS中断服务程序INT 10h在屏幕上显示
> 一个字符'.'。接着，每读入一个扇区的数据就通过Func_GetFATEntry模块取得下一个FAT表项，
> 并 跳 转 至Label_Go_On_Loading_File处 继 续 读 入 下 一 个 簇 的 数 据 ， 如 此 往 复 ， 直 至Func_
> GetFATEntry模块返回的FAT表项值是0fffh为止。当loader.bin文件的数据全部读取到内存后，跳转
> 至Label_File_Loaded处准备执行loader.bin程序。


**Label_FileName_Found:**

将RootDirSectors(根目录所占用扇区数)，将找到的扇区地址放到cx(具体操作，and和add那两步还不懂)，将cx进栈，

> 在Label_FileName_Found模块中，程序会先取得目录项DIR_FstClus字段的数值，并通过配置
ES寄存器和BX寄存器来指定loader.bin程序在内存中的起始地址，再根据loader.bin程序的起始簇号计
算出其对应的扇区号。

【这段没咋看懂 暂时搁置，待更新】

166行~187行:
-

**Label_Go_On_Loading_File:**

将ax、bx压栈，ah = 0eh为显示字符(光标前移)，显示字符'%'，增强交互，然后恢复ax，bx。将1赋给cl，call Func_ReadOneSector


----------

----------
194行~212行:
-
**Func_ReadOneSector:**

将bp(基址指针寄存器)压栈，将sp(堆栈指针寄存器)给bp，将sp-2，下一条指令。将cl(1)给sp-2地址。妈个鸡，前面有，看前面去。

214~222行:
-
**Label_Go_On_Reading:**

同样见前，不成功继续读，成功返回。

----------

----------

**177行开始:**

将ax出栈，调用(call)Func_GetFATEntry


----------

----------
226行~241行:
-
**Func_GetFATEntry:**


> 使用Func_GetFATEntry模块可根据当前FAT表项索引
> 出下一个FAT表项，该模块的寄存器参数说明如下。
> 模块Func_GetFATEntry 功能：根据当前FAT表项索引出下一个FAT表项。
>  AH=FAT表项号（输入参数/输出参数）。
> 这段程序首先会保存FAT表项号，并将奇偶标志变量（变量[odd]）置0。因为每个FAT表项占
> 1.5 B，所以将FAT表项乘以3除以2（扩大1.5倍），来判读余数的奇偶性并保存在[odd]中（奇数为1，
> 偶数为0），再将计算结果除以每扇区字节数，商值为FAT表项的偏移扇区号，余数值为FAT表项在
> 扇区中的偏移位置。接着，通过Func_ReadOneSector模块连续读入两个扇区的数据，此举的目的
> 是为了解决FAT表项横跨两个扇区的问题。最后，根据奇偶标志变量进一步处理奇偶项错位问题，
> 即奇数项向右移动4位。有能力的读者可自行将FAT12文件系统替换为FAT16文件系统，这样可以简
> 化FAT表项的索引过程。


将es、bx、ax压栈，ax赋0，es赋0(只能间接操作)。ax出栈恢复，将Odd赋0，恢复。将bx赋3，乘，赋2，除，如果为偶数则进入Label_Even，Odd为0。否则Odd为1.

**Label_Even：**

清空dx，将BPB_BytesPersec(每扇区字节数)加载bx，做除法，将余数入栈。商值为FAT表项的偏移扇区号，余数值为FAT表项在
扇区中的偏移位置。加上SectorNumOfFAT1Srart(起始扇区号)后连续读入2个扇区。dx出栈，将偏移量加到bx，将其读出的内容的地址给ax，比较Odd是否为1，如果不是则跳转到Label_Even_2。否则向右移动4位。将ax与12位1与一下，得到fat表项，然后bx、es出栈，返回。

----------

----------

**180行：**

如果fat表表项为0fffh，则表示读完了，进入Label_File_Loaded，死循环，待后续loader。<font color = 'red'>当前程序结束。</font>

如果不是则将ax压栈，RootDirSectors(根目录所占用扇区数)放至dx，然后fat表项加dx，加SectorBalance(扇区平衡数)，bx加512(每个扇区字节数)，跳转到Label_Go_On_Loading_File，重复调用自己。


----------

**继续116行，进入Label_Different：**

di(目的变址寄存器,常保存存储单元地址)，存入的目前是读入的内存的偏移值，这波与和加没看懂【125、126】。将文件名重新加载到SI(源变址寄存器,常保存存储单元地址)，因为lodsb会改变SI。跳转回100行，继续找。

如果超过16次则进入下一个扇区找，进入Label_Goto_Next_Sector_In_Root_Dir。

130行~133行：
-
**Label_Goto_Next_Sector_In_Root_Dir：**

SectorNo加1，第一次就是根目录+1。跳转到84行继续搜索。

# <font color = 'green'><b>跳转 ：</b></font>#

137行~149行：
-
> 如果没有找到，那
> 么就执行其后的Label_No_LoaderBin模块，进而在屏幕上显示提示信息，通知用户引导加载程序
> 不存在。




至此，基本已完全注释。