`timescale 1ns/1ps
// 과제12 TB: 마스터 FPGA(과제11 회로)와 슬레이브 FPGA(과제10 회로)를 연결한다.
module tb;
    reg clk=0, rst=1;
    always #10 clk = ~clk;
    reg [7:0] sw = 8'h3C;
    wire sck, cs_n, mosi, txd;
    wire [7:0] led_m, led_s;
    spi_master_top #(.HALF_CYCLES(25), .SEND_CYCLES(2000)) fpga_a(clk, rst, sw, sck, cs_n, mosi, led_m);
    spi_rx_uart   #(.CLKS_PER_BIT(16)) fpga_b(clk, rst, sck, cs_n, mosi, txd, led_s);
    integer n = 0; reg [7:0] vals [0:2];
    initial begin vals[0]=8'h3C; vals[1]=8'hC3; vals[2]=8'h81; end
    always @(posedge fpga_b.u_rx.rx_valid) begin
        #1;
        if (fpga_b.u_rx.rx_data !== vals[n]) $fatal(1, "loop expected=%02X got=%02X", vals[n], fpga_b.u_rx.rx_data);
        $display("FPGA A sent %02X, FPGA B received %02X", vals[n], fpga_b.u_rx.rx_data);
        n = n + 1;
        if (n < 3) sw = vals[n];
    end
    initial begin
        $dumpfile("wave.vcd"); $dumpvars(0, tb);
        repeat (4) @(posedge clk); rst = 0;
        wait (n == 3);
        $display("PASS SPI LOOP: FPGA to FPGA 3C C3 81");
        $finish;
    end
    initial begin #500_000; $fatal(1, "timeout"); end
endmodule