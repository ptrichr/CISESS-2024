`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2024 01:55:55 PM
// Design Name: 
// Module Name: hz
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


module div (
input           clk ,
output  reg     en
);

integer count = 0;

always @(negedge clk)
begin
    if (count == 4999)
    begin
        en <= 1;
        count <= 0;
    end
    else
    begin
        en <= 0;
        count <= count + 1;
    end
end
endmodule
