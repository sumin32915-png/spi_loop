`timescale 1ns/1ps
// UART 송신 8N1. CLKS_PER_BIT = 50 MHz / 9600 = 5208
module uart_tx #(parameter CLKS_PER_BIT = 5208)(
    input  wire       clk_50mhz,
    input  wire       rst_p,
    input  wire       start,
    input  wire [7:0] data,
    output reg        tx,
    output wire       busy
);
    reg [9:0]  frame;
    reg [3:0]  bit_idx;
    reg [15:0] count;
    reg        active;
    assign busy = active;

    always @(posedge clk_50mhz) begin
        if (rst_p) begin
            tx <= 1'b1; active <= 1'b0; bit_idx <= 4'd0; count <= 16'd0; frame <= 10'h3FF;
        end else if (!active) begin
            tx <= 1'b1;
            if (start) begin
                frame <= {1'b1, data, 1'b0};   // 정지, 데이터(LSB 먼저), 시작
                active <= 1'b1; bit_idx <= 4'd0; count <= 16'd0;
                tx <= 1'b0;
            end
        end else if (count == CLKS_PER_BIT - 1) begin
            count <= 16'd0;
            if (bit_idx == 4'd9) begin
                active <= 1'b0; tx <= 1'b1;
            end else begin
                bit_idx <= bit_idx + 4'd1;
                tx <= frame[bit_idx + 4'd1];
            end
        end else begin
            count <= count + 16'd1;
        end
    end
endmodule