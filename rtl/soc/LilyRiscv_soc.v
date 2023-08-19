
module LilyRiscv_soc(
    input  wire clk,
    input  wire rstn,
    output wire uart_tx_pin, // UART发送引脚
    input  wire uart_rx_pin,  // UART接收引脚
    inout  wire[1:0] gpio    // GPIO引脚
);

wire[31:0] LilyRiscv_mem_waddr_o;
wire[31:0] LilyRiscv_mem_raddr_o;

// master 0 interface
wire m0_req_i;
wire m0_we_i;
wire[31:0] m0_addr_i;
wire[31:0] m0_data_i;
wire[31:0] m0_data_o;
// master 1 interface
wire[31:0] m1_addr_i;
wire[31:0] m1_data_i;
wire[31:0] m1_data_o;
wire m1_req_i;
wire m1_we_i;
// slave 0 interface
wire[31:0] s0_addr_o;
wire[31:0] s0_data_o;
wire[31:0] s0_data_i;
wire s0_we_o;
// slave 1 interface
wire[31:0] s1_addr_o;
wire[31:0] s1_data_o;
wire[31:0] s1_data_i;
wire s1_we_o;
// slave 3 interface
wire[31:0] s3_addr_o;
wire[31:0] s3_data_o;
wire[31:0] s3_data_i;
wire s3_we_o;
// slave 4 interface
wire[31:0] s4_addr_o;
wire[31:0] s4_data_o;
wire[31:0] s4_data_i;
wire s4_we_o;

// gpio
wire[1:0] io_in;
wire[31:0] gpio_ctrl;
wire[31:0] gpio_data;

// io0
assign gpio[0] = (gpio_ctrl[1:0] == 2'b01)? gpio_data[0]: 1'bz;
assign io_in[0] = gpio[0];
// io1
assign gpio[1] = (gpio_ctrl[3:2] == 2'b01)? gpio_data[1]: 1'bz;
assign io_in[1] = gpio[1];

wire hold_flag_o;

LilyRiscv LilyRiscv_U1(
    .clk        (clk),
    .rstn       (rstn),
    .mem_req_o  (m0_req_i),
    .mem_wen_o  (m0_we_i),
    .mem_waddr_o(LilyRiscv_mem_waddr_o),
    .mem_wdata_o(m0_data_i),
    .mem_raddr_o(LilyRiscv_mem_raddr_o),
    .mem_rdata_i(m0_data_o),
    .inst_addr_o(m1_addr_i),
    .inst_i     (m1_data_o),
    .hold_flag_i(hold_flag_o)
);

rom rom_U1(
    .clk   (clk),
    .rstn  (rstn),
    .wen_i (s0_we_o),
    .addr_i(s0_addr_o),
    .data_i(s0_data_o),
    .data_o(s0_data_i)
);

ram ram_U1(
    .clk   (clk),
    .rstn  (rstn),
    .wen_i (s1_we_o),
    .addr_i(s1_addr_o),
    .data_i(s1_data_o),
    .data_o(s1_data_i)
);

// uart模块例化
uart uart_U1(
    .clk(clk),
    .rst(rstn),
    .we_i(s3_we_o),
    .addr_i(s3_addr_o),
    .data_i(s3_data_o),
    .data_o(s3_data_i),
    .tx_pin(uart_tx_pin),
    .rx_pin(uart_rx_pin)
);

gpio gpio_U1(
    .clk     (clk),
    .rst     (rstn),
    .we_i    (s4_we_o),
    .addr_i  (s4_addr_o),
    .data_i  (s4_data_o),
    .data_o  (s4_data_i),
    .io_pin_i(io_in),
    .reg_ctrl(gpio_ctrl),
    .reg_data(gpio_data)
);



assign m0_addr_i = (m0_we_i == 1'b1) ? LilyRiscv_mem_waddr_o : LilyRiscv_mem_raddr_o;
rib rib_U1(
    .clk(clk),
    .rst(rstn),
    // master 0 interface
    .m0_addr_i(m0_addr_i),
    .m0_data_i(m0_data_i),
    .m0_data_o(m0_data_o),
    .m0_req_i(m0_req_i),
    .m0_we_i(m0_we_i),
    // master 1 interface
    .m1_addr_i(m1_addr_i),
    .m1_data_i(32'd0),
    .m1_data_o(m1_data_o),
    .m1_req_i(1'b1),
    .m1_we_i(1'b0),
    // master 2 interface
    .m2_addr_i(),
    .m2_data_i(),
    .m2_data_o(),
    .m2_req_i(),
    .m2_we_i(),
    // master 3 interface
    .m3_addr_i(),
    .m3_data_i(),
    .m3_data_o(),
    .m3_req_i(),
    .m3_we_i(),
    // slave 0 interface
    .s0_addr_o(s0_addr_o),
    .s0_data_o(s0_data_o),
    .s0_data_i(s0_data_i),
    .s0_we_o(s0_we_o),
    // slave 1 interface
    .s1_addr_o(s1_addr_o),
    .s1_data_o(s1_data_o),
    .s1_data_i(s1_data_i),
    .s1_we_o(s1_we_o),
    // slave 2 interface
    .s2_addr_o(),
    .s2_data_o(),
    .s2_data_i(),
    .s2_we_o(),
    // slave 3 interface
    .s3_addr_o(s3_addr_o),
    .s3_data_o(s3_data_o),
    .s3_data_i(s3_data_i),
    .s3_we_o(s3_we_o),
    // slave 4 interface
    .s4_addr_o(s4_addr_o),
    .s4_data_o(s4_data_o),
    .s4_data_i(s4_data_i),
    .s4_we_o(s4_we_o),
    // slave 5 interface
    .s5_addr_o(),
    .s5_data_o(),
    .s5_data_i(),
    .s5_we_o(),

    .hold_flag_o(hold_flag_o)
);


endmodule