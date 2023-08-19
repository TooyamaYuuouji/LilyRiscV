#!/usr/bin/python

# 将inst.data的数据读入.vvp文件，并运行

import subprocess
import sys

from defines import *


def main():
    vvp_cmd = ['vvp']
    vvp_cmd.append(OUT_FILE_PATH)
    process = subprocess.Popen(vvp_cmd)
    try:
        process.wait(timeout=10)
    except:
        print('Error: vvp timeout!')


if __name__ == '__main__':
    sys.exit(main())