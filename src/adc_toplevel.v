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
    input clk,                                              // R2 package pin
//  input clr,
    input switch_signal,                                    // pin that the switching signal will be read from: A0 (package pin: B13)
    input switch_ground,                                    // A13 package pin
    input feed_signal,                                      // pin that the feedhorn signal will be read from: A1 (package pin: B15)
    input feed_ground,                                      // A15 package pin
    output reg demod
);

    // make sure to ground the pins labeled V_P and V_N
    // demo for more pin assignments
    
    // FSM states
    reg curr_st;
    parameter sampling_st = 0;
    parameter demod_st = 1;
    
    
    // ADC variables
    wire enable;  
    wire ready;
    reg ready_d1;
    wire ready_rising;
    wire ready_falling;
    wire [15:0] data;                                       // the 12 most significant bits store the data we need
    reg [6:0] Address_in;                   
   
   
    // demod/sampling variables
    parameter max_samples = 255;                           // max number of samples
    parameter switch = 0;
    parameter feed = 1;
    reg channel;                                            // chooses between switch signal (A0) and feed signal (A1)
    reg [11:0] feed_accumulator[max_samples:0];
    reg [11:0] switch_accumulator[max_samples:0];                  // store 1024 12-bit samples
    integer i;                                              // keeps track of position in switch array
    integer j;                                              // keeps track of position in feed array
    integer counter;                                        // keeps track of position in both arrays for demodulation
    integer Von;                                            // for demodulation. keeps track of total "value" for segments where the switch is closed
    integer on_count;                                       // for demodulation. keeps track of number of values for segments where the switch is closed
    integer Voff;                                           // for demodulation. keeps track of total "value" for segments where the switch is open
    integer off_count;                                      // for demodulation. keeps track of number of values for segments where the switch is open
   
    
    // initializes variables
    initial
    begin
        curr_st = sampling_st;
        channel = 0;                                        
        i = 0;
        j = 0;
        counter = 0;
        Von = 0;
        Voff = 0;
        on_count = 0;
        off_count = 0;
    end


    // xadc instantiation connect the eoc_out .den_in to get continuous conversion
    xadc_wiz_0 xadc
    (
        .daddr_in(Address_in),                              // Address bus for the dynamic reconfiguration port
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
        
        // check the demo for i/o ports
        .vp_in(),                                           // input wire vp_in (i think these are reference pins, this is positive reference)
        .vn_in(),                                           // input wire vn_in (ground reference)
        .vauxp0(switch_signal),                             // input wire vauxp0 (analog input - switching)
        .vauxn0(switch_ground),                             // input wire vauxn0 (grounded? check schematic)
        .vauxp1(feed_signal),                               // input wire vauxp1 (analog input - feed)
        .vauxn1(feed_ground)                                // input wire vauxn1 (grounded? check schematic)
    );
    
    
    always @(posedge clk)
    begin
        ready_d1 <= ready;
    end
    
    
    assign ready_rising = ready && !ready_d1 ? 1'b1 : 1'b0;
    assign ready_falling = !ready && ready_d1 ? 1'b1 : 1'b0;
    
    
    // determine which state we are in depending on if the accumulators are full or not
    always @(i or j)
    begin
        if (i < max_samples && j < max_samples)
            curr_st = sampling_st;
        else
            curr_st = demod_st;
    end


    // demod logic
    always @(posedge clk)
    begin
        case(curr_st)
        
            // sampling mode
            sampling_st:
            begin
                if (ready_rising == 1)
                begin
                    // sampling from A0 (switch)
                    if (channel == 0)
                    begin
                        Address_in <= 8'h10;                    // address for switch pin
                        channel <= feed;                        // next sample from feed
                        if (i < max_samples)                    // write the data to the accumulator
                        begin
                            switch_accumulator[i] <= data[15:4];    
                            i = i + 1;
                        end
                    end
                    
                    // sampling from A1 (feed)
                    else
                    begin
                        Address_in <= 8'h11;                    // address for feed pin
                        channel <= switch;                      // next sample from switch
                        if (j < max_samples)                    // write the data to the accumulator
                        begin
                            feed_accumulator[j] <= data[15:4];
                            j = j + 1;
                        end
                    end
                end
                else
                begin
                    Address_in <= Address_in;
                end
            end
            
            // demod mode
            demod_st:
            begin
                for (counter = 1; counter < max_samples - 1; counter = counter + 1)
                begin
                // if the signal from switch is low to the left and right, that means this sample is high
                // here we are using the same assumption that the signal will be less than 512
                    if (switch_accumulator[counter - 1] < 512 && switch_accumulator[counter + 1] < 512)
                    
                    // high data point
                    begin
                        Von <= Von + feed_accumulator[counter];
                        on_count <= on_count + 1;
                    end
                    
                    // low data point
                    else
                    begin
                        Voff <= Voff + feed_accumulator[counter];
                        off_count <= off_count + 1;
                    end                
                end
                
                // assign demod based on formula from arduin code?
                if (off_count != 0 && on_count != 0)
                    demod <= (Voff + Von) / (off_count + on_count);
                
                // flush the variables for new cycle
                i = 0;
                j = 0;
                counter = 0;
                Von = 0;
                Voff = 0;
                on_count = 0;
                off_count = 0;
            end
        endcase            
    end
    
endmodule
