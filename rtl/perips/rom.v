// module rom(
// 	input wire[31:0] inst_addr_i,
// 	output reg[31:0] inst_o
// );

// 	reg[31:0] rom_mem[0:4095];  //4096 个 32b的 空间  //错
	
// 	always @(*)begin
// 		inst_o = rom_mem[inst_addr_i[31:2]];
// 	end

// endmodule


module rom(
    input  wire clk,
    input  wire rstn,

    input  wire wen_i,
    input  wire[31:0] addr_i,
    input  wire[31:0] data_i,

    output reg[31:0] data_o
);

reg[31:0] rom_mem[0:4095];

always @(posedge clk) begin
    if(wen_i == 1'b1) begin
        rom_mem[addr_i[31:2]] <= data_i;
    end
end

always @(*) begin
    if(rstn == 1'b0) begin
        data_o = 32'd0;
    end else begin
        data_o = rom_mem[addr_i[31:2]];
    end
end

endmodule