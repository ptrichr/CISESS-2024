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
    output reg [3:0] LED,
    output reg [11:0] denoise
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
integer on_data;
integer off_data;
reg on_ready;
reg off_ready;


//-----------------------------------------------------------------------------
// clock divider for ADC 100MHz -> 33.33kHz
wire clk_en;

adc_clock_divider
d(
.clk            (clk            ),
.clk_enable     (clk_en         )
);


//-----------------------------------------------------------------------------
// xadc instantiation connect the eoc_out .den_in to get continuous conversion
// xadc dclk needs the system clock (100MHz)
xadc_wiz_0 xadc
(
    .daddr_in(8'h10),                                   // Address bus for the dynamic reconfiguration port
    .dclk_in(clk),                                      // Clock input for the dynamic reconfiguration port
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
    
    .vp_in(),
    .vn_in(),
    .vauxp0(feed_signal),
    .vauxn0(feed_ground)
);


//-----------------------------------------------------------------------------
// driver signals for XADC IP
always @(posedge clk_en)
begin
    ready_d1 <= ready;
end


assign ready_rising = ready && !ready_d1 ? 1'b1 : 1'b0;
assign ready_falling = !ready && ready_d1 ? 1'b1 : 1'b0;


//led visual dmm              
always @(posedge clk)
begin
  if (ready_rising == 1)
  begin
      case (data[15:13])
        4: LED <= 4'b0001;
        5: LED <= 4'b0011;
        6: LED <= 4'b0111;
        7: LED <= 4'b1111;
        default: LED <= 6'b0; 
      endcase
  end
  else
      LED <= LED;
end

//always @(*)
//begin
//    denoise <= data[15:4];
//end

//-----------------------------------------------------------------------------
// Denoise logic

// collect data from either on or off. if data has been collected from both, reset
always @(posedge clk_en)
begin
    if (on_ready == 1 && off_ready == 1)
    begin
        on_ready <= 0;
        off_ready <= 0;
    end

    if (switch_pwm == 1)
    begin
        on_data <= data[15:4];
        on_ready <= 1;
    end
    else
    begin
        off_data <= data[15:4];
        off_ready <= 1;
    end
end

// assign denoise.
always @(*)
begin
    if (on_data > off_data)
        denoise <= on_data - off_data;
    else
        denoise <= 0;           // handles underflow
        
    on_ready <= 0;
    off_ready <= 0;
end


endmodule
