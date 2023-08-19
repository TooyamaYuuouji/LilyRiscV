# 供编译、运行等过程使用到的路径索引

MAIN_PATH = r'/home/tooyama/Code/Project/LilyRiscv'

OUT_FILE_PATH = MAIN_PATH + r'/sim/out.vvp'

# 由于使用 iverilog 进行编译和仿真，路径索引需根据调用 tb.v 的程序为基准（如sim_one_old_isa），即需要根据 sim_one_isa.py 等的文件路径为基准
# 因此需要对 tb.v 中的 $readmemh() 中的路径进行修改
INST_DATA_FILE = MAIN_PATH + r'/sim/inst.data'

# 用于old_isa指令集
OLD_ISA_PATH = MAIN_PATH + r'/test/old_isa'

# 用于新指令测试集
ARCH_PATH = MAIN_PATH + r'/test/riscv-arch-test'
ARCH_SRC_PATH = ARCH_PATH + r'/src'
ARCH_REF_PATH = ARCH_PATH + r'/references'
ARCH_ISA_SUBFOLDER_LIST = ['rv32i', 'rv32im', 'rv32Zicsr', 'rv32Zifencei']
ARCH_LOG_FILE = ARCH_PATH + r'/run.log'
