`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2024 10:40:30 AM
// Design Name: 
// Module Name: impl_top
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

module datapath (
input               clk             , // Top level system clock input.
input               demod_1         , // Demod data
input               demod_2         ,
input               transmit_1      , // Signal to transmit demod_1
input               transmit_2      , // Signal to transmit demod_2
output  reg         uart_tx_en      , // Enable UART
output  reg [7:0]   uart_tx_data      // UART data
);


//-----------------------------------------------------------------------------
always @(transmit_1 or transmit_2)
begin
    if (transmit_1 == 0 && transmit_2 == 0)
        uart_tx_en <= 0;
    else
    begin
        if (transmit_1 == 1)
        begin
            uart_tx_data <= demod_1;
            uart_tx_en <= 1;
        end
        
        if (transmit_2 == 1)
        begin
            uart_tx_data <= demod_2;
            uart_tx_en <= 1;
        end
    end
    
end


endmodule
