module LilyRiscv(
    input  wire         clk,
    input  wire         rstn,

    output wire         mem_req_o, // 内存访问请求
    output wire         mem_wen_o, // 内存写标志
    output wire[31:0]   mem_waddr_o, // 写内存地址
    output wire[31:0]   mem_wdata_o, // 写内存数据
    output wire[31:0]   mem_raddr_o, // 读内存地址
    input  wire[31:0]   mem_rdata_i, // 内存的数据

    output wire[31:0]   inst_addr_o, // 指令地址
    input  wire[31:0]   inst_i,      // 指令内容
    input  wire         hold_flag_i
);

// pc to if_id
wire[31:0] pc_pc_o;

// pc to rom
assign inst_addr_o = pc_pc_o;

// if_id to id
wire[31:0] if_id_inst_addr_o;
wire[31:0] if_id_inst_o;

// id to regs
wire[4:0] id_reg1_raddr_o;
wire[4:0] id_reg2_raddr_o;
// id to id_ex
wire[31:0] id_inst_addr_o;
wire[31:0] id_inst_o      ;
wire[31:0] id_op1_o      ;
wire[31:0] id_op2_o      ;
wire[31:0] id_jump_base_addr_o;
wire[31:0] id_jump_offs_addr_o;
wire[31:0] id_reg1_rdata_o;
wire[31:0] id_reg2_rdata_o;
wire       id_rd_wen_o   ;
wire[4:0]  id_rd_waddr_o  ;

// regs to id
wire[31:0] regs_reg1_rdata_o;
wire[31:0] regs_reg2_rdata_o;

// id_ex to ex
wire[31:0] id_ex_inst_addr_o;
wire[31:0] id_ex_inst_o      ;
wire[31:0] id_ex_op1_o      ;
wire[31:0] id_ex_op2_o      ;
wire[31:0] id_ex_jump_base_addr_o;
wire[31:0] id_ex_jump_offs_addr_o;
wire[31:0] id_ex_reg1_rdata_o;
wire[31:0] id_ex_reg2_rdata_o;
wire       id_ex_rd_wen_o   ;
wire[4:0]  id_ex_rd_waddr_o  ;

// ex to regs
wire ex_reg_wen_o;
wire[4:0] ex_reg_waddr_o;
wire[31:0] ex_reg_wdata_o;
// ex to ctrl
wire ex_hold_flag_o;
wire ex_jump_flag_o;
wire[31:0] ex_jump_addr_o;
// ex to div
wire ex_div_start_o;
wire[31:0] ex_div_dividend_o;
wire[31:0] ex_div_divisor_o;
wire[2:0] ex_div_op_o;
wire[4:0] ex_div_reg_waddr_o;

// ctrl to if_id/id_ex pc
wire[1:0] ctrl_hold_flag_o;
// ctrl to pc
wire ctrl_jump_flag_o;
wire[31:0] ctrl_jump_addr_o;

// div to ex
wire[31:0] div_result_o;
wire div_ready_o;
wire div_busy_o;
wire[4:0] div_reg_waddr_o;

pc pc_U1(
    .clk        (clk),
    .rstn       (rstn),
    .hold_flag_i(ctrl_hold_flag_o),
    .jump_flag_i(ctrl_jump_flag_o),
    .jump_addr_i(ctrl_jump_addr_o),
    .pc_o       (pc_pc_o)
);

if_id if_id_U1(
    .clk        (clk),
    .rstn       (rstn),
    .hold_flag_i(ctrl_hold_flag_o),
    .inst_addr_i(pc_pc_o),
    .inst_i     (inst_i),
    .inst_addr_o(if_id_inst_addr_o),
    .inst_o     (if_id_inst_o)
);

id id_U1(
    .inst_addr_i     (if_id_inst_addr_o),
    .inst_i          (if_id_inst_o),
    .reg1_raddr_o    (id_reg1_raddr_o),
    .reg2_raddr_o    (id_reg2_raddr_o),
    .reg1_rdata_i    (regs_reg1_rdata_o),
    .reg2_rdata_i    (regs_reg2_rdata_o),
    .inst_addr_o     (id_inst_addr_o),
    .inst_o          (id_inst_o),
    .op1_o           (id_op1_o),
    .op2_o           (id_op2_o),
    .jump_base_addr_o(id_jump_base_addr_o),
    .jump_offs_addr_o(id_jump_offs_addr_o),
    .reg1_rdata_o    (id_reg1_rdata_o),
    .reg2_rdata_o    (id_reg2_rdata_o),
    .rd_wen_o        (id_rd_wen_o),
    .rd_waddr_o      (id_rd_waddr_o)
);

