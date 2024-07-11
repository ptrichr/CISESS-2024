`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2024 03:04:40 PM
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


module uart_toplevel (
input               clk         ,   // System clock
input               sw_0        ,   // Enable switch
input  [11:0]       demod       ,   // Demod data
output              uart_txd    ,   // UART transmission pin
output              busy            // UART busy signal
);

wire transmit_top, transmit_bottom, uart_tx_en, en;
wire  [7:0]     demod_1;
wire  [7:0]     demod_2;
wire  [7:0]     uart_tx_data;

// split the demod data
assign demod_1 = {4'b0000, demod[11:8]};
assign demod_2 = demod[7:0];


//-------------------------------------------------------------------
// datapath controller

controller
c(
// inputs
.clk            (clk            ),
.busy           (busy           ),
.demod_1        (demod_1        ),
.demod_2        (demod_2        ),

// outputs
.transmit_top   (transmit_top   ),
.transmit_bottom(transmit_bottom)
);


//-------------------------------------------------------------------
// datapath

datapath
d(
// inputs
.clk            (clk            ),
.demod_1        (demod_1        ),
.demod_2        (demod_2        ),
.transmit_top   (transmit_top   ),
.transmit_bottom(transmit_bottom),

// outputs
.uart_tx_en     (uart_tx_en     ),
.uart_tx_data   (uart_tx_data   )
);


//-------------------------------------------------------------------
// UART Transmitter module.

// Clock frequency in hertz.
parameter CLK_HZ = 100000000;
parameter BIT_RATE = 115200;
parameter PAYLOAD_BITS = 8;

uart_tx #(
.BIT_RATE       (BIT_RATE       ),
.PAYLOAD_BITS   (PAYLOAD_BITS   ),
.CLK_HZ         (CLK_HZ         )
) transmitter(
.clk            (clk            ),
.resetn         (sw_0           ),
.uart_txd       (uart_txd       ),
.uart_tx_en     (uart_tx_en     ),
.uart_tx_busy   (busy           ),
.uart_tx_data   (uart_tx_data   ) 
);
endmodule
