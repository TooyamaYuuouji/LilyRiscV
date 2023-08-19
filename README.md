# LilyRiscv

## 文件结构
+ sim：和仿真有关的脚本等文件
    + tool/defines.py：供其他py文件使用的变量
    + tool/compile_rtl.py：使用iverilog编译rtl代码，并生成vvp文件供仿真使用
    <!-- + tool/bin2hex.py：将二进制文件改为十六进制文件供vvp文件使用 -->
    + sim_single_oi.py：调用vvp文件，使用old_isa中的单个文件进行仿真
    + sim_all_oi.py：调用vvp文件，使用所有old_isa中的文件进行仿真
    + Makefile：脚本
    <!-- + sim_single_arch.py：调用vvp文件，使用riscv-arch-test中的文件进行仿真 -->

## 仿真
注意：所有的仿真过程都依赖于sim文件夹下的inst_data.txt文件，即生成十六进制的机器码后存入inst_data.txt，tb中的DUT读取该inst_data.txt的内容

## BUG
内部线似乎有点问题（？），与外部设备的交互不顺利（LS部分指令的执行没达到预期，可能是汇编翻译为机器码的过程没做好），暂时搁置