
// 内部通用寄存器，共32个32位寄存器。其中写优先级高于读优先级

module regs(
	input  wire         clk,
	input  wire         rstn,

	//from id
	input  wire[4:0] reg1_raddr_i,
	input  wire[4:0] reg2_raddr_i,
	
	//to id
	output reg[31:0] reg1_rdata_o,
	output reg[31:0] reg2_rdata_o,
	
	//from ex
    input               reg_wen_i,
	input  wire[4:0]    reg_waddr_i,
	input  wire[31:0]   reg_wdata_i
);

reg[31:0] x[0:31]; // 通用寄存器 x0~x31
integer i;

// 读寄存器1
always @(*) begin
    if(rstn == 1'b0) begin
        reg1_rdata_o = 32'd0;
    end else begin
        // 保护 x0 只读寄存器
        if(reg1_raddr_i == 5'd0) begin
            reg1_rdata_o = 32'd0;
        // 同时读写
        end else if((reg_wen_i == 1'b1) && (reg_waddr_i == reg1_raddr_i))
            reg1_rdata_o = reg_wdata_i;
        else begin
            reg1_rdata_o = x[reg1_raddr_i];
        end
    end
end

// 读寄存器2
always @(*) begin
    if(rstn == 1'b0) begin
        reg2_rdata_o = 32'd0;
    end else begin
        // 保护 x0 只读寄存器
        if(reg2_raddr_i == 5'd0) begin
            reg2_rdata_o = 32'd0;
        // 同时读写
        end else if((reg_wen_i == 1'b1) && (reg_waddr_i == reg2_raddr_i))
            reg2_rdata_o = reg_wdata_i;
        else begin
            reg2_rdata_o = x[reg2_raddr_i];
        end
    end
end

// 写寄存器
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) begin
        for(i = 0; i < 32; i = i + 1)begin
            x[i] <= 32'h0;
        end
    end	else begin
        if((reg_wen_i == 1'b1) && (reg_waddr_i != 5'd0)) begin
            x[reg_waddr_i] <= reg_wdata_i;
        end
    end	
end

endmodule