
module id_ex(
    input  wire         clk,
    input  wire         rstn,

    // from ctrl
    input  wire[1:0]    hold_flag_i,

    // from id
    input  wire[31:0]   inst_addr_i,    // 指令地址
    input  wire[31:0]   inst_i,         // 指令内容
    input  wire[31:0]   op1_i,          // 操作数1
    input  wire[31:0]   op2_i,          // 操作数2
    input  wire[31:0]   jump_base_addr_i, // 跳转指令用到的基地址
    input  wire[31:0]   jump_offs_addr_i, // 跳转指令用到的偏移地址
    input  wire[31:0]   reg1_rdata_i, // 通用寄存器1的数据
    input  wire[31:0]   reg2_rdata_i, // 通用寄存器2的数据
    input  wire         rd_wen_i,   // 写回通用寄存器的标志
    input  wire[4:0]    rd_waddr_i,  // 写回通用寄存器的地址

    // to ex
    output wire[31:0]   inst_addr_o,    // 指令地址
    output wire[31:0]   inst_o,         // 指令内容
    output wire[31:0]   op1_o,          // 操作数1
    output wire[31:0]   op2_o,          // 操作数2
    output wire[31:0]   jump_base_addr_o, // 跳转指令用到的基地址
    output wire[31:0]   jump_offs_addr_o, // 跳转指令用到的偏移地址
    output wire[31:0]   reg1_rdata_o, // 通用寄存器1的数据
    output wire[31:0]   reg2_rdata_o, // 通用寄存器2的数据
    output wire         rd_wen_o,   // 写回通用寄存器的标志
    output wire[4:0]    rd_waddr_o  // 写回通用寄存器的地址
);

wire hold_en = (hold_flag_i >= 2'b11);

gen_diff #(32) inst_addr_diff(clk, rstn, hold_en, 32'h0, inst_addr_i, inst_addr_o);

gen_diff #(32) inst_diff(clk, rstn, hold_en, 32'h00000001, inst_i, inst_o);

gen_diff #(32) op1_diff(clk, rstn, hold_en, 32'h0, op1_i, op1_o);

gen_diff #(32) op2_diff(clk, rstn, hold_en, 32'h0, op2_i, op2_o);

gen_diff #(32) jump_base_addr_diff(clk, rstn, hold_en, 32'h0, jump_base_addr_i, jump_base_addr_o);

gen_diff #(32) jump_offs_addr_diff(clk, rstn, hold_en, 32'h0, jump_offs_addr_i, jump_offs_addr_o);

gen_diff #(32) reg1_rdata_diff(clk, rstn, hold_en, 32'h0, reg1_rdata_i, reg1_rdata_o);

gen_diff #(32) reg2_rdata_diff(clk, rstn, hold_en, 32'h0, reg2_rdata_i, reg2_rdata_o);

gen_diff #(1) rd_wen_diff(clk, rstn, hold_en, 1'b0, rd_wen_i, rd_wen_o);

gen_diff #(5) rd_waddr_diff(clk, rstn, hold_en, 5'd0, rd_waddr_i, rd_waddr_o);

endmodule