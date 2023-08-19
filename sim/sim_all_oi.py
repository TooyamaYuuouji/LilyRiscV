#!/usr/bin/python

import os

import tool.defines as defines


def main():
    file_list = os.listdir(defines.OLD_ISA_PATH)
    pass_num = 0
    fail_num = 0

    for file in file_list:
        name = file.split('.')[0]
        isa_name = name.split('-')[-1]

        cmd = r'python sim_single_oi.py' + ' ' + isa_name
        # 使用管道执行命令
        pip = os.popen(cmd)
        r = pip.read()
        if r.find('TEST_PASS') != -1:
            pass_num += 1
            print('ISA: ', isa_name.ljust(10, ' '), 'PASS')
        else:
            fail_num += 1
            print('ISA: ', isa_name.ljust(10, ' '), '*** FAIL ***')
        pip.close()

    print(60*'-')
    print('Summary: pass number =', pass_num, '\t', 'fail number =', fail_num)


if __name__ == '__main__':
    main()