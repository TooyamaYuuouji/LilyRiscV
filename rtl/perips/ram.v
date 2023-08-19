
// 能最大存储 4096 个 32 位数据的 ram
module ram(
    input  wire clk,
    input  wire rstn,

    input  wire wen_i,
    input  wire[31:0] addr_i,
    input  wire[31:0] data_i,

    output reg[31:0] data_o
);

reg[31:0] ram_data[0:4095];

always @(posedge clk) begin
    if(wen_i == 1'b1) begin
        ram_data[addr_i[31:2]] <= data_i;
    end
end

always @(*) begin
    if(rstn == 1'b0) begin
        data_o = 32'd0;
    end else begin
        data_o = ram_data[addr_i[31:2]];
    end
end

endmodule