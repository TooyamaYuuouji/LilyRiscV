

// PC 寄存器模块
// 32位Riscv，使用8bit rom存储指令，因此每条指令使用四个字节的地址
// 最大支持 1G rom（2^32/4）

module pc(
    input  wire         clk,
    input  wire         rstn,

    // from ctrl
    input  wire[1:0]    hold_flag_i,
    input  wire         jump_flag_i,
    input  wire[31:0]   jump_addr_i,

    // to rom/if_id
    output reg[31:0]    pc_o
);


always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) begin
        pc_o <= 32'h0;
    end else begin
        // 优先跳转而非暂停，否则会出现错误，这是因为只有div这个怪胎需要暂停流水线而其他指令不用
        // 如果优先暂停，根据ctrl的规则，暂停和跳转具备同等作用，也就是说暂停信号也会被识别为跳转
        // 信号，这会导致时序错误
        if(jump_flag_i == 1'b1) begin
            pc_o <= jump_addr_i;
        end else if(hold_flag_i >= 2'b01) begin
            pc_o <= pc_o;
        end else begin
            pc_o <= pc_o + 32'h4;
        end
    end
end

endmodule