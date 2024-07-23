`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2024 02:06:51 PM
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx (
    input wire clk,            // 100 MHz clock input
    input wire reset,          // Reset
    input wire [11:0] data,    // 12-bit data input
    input wire start,          // Start transmission signal
    output reg uart_txd,       // UART TXD pin
    output reg busy            // Busy
);

// Baud rate calculation
localparam BAUD_RATE = 115200;
localparam CLOCK_FREQ = 100_000_000;
localparam BAUD_COUNTER_MAX = CLOCK_FREQ / BAUD_RATE;

// UART state machine states
localparam IDLE = 3'b000,
           START1 = 3'b001,
           DATA1 = 3'b010,
           STOP1 = 3'b011,
           NEXT = 3'b100,
           START2 = 3'b101,
           DATA2 = 3'b110,
           STOP2 = 3'b111;

reg [2:0] present_state, next_state;

// Counter for baud rate
reg [15:0] baud_counter;

// reg to hold data halves, bit counter to keep position
reg [7:0] byte1, byte2;
reg [3:0] bit_counter;

// split demod data into 2 bytes
always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        byte1 <= 8'b0;
        byte2 <= 8'b0;
    end
    else if (start)
    begin
        byte1 <= {4'b0000, data[11:8]}; // 4 MSBs padded with 4 zeros
        byte2 <= data[7:0];             // 8 LSBs
    end
end

// FSM
always @(posedge clk or posedge reset)
begin
    if (reset)                          // idle when reset is enabled
    begin
        present_state <= IDLE;
        baud_counter <= 0;
        bit_counter <= 0;
        uart_txd <= 1'b1;
        busy <= 1'b0;
    end
    else                                // normal output logic
    begin
        present_state <= next_state;
        case (present_state)
            IDLE:
            begin
                uart_txd <= 1'b1;
                if (start)
                begin
                    busy <= 1'b1;
                    next_state <= START1;
                end
                else
                begin
                    busy <= 1'b0;
                end
            end

            START1:
            begin
                if (baud_counter == BAUD_COUNTER_MAX)
                begin
                    uart_txd <= 1'b0; // Start bit
                    baud_counter <= 0;
                    bit_counter <= 0;
                    next_state <= DATA1;
                end
                else
                begin
                    baud_counter <= baud_counter + 1;
                end
            end

            DATA1:
            begin
                if (baud_counter == BAUD_COUNTER_MAX)
                begin
                    baud_counter <= 0;
                    uart_txd <= byte1[bit_counter]; // Send bits of byte1
                    bit_counter <= bit_counter + 1;
                    if (bit_counter == 7) begin
                        next_state <= STOP1;
                    end
                end
                else
                begin
                    baud_counter <= baud_counter + 1;
                end
            end

            STOP1:
            begin
                if (baud_counter == BAUD_COUNTER_MAX)
                begin
                    uart_txd <= 1'b1; // Stop bit
                    baud_counter <= 0;
                    next_state <= NEXT;
                end
                else
                begin
                    baud_counter <= baud_counter + 1;
                end
            end

            NEXT:
            begin
                if (baud_counter == BAUD_COUNTER_MAX)
                begin
                    uart_txd <= 1'b0; // Start bit for next byte
                    baud_counter <= 0;
                    bit_counter <= 0;
                    next_state <= DATA2;
                end
                else
                begin
                    baud_counter <= baud_counter + 1;
                end
            end

            DATA2:
            begin
                if (baud_counter == BAUD_COUNTER_MAX)
                begin
                    baud_counter <= 0;
                    uart_txd <= byte2[bit_counter]; // Send bits of byte2
                    bit_counter <= bit_counter + 1;
                    if (bit_counter == 7) begin
                        next_state <= STOP2;
                    end
                end
                else
                begin
                    baud_counter <= baud_counter + 1;
                end
            end
            STOP2:
            begin
                if (baud_counter == BAUD_COUNTER_MAX)
                begin
                    uart_txd <= 1'b1; // Stop bit
                    baud_counter <= 0;
                    busy <= 1'b0;
                    next_state <= IDLE;
                end
                else
                begin
                    baud_counter <= baud_counter + 1;
                end
            end
        endcase
    end
end

endmodule






