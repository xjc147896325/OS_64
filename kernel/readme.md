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

fat32.inc 里的BS_FileSysType写错