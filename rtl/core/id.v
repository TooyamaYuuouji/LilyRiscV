

`include "defines.v"

// 译码器，将指令拆解，获得寄存器地址
module id(
    // from if_id
    input  wire[31:0]   inst_addr_i,    // 指令地址
    input  wire[31:0]   inst_i,         // 指令内容

    // to regs
    output reg[4:0]     reg1_raddr_o,    // 需访问通用寄存器1的地址
    output reg[4:0]     reg2_raddr_o,    // 需访问通用寄存器2的地址

    // from regs
    input wire[31:0]    reg1_rdata_i,  // 通用寄存器1返回的数据
    input wire[31:0]    reg2_rdata_i,  // 通用寄存器2返回的数据

    // to id_ex
    output reg[31:0]    inst_addr_o,    // 指令地址
    output reg[31:0]    inst_o,         // 指令内容
    output reg[31:0]    op1_o,          // 操作数1
    output reg[31:0]    op2_o,          // 操作数2
    output reg[31:0]    jump_base_addr_o, // 跳转指令用到的基地址
    output reg[31:0]    jump_offs_addr_o, // 跳转指令用到的偏移地址
    output reg[31:0]    reg1_rdata_o,     // 通用寄存器1的数据
    output reg[31:0]    reg2_rdata_o,     // 通用寄存器2的数据
    output reg          rd_wen_o,         // 写回通用寄存器的标志
    output reg[4:0]     rd_waddr_o        // 写回通用寄存器的地址
);

wire[6:0] funct7;
wire[4:0] rs2;
wire[4:0] rs1;
wire[2:0] funct3; 
wire[4:0] rd;
wire[6:0] opcode;
wire[31:0] exp_I_imm;
wire[31:0] exp_S_imm;
wire[31:0] exp_SB_imm;
wire[31:0] exp_U_imm;
wire[31:0] exp_UJ_imm;

assign funct7     = inst_i[31:25];
assign rs2        = inst_i[24:20];
assign rs1        = inst_i[19:15];
assign funct3     = inst_i[14:12];
assign rd         = inst_i[11:7];
assign opcode     = inst_i[6:0];
assign exp_I_imm  = {{20{inst_i[31]}}, inst_i[31:20]};
assign exp_S_imm  = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
assign exp_SB_imm = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
assign exp_U_imm  = {inst_i[31:12], 12'd0};
assign exp_UJ_imm = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};

always @(*)begin
    inst_o           = inst_i;
    inst_addr_o      = inst_addr_i;
    reg1_rdata_o     = reg1_rdata_i;
    reg2_rdata_o     = reg2_rdata_i;
    
    case(opcode)
        `INST_TYPE_B : begin
            rd_waddr_o = 5'b0;
            rd_wen_o   = 1'b0;
            case(funct3)
                `INST_BEQ, `INST_BNE, `INST_BLT, `INST_BGE, `INST_BLTU, `INST_BGEU : begin
                    reg1_raddr_o     = rs1;
                    reg2_raddr_o     = rs2;
                    op1_o            = reg1_rdata_i;
                    op2_o            = reg2_rdata_i;
                    jump_base_addr_o = inst_addr_i;
                    jump_offs_addr_o = exp_SB_imm;
                end 
                default : begin
                    reg1_raddr_o     = 5'b0;
                    reg2_raddr_o     = 5'b0;
                    op1_o            = 32'd0;
                    op2_o            = 32'd0;
                    jump_base_addr_o = 32'd0;
                    jump_offs_addr_o = 32'd0;
                end
            endcase
        end
        `INST_TYPE_L : begin
            jump_base_addr_o = 32'd0;
            jump_offs_addr_o = 32'd0;
            case(funct3)
                `INST_LB, `INST_LH, `INST_LW, `INST_LBU, `INST_LHU : begin
                    reg1_raddr_o = rs1;
                    reg2_raddr_o = 5'd0;
                    op1_o        = reg1_rdata_i;
                    op2_o        = exp_I_imm;
                    rd_waddr_o   = rd;
                    rd_wen_o     = 1'b1;
                end
                default : begin
                    reg1_raddr_o = 5'd0;
                    reg2_raddr_o = 5'b0;
                    op1_o        = 32'd0;
                    op2_o        = 32'd0;
                    rd_waddr_o   = 5'd0;
                    rd_wen_o     = 1'b0;
                end
            endcase
        end
        `INST_TYPE_S : begin
            jump_base_addr_o = 32'd0;
            jump_offs_addr_o = 32'd0;
            rd_waddr_o       = 5'd0;
            rd_wen_o         = 1'b0;
            case(funct3)
                `INST_SB, `INST_SH, `INST_SW : begin
                    reg1_raddr_o = rs1;
                    reg2_raddr_o = rs2;
                    op1_o        = reg1_rdata_i;
                    op2_o        = exp_S_imm;
                end
                default : begin
                    reg1_raddr_o = 5'd0;
                    reg2_raddr_o = 5'b0;
                    op1_o        = 32'd0;
                    op2_o        = 32'd0;
                end
            endcase
        end
        `INST_TYPE_I : begin
            jump_base_addr_o = 32'd0;
            jump_offs_addr_o = 32'd0;
            case(funct3)
                `INST_ADDI, `INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ORI, `INST_ANDI, `INST_SLLI, `INST_SRXI : begin
                    reg1_raddr_o = rs1;
                    reg2_raddr_o = 5'b0;
                    op1_o        = reg1_rdata_i;
                    op2_o        = exp_I_imm;
                    rd_waddr_o   = rd;
                    rd_wen_o     = 1'b1;
                end
                default : begin
                    reg1_raddr_o = 5'd0;
                    reg2_raddr_o = 5'b0;
                    op1_o        = 32'd0;
                    op2_o        = 32'd0;
                    rd_waddr_o   = 5'd0;
                    rd_wen_o     = 1'b0;
                end
            endcase
        end
        `INST_TYPE_R_M : begin
            if((funct7 == 7'b0000000) || (funct7 == 7'b0100000)) begin
                jump_base_addr_o = 32'd0;
                jump_offs_addr_o = 32'd0;
                case(funct3)
                    `INST_ADD_SUB, `INST_SLL, `INST_SLT, `INST_SLTU, `INST_XOR, `INST_SRX, `INST_OR, `INST_AND : begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        op1_o        = reg1_rdata_i;
                        op2_o        = reg2_rdata_i;
                        jump_base_addr_o = 32'd0;
                        jump_offs_addr_o = 32'd0;
                        rd_waddr_o   = rd;
                        rd_wen_o     = 1'b1;
                    end
                    `INST_DIV, `INST_DIVU, `INST_REM, `INST_REMU: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        op1_o        = reg1_rdata_i;
                        op2_o        = reg2_rdata_i;
                        jump_base_addr_o = inst_addr_i;
                        jump_offs_addr_o = 32'h4;
                        rd_waddr_o   = rd;
                        rd_wen_o     = 1'b0;
                    end
                    default : begin
                        reg1_raddr_o = 5'd0;
                        reg2_raddr_o = 5'd0;
                        op1_o        = 32'd0;
                        op2_o        = 32'd0;
                        jump_base_addr_o = 32'd0;
                        jump_offs_addr_o = 32'd0;
                        rd_waddr_o   = 5'd0;
                        rd_wen_o     = 1'b0;
                    end
                endcase
            end else if(funct7 == 7'b0000001) begin
                case(funct3)
                    `INST_MUL, `INST_MULH, `INST_MULHSU, `INST_MULHU : begin
                        reg1_raddr_o     = rs1;
                        reg2_raddr_o     = rs2;
                        op1_o            = reg1_rdata_i;
                        op2_o            = reg2_rdata_i;
                        jump_base_addr_o = 32'd0;
                        jump_offs_addr_o = 32'd0;
                        rd_waddr_o       = rd;
                        rd_wen_o         = 1'b1;
                    end
                    `INST_DIV, `INST_DIVU, `INST_REM, `INST_REMU : begin
                        reg1_raddr_o     = rs1;
                        reg2_raddr_o     = rs2;
                        op1_o            = reg1_rdata_i;
                        op2_o            = reg2_rdata_i;
                        jump_base_addr_o = inst_addr_i;
                        jump_offs_addr_o = 32'h4;
                        rd_waddr_o       = rd;
                        rd_wen_o         = 1'b0;
                    end
                    default : begin
                        reg1_raddr_o     = 5'd0;
                        reg2_raddr_o     = 5'd0;
                        op1_o            = 32'd0;
                        op2_o            = 32'd0;
                        jump_base_addr_o = 32'd0;
                        jump_offs_addr_o = 32'd0;
                        rd_waddr_o       = 5'd0;
                        rd_wen_o         = 1'b0;
                    end
                endcase
            end else begin
                reg1_raddr_o     = 5'd0;
                reg2_raddr_o     = 5'd0;
                op1_o            = 32'd0;
                op2_o            = 32'd0;
                jump_base_addr_o = 32'd0;
                jump_offs_addr_o = 32'd0;
                rd_waddr_o       = 5'd0;
                rd_wen_o         = 1'b0;
            end
        end
        `INST_TYPE_FENCE : begin
            reg1_raddr_o     = 5'd0;
            reg2_raddr_o     = 5'd0;
            op1_o            = 32'd0;
            op2_o            = 32'd0;
            jump_base_addr_o = inst_addr_i;
            jump_offs_addr_o = 32'h4;
            rd_waddr_o       = 5'd0;
            rd_wen_o         = 1'b0;
        end
        `INST_LUI : begin
            reg1_raddr_o     = 5'd0;
            reg2_raddr_o     = 5'd0;
            op1_o            = exp_U_imm;
            op2_o            = 32'd0;
            jump_base_addr_o = 32'd0;
            jump_offs_addr_o = 32'd0;
            rd_waddr_o       = rd;
            rd_wen_o         = 1'b1;
        end
        `INST_AUIPC : begin
            reg1_raddr_o     = 5'd0;
            reg2_raddr_o     = 5'd0;
            op1_o            = inst_addr_i;
            op2_o            = exp_U_imm;
            jump_base_addr_o = 32'd0;
            jump_offs_addr_o = 32'd0;
            rd_waddr_o       = rd;
            rd_wen_o         = 1'b1;
        end
        `INST_JAL : begin
            reg1_raddr_o     = 5'd0;
            reg2_raddr_o     = 5'd0;
            op1_o            = inst_addr_i;
            op2_o            = 32'h4;
            jump_base_addr_o = inst_addr_i;
            jump_offs_addr_o = exp_UJ_imm;
            rd_waddr_o       = rd;
            rd_wen_o         = 1'b1;
        end
        `INST_JALR : begin
            reg1_raddr_o     = rs1;
            reg2_raddr_o     = 5'd0;
            op1_o            = inst_addr_i;
            op2_o            = 32'h4;
            jump_base_addr_o = reg1_rdata_i;
            jump_offs_addr_o = exp_I_imm;
            rd_waddr_o       = rd;
            rd_wen_o         = 1'b1;
        end
        default : begin
            reg1_raddr_o     = 5'b0;
            reg2_raddr_o     = 5'b0;
            op1_o            = 32'b0;
            op2_o            = 32'b0;
            jump_base_addr_o = 32'd0;
            jump_offs_addr_o = 32'd0;
            rd_waddr_o       = 5'b0;
            rd_wen_o         = 1'b0;
        end
    endcase
end

endmodule