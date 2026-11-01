`timescale 1ns/1ps
// SPI Mode 0 슬레이브 수신: 8비트, MSB부터, SCK 상승 에지에서 MOSI를 읽는다.
// SCK, CS, MOSI는 비동기 입력이므로 2단 플립플롭으로 동기화한 뒤 사용한다.
module spi_slave_rx(
    input  wire       clk_50mhz,
    input  wire       rst_p,
    input  wire       spi_sck,
    input  wire       spi_cs_n,
    input  wire       spi_mosi,
    output reg  [7:0] rx_data,
    output reg        rx_valid      // 한 바이트 수신 완료 시 한 클록 1
);
    reg [2:0] sck_s;                // [0],[1] 동기화, [2] 이전 값
    reg [1:0] cs_s, mosi_s;
    reg [6:0] shift;
    reg [2:0] bit_cnt;

    wire sck_rise  = sck_s[1] & ~sck_s[2];
    wire cs_active = ~cs_s[1];

    always @(posedge clk_50mhz) begin
        if (rst_p) begin
            sck_s <= 3'b000; cs_s <= 2'b11; mosi_s <= 2'b00;
            shift <= 7'd0; bit_cnt <= 3'd0;
            rx_data <= 8'd0; rx_valid <= 1'b0;
        end else begin
            sck_s  <= {sck_s[1:0], spi_sck};
            cs_s   <= {cs_s[0], spi_cs_n};
            mosi_s <= {mosi_s[0], spi_mosi};
            rx_valid <= 1'b0;
            if (!cs_active) begin
                bit_cnt <= 3'd0;            // CS 해제: 다음 바이트를 처음부터
            end else if (sck_rise) begin
                shift <= {shift[5:0], mosi_s[1]};
                bit_cnt <= bit_cnt + 3'd1;
                if (bit_cnt == 3'd7) begin  // 8번째 상승 에지
                    rx_data  <= {shift, mosi_s[1]};
                    rx_valid <= 1'b1;
                end
            end
        end
    end
endmodule