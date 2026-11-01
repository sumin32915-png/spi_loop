`timescale 1ns/1ps
// 과제10 최상위: SPI로 받은 바이트를 LED에 표시하고 UART로 PC에 보낸다.
module spi_rx_uart #(parameter CLKS_PER_BIT = 5208)(
    input  wire       clk_50mhz,
    input  wire       rst_p,
    input  wire       spi_sck,
    input  wire       spi_cs_n,
    input  wire       spi_mosi,
    output wire       uart_txd,
    output reg  [7:0] led
);
    wire [7:0] rx_data;
    wire       rx_valid, tx_busy;

    spi_slave_rx u_rx(clk_50mhz, rst_p, spi_sck, spi_cs_n, spi_mosi, rx_data, rx_valid);
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx(clk_50mhz, rst_p, rx_valid & ~tx_busy, rx_data, uart_txd, tx_busy);

    always @(posedge clk_50mhz)
        if (rst_p) led <= 8'd0;
        else if (rx_valid) led <= rx_data;
endmodule