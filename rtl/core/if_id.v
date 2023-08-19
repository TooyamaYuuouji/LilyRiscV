

// 一级流水线，将指令向译码器传递
// 32位Riscv，每条指令长度为32
module if_id(
    input  wire         clk,
    input  wire         rstn,

    // from ctrl
    input  wire[1:0]    hold_flag_i,

    // from if
    input  wire[31:0]   inst_addr_i,    // 指令地址
    input  wire[31:0]   inst_i,         // 指令内容

    // to id
    output wire[31:0]   inst_addr_o,    // 指令地址
    output wire[31:0]   inst_o         // 指令内容
);

wire hold_en = (hold_flag_i >= 2'b10);

gen_diff #(32) inst_addr_diff(clk, rstn, hold_en, 32'h0, inst_addr_i, inst_addr_o);

gen_diff #(32) inst_diff(clk, rstn, hold_en, 32'h00000001, inst_i, inst_o);

endmodule