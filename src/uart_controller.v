`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2024 02:48:42 PM
// Design Name: 
// Module Name: impl_controller
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


module controller (
input               clk             ,
input               busy            ,
input               demod_1         ,
input               demod_2         ,
output  reg         transmit_1      ,
output  reg         transmit_2
);

wire en;

parameter   idle = 0;
parameter   first_segment = 1;
parameter   second_segment = 2;

reg  [1:0]  present;
reg  [1:0]  next;
        
reg         demod_1_mem;
reg         demod_2_mem;

// keeps track of if switches changed
wire        changed;
assign changed = demod_1_mem != demod_1 || demod_2_mem != demod_2;


//-----------------------------------------------------------------------------
// next state logic
always @(present or busy)
begin
    case (present)

        idle:
        begin
            if (changed == 1)
                next <= first_segment;
            else
                next <= idle;
        end
        
        first_segment: next <= second_segment;
        
        second_segment: next <= idle;
    endcase
end


//-----------------------------------------------------------------------------
// update the state of the FSM
div
h(
.clk            (clk),
.en             (en)
);

// 20kHz clock drives state changes
always @(posedge en)
begin
    present <= next;
end


//-----------------------------------------------------------------------------
// transmission logic
always @(present)
begin
    case(present)
        first_segment:
        begin
            // from here we remember if the data changed at all
            demod_1_mem <= demod_1;
            demod_2_mem <= demod_2;
            
            // transmit first segment
            transmit_1 <= 1;
            transmit_2 <= 0;
        end
        
        second_segment:
        begin
            // transmit second segment
            transmit_1 <= 0;
            transmit_2 <= 1;
        end
        
        idle:
        begin
            // transmit nothing
            transmit_1 <= 0;
            transmit_2 <= 0;
        end
    endcase
end

endmodule
