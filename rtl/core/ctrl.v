
// 控制器，控制流水线过程，主要是发出暂停和跳转信号
module ctrl(
    // from ex
    input  wire         hold_flag_i, // 流水线需要暂停
    input  wire         jump_flag_i, // 需要跳转
    input  wire[31:0]   jump_addr_i, // 跳转地址

    // from bus
    input  wire         bus_hold_flag_i,

    // to if_id/id_ex pc
    output reg[1:0]     hold_flag_o,

    // to pc
    output reg          jump_flag_o,
    output reg[31:0]    jump_addr_o
);

always @(*) begin
    jump_flag_o = jump_flag_i;
    jump_addr_o = jump_addr_i;
    if((hold_flag_i == 1'b1) || (jump_flag_i == 1'b1)) begin
        hold_flag_o = 2'b11;
    end else if(bus_hold_flag_i == 1'b1) begin
        hold_flag_o = 2'b01;
    end else begin
        hold_flag_o = 2'b00;
    end
end

endmodule