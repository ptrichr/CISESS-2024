`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nathan Ho
// 
// Create Date: 06/03/2024 10:29:34 AM
// Design Name: 
// Module Name: switch_clock_divider
// Project Name: CISESS-Summer-2024
// Target Devices: Digilent Arty S7 Spartan
// Tool Versions: 
// Description: Generates a PWM signal @ 2083 KHz, 50% Duty Cycle
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Use high-speed PMOD port as output fo this (JA, JB)
// 
//////////////////////////////////////////////////////////////////////////////////


module switch_clock_divider(
    input wire clk,
//  input wire clr,
    output reg clk_enable
);

integer count;

initial begin
    count = 0;
end

// factor of 48000 downscales 100MHz to 2.083KHz
always @(posedge clk) 
begin
    // up time
    if (count < 23999)
    begin
        clk_enable <= 1;
        count <= count + 1;
    end
    // down time
    else 
    begin
        if (count < 47999) 
        begin
            clk_enable <= 0;
            count <= count + 1;
        end
        // reset
        else 
        begin
            clk_enable <= 1;
            count <= 0;
        end
    end
end 

endmodule
