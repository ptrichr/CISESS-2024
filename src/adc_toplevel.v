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
// Description: ADC for demodulation of signal
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adc_toplevel(
    input clk,                              // R2
//  input clr,
    input switch_signal,                    // pin that the switching signal will be read from: A0
    input feed_signal,                      // pin that the feedhorn signal will be read from: A1
    output reg demod
);


    // make sure to ground the pins labeled V_P and V_N
    // demo for more pin assignments


    wire enable;  
    wire ready;
    reg ready_d1;
    wire ready_rising;
    wire ready_falling;
    wire [15:0] data;                        // the 12 most significant bits store the data we need
    reg [6:0] Address_in;
   
    reg sample;                              // chooses between switch signal (A0) and feed signal (A1)
    reg [1023:0] feed_accumulator;           // unpacked array of 1024 samples to store feed signal
    reg [1023:0] switch_accumulator;         // unpacked array of 1024 samples to store switch signal
    integer i;                               // keeps track of position in switch array
    integer j;                               // keeps track of position in feed array
    integer counter;                         // keeps track of position in both arrays for demodulation
    integer Von;                             // for demodulation. keeps track of total "value" for segments where the switch is closed
    integer on_count;                        // for demodulation. keeps track of number of values for segments where the switch is closed
    integer Voff;                            // for demodulation. keeps track of total "value" for segments where the switch is open
    integer off_count;                       // for demodulation. keeps track of number of values for segments where the switch is open
   
    parameter max_samples = 1024;            // max number of samples
   
    // initializes variables
    initial
    begin
        sample = 0;                         // 0 means A0, 1 means A1
        i = 0;
        j = 0;
        counter = 0;
        Von = 0;
        Voff = 0;
        on_count = 0;
        off_count = 0;
        feed_accumulator = 0;
        switch_accumulator = 0;
    end

    //xadc instantiation connect the eoc_out .den_in to get continuous conversion

    xadc_wiz_0 xadc
    (
//        i have no clue what these are 
        .daddr_in(Address_in),                      // Address bus for the dynamic reconfiguration port
        .dclk_in(clk),                              // Clock input for the dynamic reconfiguration port
        .den_in(enable),                            // Enable Signal for the dynamic reconfiguration port
        .di_in(0),                                  // Input data bus for the dynamic reconfiguration port
        .dwe_in(0),                                 // Write Enable for the dynamic reconfiguration port
        .reset_in(0),                               // Reset signal for the System Monitor control logic
        .busy_out(),                                // ADC Busy signal
        .channel_out(),                             // Channel Selection Outputs
        .do_out(data),                              // Output data bus for dynamic reconfiguration port
        .eoc_out(enable),                           // End of Conversion Signal
        .eos_out(),                                 // End of Sequence Signal
        .alarm_out(),                               // OR'ed output of all the Alarms  
        .drdy_out(ready),                           // Data ready signal for the dynamic reconfiguration port
        
        // check the demo for i/o ports
//      .vp_in(vp_in),                              // input wire vp_in (i think these are reference pins, this is positive reference)
//      .vn_in(vn_in),                              // input wire vn_in (ground reference)
        .vauxp0(switch_signal),                     // input wire vauxp0 (analog input - switching)
        .vauxn0(vauxn0),                            // input wire vauxn0 (grounded? check schematic)
        .vauxp1(feed_signal),                       // input wire vauxp1 (analog input - feed)
        .vauxn1(vauxn1)                             // input wire vauxn1 (grounded? check schematic)
    );
    
    always @(posedge clk)
    begin
        ready_d1 <= ready;
    end
      
    assign ready_rising = ready && !ready_d1 ? 1'b1 : 1'b0;
    assign ready_falling = !ready && ready_d1 ? 1'b1 : 1'b0;
      
    // driver switches between the feed and switch signals
    always @(posedge clk)
    begin
        if (ready_rising == 1)
        begin
            if (sample == 0)
            begin
                Address_in <= 8'h10;                // sample from A0 (switch)
                sample = 1;                         // next sample from A1
                if (i < max_samples)                // write the data to the accumulator
                begin
                    switch_accumulator[i] = data[15:4];
                    i = i + 1;
                end
            end
            else
            begin
                Address_in <= 8'h11;                // sample from A1 (feed)
                sample = 0;                         // next sample from A0
                if (j < max_samples)                // write the data to the accumulator
                begin
                    feed_accumulator[j] = data[15:4];
                    j = j + 1;
                end
            end
        end
        else
            Address_in <= Address_in;
    end
    
    // assign the outbound demod data
    always @(i or j) begin
        if (i == max_samples && j == max_samples)
        begin
            for (counter = 1; counter < 1023; counter = counter + 1)
            begin
                // if the signal from switch is low to the left and right, that means this sample is high
                // here we are using the same assumption that the signal will be less than 512
                if (switch_accumulator[counter - 1] < 512 && switch_accumulator[counter + 1] < 512)
                begin
                    Von = Von + feed_accumulator[counter];
                    on_count = on_count + 1;
                end
                // otherwise, we have the left and right being high, so this sample is low
                else
                begin
                    Voff = Voff + feed_accumulator[counter];
                    off_count = off_count + 1;
                end                
            end
            
            // assign demod
            demod = (Voff / off_count) - (Von / on_count);
        end
    end
    
endmodule
