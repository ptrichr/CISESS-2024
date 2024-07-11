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
input               switch_signal   ,           // loop this from the output
input               switch_ground   ,
input               sw_0            ,           // UART enable switch

output              switch_pwm      ,           // switching PWM output
output  wire        uart_txd        ,           // UART transmission pin
output  wire        busy                        // UART busy LED
);  

wire adc_enable;

// instantiate switch module
switch_clock_divider
s(
.clk            (clk            ), 
.clk_enable     (switch_pwm     )
);
                       

// instantiate ADC module                       
adc_toplevel
a(
.clk            (adc_enable     ), 
.switch_signal  (switch_signal  ), 
.switch_ground  (switch_ground  ), 
.feed_signal    (feed_signal    ), 
.feed_ground    (feed_ground    ), 
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

endmodule