id_ex id_ex_U1(
    .clk             (clk),
    .rstn            (rstn),
    .hold_flag_i     (ctrl_hold_flag_o),
    .inst_addr_i     (id_inst_addr_o),
    .inst_i          (id_inst_o),
    .op1_i           (id_op1_o),
    .op2_i           (id_op2_o),
    .jump_base_addr_i(id_jump_base_addr_o),
    .jump_offs_addr_i(id_jump_offs_addr_o),
    .reg1_rdata_i    (id_reg1_rdata_o),
    .reg2_rdata_i    (id_reg2_rdata_o),
    .rd_wen_i        (id_rd_wen_o),
    .rd_waddr_i      (id_rd_waddr_o),
    .inst_addr_o     (id_ex_inst_addr_o),
    .inst_o          (id_ex_inst_o),
    .op1_o           (id_ex_op1_o),
    .op2_o           (id_ex_op2_o),
    .jump_base_addr_o(id_ex_jump_base_addr_o),
    .jump_offs_addr_o(id_ex_jump_offs_addr_o),
    .reg1_rdata_o    (id_ex_reg1_rdata_o),
    .reg2_rdata_o    (id_ex_reg2_rdata_o),
    .rd_wen_o        (id_ex_rd_wen_o),
    .rd_waddr_o      (id_ex_rd_waddr_o)
);

ex ex_U1(
    .inst_addr_i     (id_ex_inst_addr_o),
    .inst_i          (id_ex_inst_o),
    .op1_i           (id_ex_op1_o),
    .op2_i           (id_ex_op2_o),
    .jump_base_addr_i(id_ex_jump_base_addr_o),
    .jump_offs_addr_i(id_ex_jump_offs_addr_o),
    .reg1_rdata_i    (id_ex_reg1_rdata_o),
    .reg2_rdata_i    (id_ex_reg2_rdata_o),
    .rd_wen_i        (id_ex_rd_wen_o),
    .rd_waddr_i      (id_ex_rd_waddr_o),
    .mem_req_o       (mem_req_o),
    .mem_wen_o       (mem_wen_o),
    .mem_waddr_o     (mem_waddr_o),
    .mem_wdata_o     (mem_wdata_o),
    .mem_raddr_o     (mem_raddr_o),
    .mem_rdata_i     (mem_rdata_i),
    .div_start_o     (ex_div_start_o),
    .div_dividend_o  (ex_div_dividend_o), 
    .div_divisor_o   (ex_div_divisor_o),  
    .div_op_o        (ex_div_op_o),       
    .div_reg_waddr_o (ex_div_reg_waddr_o),
    .div_ready_i     (div_ready_o),   
    .div_result_i    (div_result_o),  
    .div_busy_i      (div_busy_o),    
    .div_reg_waddr_i (div_reg_waddr_o),
    .reg_wen_o       (ex_reg_wen_o),
    .reg_waddr_o     (ex_reg_waddr_o),
    .reg_wdata_o     (ex_reg_wdata_o),
    .hold_flag_o     (ex_hold_flag_o),
    .jump_flag_o     (ex_jump_flag_o),
    .jump_addr_o     (ex_jump_addr_o)
);

regs regs_U1(
    .clk         (clk),
    .rstn        (rstn),
    .reg1_raddr_i(id_reg1_raddr_o),
	.reg2_raddr_i(id_reg2_raddr_o),
	.reg1_rdata_o(regs_reg1_rdata_o),
	.reg2_rdata_o(regs_reg2_rdata_o),
    .reg_wen_i   (ex_reg_wen_o),
    .reg_waddr_i (ex_reg_waddr_o),
    .reg_wdata_i (ex_reg_wdata_o)
);

ctrl ctrl_U1(
    .hold_flag_i(ex_hold_flag_o),
    .jump_flag_i(ex_jump_flag_o),
    .jump_addr_i(ex_jump_addr_o),
    .bus_hold_flag_i(hold_flag_i),
    .hold_flag_o(ctrl_hold_flag_o),
    .jump_flag_o(ctrl_jump_flag_o),
    .jump_addr_o(ctrl_jump_addr_o)
);

div div_U1(
    .clk        (clk),
    .rstn       (rstn),
    .start_i    (ex_div_start_o),
    .dividend_i (ex_div_dividend_o),
    .divisor_i  (ex_div_divisor_o),
    .op_i       (ex_div_op_o),
    .reg_waddr_i(ex_div_reg_waddr_o),
    .result_o   (div_result_o),
    .ready_o    (div_ready_o),
    .busy_o     (div_busy_o),
    .reg_waddr_o(div_reg_waddr_o)
);

endmodule