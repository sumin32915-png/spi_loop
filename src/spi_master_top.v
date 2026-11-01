`timescale 1ns/1ps
// 과제11 최상위: 1초마다 DIP 스위치 값을 SPI로 보내고 LED에 표시한다.
module spi_master_top #(parameter HALF_CYCLES = 50, parameter SEND_CYCLES = 50_000_000)(
    input  wire       clk_50mhz,
    input  wire       rst_p,
    input  wire [7:0] sw,
    output wire       spi_sck,
    output wire       spi_cs_n,
    output wire       spi_mosi,
    output reg  [7:0] led
);
    reg  [31:0] tick_count;
    wire        tick = (tick_count == SEND_CYCLES - 1);
    wire        busy, done;

    always @(posedge clk_50mhz)
        if (rst_p || tick) tick_count <= 32'd0;
        else tick_count <= tick_count + 32'd1;

    spi_master_tx #(.HALF_CYCLES(HALF_CYCLES)) u_spi(
        clk_50mhz, rst_p, tick & ~busy, sw, spi_sck, spi_cs_n, spi_mosi, busy, done);

    always @(posedge clk_50mhz)
        if (rst_p) led <= 8'd0;
        else if (tick & ~busy) led <= sw;
endmodule