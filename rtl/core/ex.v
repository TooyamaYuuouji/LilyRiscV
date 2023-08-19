
`include "defines.v"

module ex(
    // from id_ex
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

    // to mem
    output reg          mem_req_o, // 内存访问请求
    output reg          mem_wen_o, // 内存写标志
    output reg[31:0]    mem_waddr_o, // 写内存地址
    output reg[31:0]    mem_wdata_o, // 写内存数据
    output reg[31:0]    mem_raddr_o, // 读内存地址
    // from mem
    input  wire[31:0]   mem_rdata_i, // 内存的数据

    // to div
    output reg          div_start_o, // 开始除法运算标志
    output reg[31:0]    div_dividend_o, // 被除数
    output reg[31:0]    div_divisor_o,  // 除数
    output reg[2:0]     div_op_o,       // 具体是哪一条除法指令
    output reg[4:0]     div_reg_waddr_o,// 除法运算结束后要写的寄存器地址
    // from div
    input wire          div_ready_i,    // 除法运算完成标志
    input wire[31:0]    div_result_i,   // 除法运算结果
    input wire          div_busy_i,     // 除法运算忙标志
    input wire[4:0]     div_reg_waddr_i,// 除法运算结束后要写的寄存器地址

    // to regs
    output wire         reg_wen_o,  // 通用寄存器写使能
    output wire[4:0]    reg_waddr_o,  // 通用寄存器写地址
    output wire[31:0]   reg_wdata_o, // 通用寄存器写地址

    // to ctrl
    output wire         hold_flag_o, // 流水线保持标志
    output wire         jump_flag_o, // 跳转标志
    output wire[31:0]   jump_addr_o // 跳转地址
);

wire[6:0] funct7;
wire[2:0] funct3;
wire[6:0] opcode;

assign funct7    = inst_i[31:25];
assign funct3    = inst_i[14:12];
assign opcode    = inst_i[6:0];

// ALU-乘法
reg[31:0] mul_op1, mul_op2;
wire[63:0] mul_result, mul_result_invert;
assign mul_result = mul_op1 * mul_op2;
assign mul_result_invert = ~mul_result + 1'b1;

// 除法寄存器
reg r_div_reg_wen;
reg[4:0] r_div_reg_waddr;
reg[31:0] r_div_reg_wdata;
reg r_div_hold_flag;
reg r_div_jump_flag;
reg[31:0] r_div_jump_addr;

// 普通寄存器
reg r_reg_wen;
reg[4:0] r_reg_waddr;
reg[31:0] r_reg_wdata;
reg r_hold_flag;
reg r_jump_flag;
reg[31:0] r_jump_addr;

assign reg_wen_o = ((r_reg_wen == 1'b1) || (r_div_reg_wen == 1'b1)) ? 1'b1 : 1'b0;
assign reg_waddr_o = r_reg_waddr | r_div_reg_waddr;
assign reg_wdata_o = r_reg_wdata | r_div_reg_wdata;
assign hold_flag_o = ((r_hold_flag == 1'b1) || (r_div_hold_flag == 1'b1)) ? 1'b1 : 1'b0;
assign jump_flag_o = ((r_jump_flag == 1'b1) || (r_div_jump_flag == 1'b1)) ? 1'b1 : 1'b0;
assign jump_addr_o = r_jump_addr | r_div_jump_addr;

wire[1:0] mem_raddr_index;
wire[1:0] mem_waddr_index;

assign mem_raddr_index = (reg1_rdata_i + {{20{inst_i[31]}}, inst_i[31:20]}) & 2'b11;
assign mem_waddr_index = (reg1_rdata_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]}) & 2'b11;

// 处理乘法指令
always @(*) begin
    if ((opcode == `INST_TYPE_R_M) && (funct7 == 7'b0000001)) begin
        case(funct3)
            `INST_MUL, `INST_MULHU : begin
                mul_op1 = reg1_rdata_i;
                mul_op2 = reg2_rdata_i;
            end
            `INST_MULHSU : begin
                mul_op1 = (reg1_rdata_i[31] == 1'b1) ? (~reg1_rdata_i + 1) : reg1_rdata_i;
                mul_op2 = reg2_rdata_i;
            end
            `INST_MULH : begin
                mul_op1 = (reg1_rdata_i[31] == 1'b1) ? (~reg1_rdata_i + 1) : reg1_rdata_i;
                mul_op2 = (reg2_rdata_i[31] == 1'b1) ? (~reg2_rdata_i + 1) : reg2_rdata_i;
            end
            default : begin
                mul_op1 = reg1_rdata_i;
                mul_op2 = reg2_rdata_i;
            end
        endcase
    end else begin
        mul_op1 = reg1_rdata_i;
        mul_op2 = reg2_rdata_i;
    end
end

// 处理除法指令
always @(*) begin
    div_dividend_o = reg1_rdata_i;
    div_divisor_o = reg2_rdata_i;
    div_op_o = funct3;
    div_reg_waddr_o = rd_waddr_i;
    if((opcode == `INST_TYPE_R_M) && (funct7 == 7'b0000001)) begin
        r_div_reg_wen = 1'b0;
        r_div_reg_waddr = 32'd0;
        r_div_reg_wdata = 32'd0;
        case(funct3)
            `INST_DIV, `INST_DIVU, `INST_REM, `INST_REMU: begin
                div_start_o = 1'b1;
                r_div_hold_flag = 1'b1;
                r_div_jump_flag = 1'b1;
                r_div_jump_addr = jump_base_addr_i + jump_offs_addr_i;
            end
            default : begin
                div_start_o = 1'b0;
                r_div_hold_flag = 1'b0;
                r_div_jump_flag = 1'b0;
                r_div_jump_addr = 32'd0;
            end
        endcase
    end else begin
        r_div_jump_flag = 1'b0;
        r_div_jump_addr = 32'd0;
        if(div_busy_i == 1'b1) begin
            div_start_o = 1'b1;
            r_div_reg_wen = 1'b0;
            r_div_reg_waddr = 32'd0;
            r_div_reg_wdata = 32'd0;
            r_div_hold_flag = 1'b1;
        end else begin
            div_start_o = 1'b0;
            r_div_hold_flag = 1'b0;
            if(div_ready_i == 1'b1) begin
                r_div_reg_wen = 1'b1;
                r_div_reg_waddr = div_reg_waddr_i;
                r_div_reg_wdata = div_result_i;
            end else begin
                r_div_reg_wen = 1'b0;
                r_div_reg_waddr = 32'd0;
                r_div_reg_wdata = 32'd0;
            end
        end
    end
end

// 执行
always @(*)begin
    r_reg_waddr = rd_waddr_i;
    r_reg_wen   = rd_wen_i;
    
    case(opcode)
        `INST_TYPE_B : begin
            r_reg_wdata = 32'b0;
            mem_req_o = 1'b0;
            mem_wen_o = 1'b0;
            mem_waddr_o = 32'd0;
            mem_wdata_o = 32'd0;
            mem_raddr_o = 32'd0;
            case(funct3)
                `INST_BEQ : begin
                    r_jump_addr = jump_base_addr_i + jump_offs_addr_i;
                    r_jump_flag	= (op1_i == op2_i) ? 1'b1 : 1'b0;
                    r_hold_flag = 1'b0;
                end
                `INST_BNE : begin
                    r_jump_addr = jump_base_addr_i + jump_offs_addr_i;
                    r_jump_flag	= (op1_i == op2_i) ? 1'b0 : 1'b1;
                    r_hold_flag = 1'b0;
                end
                `INST_BLT : begin
                    r_jump_addr = jump_base_addr_i + jump_offs_addr_i;
                    r_jump_flag	= ($signed(op1_i) < $signed(op2_i)) ? 1'b1 : 1'b0;
                    r_hold_flag = 1'b0;
                end
                `INST_BGE : begin
                    r_jump_addr = jump_base_addr_i + jump_offs_addr_i;
                    r_jump_flag	= ($signed(op1_i) >= $signed(op2_i)) ? 1'b1 : 1'b0;
                    r_hold_flag = 1'b0;
                end
                `INST_BLTU : begin
                    r_jump_addr = jump_base_addr_i + jump_offs_addr_i;
                    r_jump_flag	= (op1_i < op2_i) ? 1'b1 : 1'b0;
                    r_hold_flag = 1'b0;
                end
                `INST_BGEU : begin
                    r_jump_addr = jump_base_addr_i + jump_offs_addr_i;
                    r_jump_flag	= (op1_i >= op2_i) ? 1'b1 : 1'b0;
                    r_hold_flag = 1'b0;
                end
                default : begin
                    r_jump_addr = 32'b0;
                    r_jump_flag	= 1'b0;
                    r_hold_flag = 1'b0;
                end
            endcase
        end
        `INST_TYPE_L : begin
            r_jump_addr = 32'd0;
            r_jump_flag	= 1'b0;
            r_hold_flag = 1'b0;
            mem_req_o   = 1'b1;
            mem_wen_o   = 1'b0;
            mem_waddr_o = 32'd0;
            mem_wdata_o = 32'd0;
            case(funct3)
                `INST_LB : begin
                    mem_raddr_o = op1_i + op2_i;
                    case(mem_raddr_index)
                        2'b00: begin
                            r_reg_wdata = {{24{mem_rdata_i[7]}}, mem_rdata_i[7:0]};
                        end
                        2'b01: begin
                            r_reg_wdata = {{24{mem_rdata_i[15]}}, mem_rdata_i[15:8]};
                        end
                        2'b10: begin
                            r_reg_wdata = {{24{mem_rdata_i[23]}}, mem_rdata_i[23:16]};
                        end
                        default: begin
                            r_reg_wdata = {{24{mem_rdata_i[31]}}, mem_rdata_i[31:24]};
                        end
                    endcase
                end
                `INST_LH : begin
                    mem_raddr_o = op1_i + op2_i;
                    if(mem_raddr_index == 2'b00) begin
                        r_reg_wdata = {{16{mem_rdata_i[15]}}, mem_rdata_i[15:0]};
                    end else begin
                        r_reg_wdata = {{16{mem_rdata_i[31]}}, mem_rdata_i[31:16]};
                    end
                end
                `INST_LW : begin
                    mem_raddr_o = op1_i + op2_i;
                    r_reg_wdata = mem_rdata_i;
                end
                `INST_LBU : begin
                    mem_raddr_o = op1_i + op2_i;
                    case(mem_raddr_index)
                        2'b00: begin
                            r_reg_wdata = {24'h0, mem_rdata_i[7:0]};
                        end
                        2'b01: begin
                            r_reg_wdata = {24'h0, mem_rdata_i[15:8]};
                        end
                        2'b10: begin
                            r_reg_wdata = {24'h0, mem_rdata_i[23:16]};
                        end
                        default: begin
                            r_reg_wdata = {24'h0, mem_rdata_i[31:24]};
                        end
                    endcase
                end
                `INST_LHU : begin
                    mem_raddr_o = op1_i + op2_i;
                    if(mem_raddr_index == 2'b0) begin
                        r_reg_wdata = {16'h0, mem_rdata_i[15:0]};
                    end else begin
                        r_reg_wdata = {16'h0, mem_rdata_i[31:16]};
                    end
                end
                default : begin
                    mem_raddr_o = 32'd0;
                    r_reg_wdata = 32'd0;
                end
            endcase
        end
        `INST_TYPE_S : begin
            r_reg_wdata = 32'd0;
            r_jump_addr = 32'd0;
            r_jump_flag	= 1'b0;
            r_hold_flag = 1'b0;
            mem_req_o   = 1'b1;
            mem_wen_o   = 1'b1;
            case(funct3)
                `INST_SB : begin
                    mem_waddr_o = op1_i + op2_i;
                    mem_raddr_o = op1_i + op2_i;
                    case(mem_waddr_index)
                        2'b00: begin
                            mem_wdata_o = {mem_rdata_i[31:8], reg2_rdata_i[7:0]};
                        end
                        2'b01: begin
                            mem_wdata_o = {mem_rdata_i[31:16], reg2_rdata_i[7:0], mem_rdata_i[7:0]};
                        end
                        2'b10: begin
                            mem_wdata_o = {mem_rdata_i[31:24], reg2_rdata_i[7:0], mem_rdata_i[15:0]};
                        end
                        default: begin
                            mem_wdata_o = {reg2_rdata_i[7:0], mem_rdata_i[23:0]};
                        end
                    endcase
                end
                `INST_SH : begin
                    mem_waddr_o = op1_i + op2_i;
                    mem_raddr_o = op1_i + op2_i;
                    if(mem_waddr_index == 2'b00) begin
                        mem_wdata_o = {mem_rdata_i[31:16], reg2_rdata_i[15:0]};
                    end else begin
                        mem_wdata_o = {reg2_rdata_i[15:0], mem_rdata_i[15:0]};
                    end
                end
                `INST_SW : begin
                    mem_waddr_o = op1_i + op2_i;
                    mem_raddr_o = op1_i + op2_i;
                    mem_wdata_o = reg2_rdata_i;
                end
                default : begin
                    mem_waddr_o = 32'd0;
                    mem_raddr_o = 32'd0;
                    mem_wdata_o = 32'd0;
                end
            endcase
        end
        `INST_TYPE_I : begin
            r_jump_addr = 32'd0;
            r_jump_flag	= 1'b0;
            r_hold_flag = 1'b0;
            mem_req_o   = 1'b0;
            mem_wen_o   = 1'b0;
            mem_waddr_o = 32'd0;
            mem_wdata_o = 32'd0;
            mem_raddr_o = 32'd0;
            case(funct3)
                `INST_ADDI : begin
                    r_reg_wdata = op1_i + op2_i;
                end
                `INST_SLTI : begin
                    r_reg_wdata = ($signed(op1_i) < $signed(op2_i)) ? 32'h1 : 32'h0;
                end
                `INST_SLTIU : begin
                    r_reg_wdata = (op1_i < op2_i) ? 32'h1 : 32'h0;
                end
                `INST_XORI : begin
                    r_reg_wdata = op1_i ^ op2_i;
                end
                `INST_ORI : begin
                    r_reg_wdata = op1_i | op2_i;
                end
                `INST_ANDI : begin
                    r_reg_wdata = op1_i & op2_i;
                end
                `INST_SLLI : begin
                    r_reg_wdata = op1_i << op2_i[4:0]; // op2_i[5] === 0
                end
                `INST_SRXI : begin
                    // SRLI
                    if(funct7 == 7'b000_0000) begin
                        r_reg_wdata = op1_i >> op2_i[4:0];
                    end
                    // SRAI
                    else begin
                        r_reg_wdata = (op1_i >> op2_i[4:0]) | ({32{op1_i[31]}} & ~(32'hFFFF_FFFF >> op2_i[4:0]));
                    end
                end
                default : begin
                    r_reg_wdata = 32'd0;
                end
            endcase
        end
        `INST_TYPE_R_M : begin
            r_jump_addr = 32'd0;
            r_jump_flag	= 1'b0;
            r_hold_flag = 1'b0;
            mem_req_o   = 1'b0;
            mem_wen_o   = 1'b0;
            mem_waddr_o = 32'd0;
            mem_wdata_o = 32'd0;
            mem_raddr_o = 32'd0;
            if ((funct7 == 7'b0000000) || (funct7 == 7'b0100000)) begin
                case(funct3)
                    `INST_ADD_SUB : begin
                        // ADD
                        if(funct7 == 7'b000_0000) begin
                            r_reg_wdata = op1_i + op2_i;
                        end
                        // SUB
                        else begin
                            r_reg_wdata = op1_i - op2_i;
                        end
                    end
                    `INST_SLL : begin
                        r_reg_wdata = op1_i << op2_i[4:0];
                    end
                    `INST_SLT : begin
                        r_reg_wdata = ($signed(op1_i) < $signed(op2_i)) ? 32'h1 : 32'h0;
                    end
                    `INST_SLTU : begin
                        r_reg_wdata = (op1_i < op2_i) ? 32'h1 : 32'h0;
                    end
                    `INST_XOR : begin
                        r_reg_wdata = op1_i ^ op2_i;
                    end
                    `INST_SRX : begin
                        // SRL
                        if(funct7 == 7'b000_0000) begin
                            r_reg_wdata = op1_i >> op2_i[4:0];
                        end
                        // SRA
                        else begin
                            r_reg_wdata = (op1_i >> op2_i[4:0]) | ({32{op1_i[31]}} & ~(32'hFFFF_FFFF >> op2_i[4:0]));
                        end
                    end
                    `INST_OR : begin
                        r_reg_wdata = op1_i | op2_i;
                    end
                    `INST_AND : begin
                        r_reg_wdata = op1_i & op2_i;
                    end
                    default : begin
                        r_reg_wdata = 32'b0;
                    end
                endcase
            end else if (funct7 == 7'b0000001) begin
                case(funct3)
                    `INST_MUL: begin
                        r_reg_wdata = mul_result[31:0];
                    end
                    `INST_MULH : begin
                        case({reg1_rdata_i[31], reg2_rdata_i[31]})
                            2'b00 : begin r_reg_wdata = mul_result[63:32]; end
                            2'b11 : begin r_reg_wdata = mul_result[63:32]; end
                            default : begin r_reg_wdata = mul_result_invert[63:32]; end
                        endcase
                    end
                    `INST_MULHSU : begin
                        if(reg1_rdata_i[31] == 1'b1) begin
                            r_reg_wdata = mul_result_invert[63:32];
                        end else begin
                            r_reg_wdata = mul_result[63:32];
                        end
                    end
                    `INST_MULHU : begin
                        r_reg_wdata = mul_result[63:32];
                    end
                endcase
            end else begin
                r_reg_wdata = 32'd0;
            end
        end
        `INST_TYPE_FENCE : begin
            r_reg_wdata = 32'd0;
            r_jump_addr = jump_base_addr_i + jump_offs_addr_i;
            r_jump_flag	= 1'b1;
            r_hold_flag = 1'b0;
            mem_req_o   = 1'b0;
            mem_wen_o   = 1'b0;
            mem_waddr_o = 32'd0;
            mem_wdata_o = 32'd0;
            mem_raddr_o = 32'd0;
        end
        `INST_LUI : begin
            r_reg_wdata = op1_i;
            r_jump_addr = 32'd0;
            r_jump_flag	= 1'b0;
            r_hold_flag = 1'b0;
            mem_req_o   = 1'b0;
            mem_wen_o   = 1'b0;
            mem_waddr_o = 32'd0;
            mem_wdata_o = 32'd0;
            mem_raddr_o = 32'd0;
        end
        `INST_AUIPC : begin
            r_reg_wdata = op1_i + op2_i;
            r_jump_addr = 32'd0;
            r_jump_flag	= 1'b0;
            r_hold_flag = 1'b0;
            mem_req_o   = 1'b0;
            mem_wen_o   = 1'b0;
            mem_waddr_o = 32'd0;
            mem_wdata_o = 32'd0;
            mem_raddr_o = 32'd0;
        end
        `INST_JAL, `INST_JALR : begin
            r_reg_wdata = op1_i + op2_i;
            r_jump_addr = jump_base_addr_i + jump_offs_addr_i;
            r_jump_flag	= 1'b1;
            r_hold_flag = 1'b0;
            mem_req_o   = 1'b0;
            mem_wen_o   = 1'b0;
            mem_waddr_o = 32'd0;
            mem_wdata_o = 32'd0;
            mem_raddr_o = 32'd0;
        end
        default : begin
            r_reg_wdata = 32'b0;
            r_jump_addr = 32'b0;
            r_jump_flag	= 1'b0;
            r_hold_flag = 1'b0;
            mem_req_o = 1'b0;
            mem_wen_o = 1'b0;
            mem_waddr_o = 32'd0;
            mem_wdata_o = 32'd0;
            mem_raddr_o = 32'd0;
        end
    endcase
end

endmodule