`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nathan Ho
// 
// Create Date: 06/04/2024 10:17:50 AM
// Design Name: 
// Module Name: adc_toplevel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: ADC for demodulation of signal.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adc_toplevel(
    input clk,                                              // System clock
    input switch_pwm,                                       // switching PWM
    input feed_signal,                                      // B13 (A0 on board)
    input feed_ground,
    output wire [11:0] demod
);

// make sure to ground the pins labeled V_P and V_N


// ADC variables
wire enable;  
wire ready;
reg ready_d1;
wire ready_rising;
wire ready_falling;
wire [15:0] data;                                       // the 12 most significant bits store the data we need
reg [6:0] Address_in;

// Storing data for demodulation
reg [11:0] on_data;
reg [11:0] off_data;


//-----------------------------------------------------------------------------
// clock divider for ADC 100MHz -> 33.33kHz ? though i think this should be 16.67kHz now.
wire clk_en;

adc_clock_divider
d(
.clk            (clk            ),
.clk_enable     (clk_en         )
);


//-----------------------------------------------------------------------------
// xadc instantiation connect the eoc_out .den_in to get continuous conversion
xadc_wiz_0 xadc
(
    .daddr_in(8'h10),                                   // Address bus for the dynamic reconfiguration port
    .dclk_in(clk_en),                                   // Clock input for the dynamic reconfiguration port
    .den_in(enable),                                    // Enable Signal for the dynamic reconfiguration port
    .di_in(0),                                          // Input data bus for the dynamic reconfiguration port
    .dwe_in(0),                                         // Write Enable for the dynamic reconfiguration port
    .reset_in(0),                                       // Reset signal for the System Monitor control logic
    .busy_out(),                                        // ADC Busy signal
    .channel_out(),                                     // Channel Selection Outputs
    .do_out(data),                                      // Output data bus for dynamic reconfiguration port
    .eoc_out(enable),                                   // End of Conversion Signal
    .eos_out(),                                         // End of Sequence Signal
    .alarm_out(),                                       // OR'ed output of all the Alarms  
    .drdy_out(ready),                                   // Data ready signal for the dynamic reconfiguration port
    
    // check the demo for i/o ports
    .vp_in(),                                           // input wire vp_in (i think these are reference pins, this is positive reference)
    .vn_in(),                                           // input wire vn_in (ground reference)
    .vauxp0(feed_signal),                               // input wire vauxp0 (analog input - switching)
    .vauxn0(feed_ground)                                // input wire vauxn0 (grounded? check schematic)
);


//-----------------------------------------------------------------------------
// driver signals for XADC IP
always @(posedge clk_en)
begin
    ready_d1 <= ready;
end


assign ready_rising = ready && !ready_d1 ? 1'b1 : 1'b0;
assign ready_falling = !ready && ready_d1 ? 1'b1 : 1'b0;

assign demod = data[15:4];      // for testing XADC

//-----------------------------------------------------------------------------
// Demodulation logic
// signal demodulation needs to be T_switching - T_vapor
// this means that we need to subtract when the switch is high from when the switch is low.
// this data resolution is kinda low though, there's only 1 sample per clock cycle

// switch is high -> sample for on
//always @(posedge switch_pwm)
//begin
//    on_data <= data[15:4];
//end

//// switch is low -> sample for off
//always @(negedge switch_pwm)
//begin
//    off_data <= data[15:4];
//end

//assign demod = on_data - off_data;

endmodule
