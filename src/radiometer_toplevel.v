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
    input clk,              // R2
//    input clr,
    input feed_signal,
    output switch_pwm,
    output demod
);  
    switch_clock_divider s(.clk(clk), .clk_enable(switch_pwm));
    adc_toplevel a(.clk(clk), .switch_signal(switch_pwm), .feed_signal(feed_signal), .demod(demod));
endmodule
