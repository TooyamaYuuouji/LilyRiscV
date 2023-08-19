//--------------------------------------------------
// 使用旧指令集（old_isa）进行测试的tb文件

`timescale 1ns/1ps

module top_tb_oi();

logic clk;
logic rstn;
wire[1:0] gpio;
logic tx, rx;

logic[31:0] x3, x26, x27;

always_comb begin
    x3 = top_tb_oi.DUT.LilyRiscv_U1.regs_U1.x[3];
    x26 = top_tb_oi.DUT.LilyRiscv_U1.regs_U1.x[26];
    x27 = top_tb_oi.DUT.LilyRiscv_U1.regs_U1.x[27];
end

initial begin: clk_gen
    clk = 0;
    forever begin
        #10 clk = ~clk;
    end
end

initial begin: reset
    rstn = 0;
    #30;
    rstn = 1;	
end

// rom 初始值
// 视情况，readmemh 的路径可能需要根据vvp文件的路径进行修改
initial begin
    $readmemh("./inst.data", top_tb_oi.DUT.rom_U1.rom_mem);
end

integer ii;
initial begin
    $display("test running...");
    wait(x26 == 32'b1); // wait sim end
    #200;
    if(x27 == 32'b1) begin
        $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#####     ##     ####    #### ~~~~~~~~~");
        $display("~~~~~~~~~~#    #   #  #   #       #     ~~~~~~~~~");
        $display("~~~~~~~~~~#    #  #    #   ####    #### ~~~~~~~~~");
        $display("~~~~~~~~~~#####   ######       #       #~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #  #    #  #    #~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #   ####    #### ~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end else begin
        $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
        $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
        $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
        $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("fail testnum = %2d", x3);
        for (ii = 0; ii < 32; ii ++) begin
            $display("x[%2d] = 0x%x", ii, top_tb_oi.DUT.LilyRiscv_U1.regs_U1.x[ii]);
        end
    end
    $finish();
end

// sim timeout
initial begin
    #5000;
    $display("tb running time out!!!");
    $finish();
end


LilyRiscv_soc DUT(
    .clk (clk),
    .rstn(rstn),
    .uart_tx_pin(tx),
    .uart_rx_pin(rx),
    .gpio(gpio)
);

initial begin
    $dumpfile("top_tb_oi.vcd");
    $dumpvars(0, top_tb_oi);
end

endmodule : top_tb_oi
