
import os


# 二级制文件转为十六进制文件
def main(source_file_path, target_file_path):
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


if __name__ == '__main__':
    main('uart_tx.bin', 'hextest')
    None
