#!/usr/bin/python

import sys
import os

import tool.defines as defines


def main(isa_name):
    file_list = os.listdir(defines.OLD_ISA_PATH)
    source_file = None
    for file in file_list:
        name = file.split('.')[0]
        isa_name_temp = name.split('-')[-1]
        if isa_name_temp == isa_name:
            source_file = file
            break

    if source_file is None:
        print('ERROR !!!')
        print('don\'t find valid ISA sim file! Please check there\'s a valid ISA name as input argument!')
    else:
        source_file_path = os.path.join(defines.OLD_ISA_PATH, source_file)
        source_FH = open(source_file_path, 'r')
        buf = source_FH.read()
        source_FH.close()

        target_FH = open(defines.INST_DATA_FILE, 'w')
        target_FH.write(buf)
        target_FH.close()

        cmd = r'python ./tool/read_inst_data.py'
        # 使用管道执行命令
        pip = os.popen(cmd)
        print(pip.read())
        # vvp_cmd = ['vvp']
        # vvp_cmd.append(OUT_FILE_PATH)
        # process = subprocess.Popen(vvp_cmd)
        # try:
        #     process.wait(timeout=10)
        # except:
        #     print('Error: vpp timeout!')


if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))