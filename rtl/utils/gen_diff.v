
// 通用型D触发器
module gen_diff #(
    parameter DATAWIDTH = 32
)
(
    input  wire                 clk,
    input  wire                 rstn,

    input  wire                 hold_flag_i,  // 保持使能
    input  wire[DATAWIDTH-1:0]  dflt_val_i, // default value，默认值
    input  wire[DATAWIDTH-1:0]  d_i,        // 输入数据
    output reg[DATAWIDTH-1:0]   d_o         // 输出数据
);

always @(posedge clk or negedge rstn) begin
    if((rstn == 1'b0) || (hold_flag_i == 1'b1)) begin
        d_o <= dflt_val_i;
    end else begin
        d_o <= d_i;
    end
end

endmodule