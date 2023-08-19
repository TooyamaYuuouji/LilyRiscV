#!/usr/bin/python

import os
import subprocess

from defines import *


# 二级制文件转为十六进制文件
def bin2hex(source_file_path, target_file_path):
    binfile_FH = open(source_file_path, 'rb')
    bincontext = binfile_FH.read()
    binfile_FH.close()

    hexfile_FH = open(target_file_path, 'w')

    counter = 0
    array = []
    for b in bincontext:
        array.append(b)
        counter = counter + 1
        if counter == 4:
            array.reverse()
            hexfile_FH.write(bytearray(array).hex() + '\n')
            counter = 0
            array = []

    hexfile_FH.close()


# 查找是否有与名称对应的bin文件
def find_isa_bin(isa_path, isa_name):
    file_list = os.listdir(isa_path)
    for file in file_list:
        if file.find(isa_name) != -1:
            if file.find('bin') != -1:
                return file

    return None


# 查找是否有与名称对应的reference文件
def find_isa_reference(isa_reference_path, isa_name):
    file_list = os.listdir(isa_reference_path)
    for file in file_list:
        if file.find(isa_name) != -1:
            return file

    return None


if __name__ == '__main__':
    isa_name = 'add'.upper()

    src_file_path = None
    ref_file_path = None

    # 1.查找isa对应的bin文件和reference文件
    for ii in range(0, 4):
        src_file_path = os.path.join(ARCH_SRC_PATH, ARCH_ISA_SUBFOLDER_LIST[ii])
        isa_bin = find_isa_bin(src_file_path, isa_name)
        if isa_bin != None:
            ref_file_path = os.path.join(ARCH_REF_PATH, ARCH_ISA_SUBFOLDER_LIST[ii])
            isa_ref = find_isa_reference(ref_file_path, isa_name)
            break

    if isa_ref is None:
        print('ERROR !!!')
        print('don\'t find valid ISA sim file! Please check there\'s a valid ISA name as input argument!')
    # 2.将bin文件转为hex文件
    else:
        bin2hex(os.path.join(src_file_path, isa_bin), INST_DATA_FILE)

    # 3.运行
    log_FH = open(ARCH_LOG_FILE, 'w')
    vvp_cmd = ['vvp']
    vvp_cmd.append(OUT_FILE_PATH)
    # process = subprocess.Popen(vvp_cmd, stdout=log_FH, stderr=log_FH)
    process = subprocess.Popen(vvp_cmd)
    try:
        process.wait(timeout=10)
    except:
        print('Error: vpp timeout!')
    log_FH.close()