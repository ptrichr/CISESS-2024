`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2024 11:36:19 AM
// Design Name: 
// Module Name: adc_clock_divider
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


module adc_clock_divider (
input           clk         ,
output  reg     clk_enable
);

integer count;

initial begin
    count = 0;
end

// factor of 3000 downscales 100MHz to 33.33KHz
always @(posedge clk) 
begin
    // up time
    if (count < 1499)
    begin
        clk_enable <= 1;
        count <= count + 1;
    
    end
    // down time 
    else 
    begin
        if (count < 2999) 
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
