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


module radiometer (
input               clk             ,           // R2, internal 100MHz clock
input               feed_signal     ,
input               feed_ground     ,
input               sw_0            ,           // UART enable switch

output  wire        switch_pwm      ,           // switching PWM output
output  wire        uart_txd        ,           // UART transmission pin
output  wire        busy,                       // UART busy LED
output  wire [3:0]  LED
);  

wire [11:0] denoise;

// instantiate switch module
switch_controller
s(
.clk            (clk            ), 
.pwm            (switch_pwm     )
);
                       

// instantiate ADC module                       
adc
a(
.clk            (clk            ), 
.switch_pwm     (switch_pwm     ), 
.feed_signal    (feed_signal    ), 
.feed_ground    (feed_ground    ),
.LED            (LED            ), 
.denoise        (denoise          )
);

// uart
uart_tx
u(
.clk            (clk            ),
.reset          (sw_0           ),      // low active enable
.data           (denoise        ),
.start          (1'b1           ),
.uart_txd       (uart_txd       ),
.busy           (busy           )
);

endmodule
