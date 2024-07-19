`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2024 11:12:54 AM
// Design Name: 
// Module Name: radiometer_toplevel
// Project Name: CISESS-Summer-2024
// Target Devices: Digilent Arty S7 Spartan
// Tool Versions: 
// Description: Back-end signal processing unit for CISESS's microwave radiometer project, generates a switching signal and ADC
//              for 22GHz band signals
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module radiometer_toplevel(
input               clk             ,           // R2, internal 100MHz clock
input               feed_signal     ,
input               feed_ground     ,
input               sw_0            ,           // UART enable switch

output  wire        switch_pwm      ,           // switching PWM output
output  wire        uart_txd        ,           // UART transmission pin
output  wire        busy,                        // UART busy LED
output wire [3:0] LED
);  

wire adc_enable;
wire [11:0] demod;

// instantiate switch module
switching
s(
.clk            (clk            ), 
.pwm            (switch_pwm     )
);
                       

// instantiate ADC module                       
adc_toplevel
a(
.clk            (clk            ), 
.switch_pwm     (switch_pwm     ), 
.feed_signal    (feed_signal    ), 
.feed_ground    (feed_ground    ),
.LED            (LED), 
.demod          (demod          )
);

// uart
uart_toplevel
u(
.clk            (clk            ),
.sw_0           (sw_0           ),
.demod          (demod          ),
.uart_txd       (uart_txd       ),
.busy           (busy           )
);

//parameter CLK_HZ = 100000000;
//parameter BIT_RATE = 115200;
//parameter PAYLOAD_BITS = 8;

//uart_tx #(
//.BIT_RATE       (BIT_RATE       ),
//.PAYLOAD_BITS   (PAYLOAD_BITS   ),
//.CLK_HZ         (CLK_HZ         )
//) transmitter(
//.clk            (clk            ),
//.resetn         (sw_0           ),
//.uart_txd       (uart_txd       ),
//.uart_tx_en     (1'b1     ),
//.uart_tx_busy   (busy           ),
//.uart_tx_data   (demod[7:0]          ) 
//);

endmodule
