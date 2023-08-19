#!/usr/bin/python

# 对LilyRiscv中的设计代码（rtl）进行编译，并在当前目录下生成.vvp文件
# 使用方式：
# $ python compile_rtl.py
# $
# 注意事项：

import os
import subprocess
import sys

from defines import *


def main():
    # 待编译文件
    core_path = os.path.join(MAIN_PATH, r'rtl/core')
    perips_path = os.path.join(MAIN_PATH, r'rtl/perips')
    soc_path = os.path.join(MAIN_PATH, r'rtl/soc')
    utils_path = os.path.join(MAIN_PATH, r'rtl/utils')

    # tb文件
    tb_path = os.path.join(MAIN_PATH, r'tb')

    # iverilog 程序
    iverilog_cmd = ['iverilog']
    # 支持 SystemVerilog
    iverilog_cmd += ['-g2005-sv']
    # 编译生成文件
    iverilog_cmd += ['-o', OUT_FILE_PATH]
    # 宏定义，仿真输出文件
    iverilog_cmd += ['-D', r'OUTPUT="signature.output"']
    # 确定头文件路径
    iverilog_cmd += ['-I', core_path]
    # tb 文件
    iverilog_cmd.append(tb_path + r'/top_tb_oi.sv')
    # core 文件夹
    iverilog_cmd.append(core_path + r'/ctrl.v')
    iverilog_cmd.append(core_path + r'/div.v')
    iverilog_cmd.append(core_path + r'/ex.v')
    iverilog_cmd.append(core_path + r'/id.v')
    iverilog_cmd.append(core_path + r'/id_ex.v')
    iverilog_cmd.append(core_path + r'/if_id.v')
    iverilog_cmd.append(core_path + r'/pc.v')
    iverilog_cmd.append(core_path + r'/regs.v')
    iverilog_cmd.append(core_path + r'/LilyRiscv.v')
    # perips 文件夹
    iverilog_cmd.append(perips_path + r'/ram.v')
    iverilog_cmd.append(perips_path + r'/rom.v')
    iverilog_cmd.append(perips_path + r'/rib.v')
    iverilog_cmd.append(perips_path + r'/uart.v')
    iverilog_cmd.append(perips_path + r'/gpio.v')
    # soc 文件夹
    iverilog_cmd.append(soc_path + r'/LilyRiscv_soc.v')
    # utils 文件夹
    iverilog_cmd.append(utils_path + r'/gen_diff.v')

    process = subprocess.Popen(iverilog_cmd)
    process.wait(timeout=5)


if __name__ == '__main__':
    sys.exit(main())