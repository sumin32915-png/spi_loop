`timescale 1ns/1ps
// SPI Mode 0 마스터 송신: 8비트, MSB부터.
// SCK는 대기 시 LOW, HALF_CYCLES 클록마다 반전 (50 -> 500 kHz).
// CS를 내리면서 MSB를 준비하고, 하강 에지마다 다음 비트로 바꾼다.
module spi_master_tx #(parameter HALF_CYCLES = 50)(
    input  wire       clk_50mhz,
    input  wire       rst_p,
    input  wire       start,
    input  wire [7:0] tx_data,
    output reg        spi_sck,
    output reg        spi_cs_n,
    output reg        spi_mosi,
    output reg        busy,
    output reg        done
);
    reg [7:0]  shreg;
    reg [3:0]  rises;               // 지금까지 만든 상승 에지 수
    reg [15:0] count;

    always @(posedge clk_50mhz) begin
        if (rst_p) begin
            spi_sck <= 1'b0; spi_cs_n <= 1'b1; spi_mosi <= 1'b0;
            busy <= 1'b0; done <= 1'b0; shreg <= 8'd0; rises <= 4'd0; count <= 16'd0;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                if (start) begin
                    shreg <= tx_data;
                    spi_mosi <= tx_data[7];    // 첫 상승 에지 전에 MSB 준비
                    spi_cs_n <= 1'b0;
                    busy <= 1'b1; rises <= 4'd0; count <= 16'd0;
                end
            end else if (count == HALF_CYCLES - 1) begin
                count <= 16'd0;
                if (!spi_sck) begin
                    if (rises == 4'd8) begin   // 8비트 끝: CS 해제
                        spi_cs_n <= 1'b1; busy <= 1'b0; done <= 1'b1;
                    end else begin
                        spi_sck <= 1'b1;       // 상승 에지: 수신 측이 읽음
                        rises <= rises + 4'd1;
                    end
                end else begin
                    spi_sck <= 1'b0;           // 하강 에지: 다음 비트 준비
                    shreg <= {shreg[6:0], 1'b0};
                    spi_mosi <= shreg[6];
                end
            end else begin
                count <= count + 16'd1;
            end
        end
    end
endmodule