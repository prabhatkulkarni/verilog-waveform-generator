`timescale 1ns / 1ps

// Programmable square-wave generator.
// The output toggles after the selected number of input-clock cycles.
// With a 10 MHz input clock, the supported output frequencies are
// 10 kHz, 100 kHz, 500 kHz, and 1 MHz.
module waveform_generator (
    input  wire       clk,
    input  wire       rst,       // Active-high synchronous reset
    input  wire [1:0] freq_sel,
    output reg        wave_out
);

    reg [8:0] counter;
    reg [8:0] terminal_count;

    // Select the number of input-clock cycles between output toggles.
    always @(*) begin
        case (freq_sel)
            2'b00:   terminal_count = 9'd499;
            2'b01:   terminal_count = 9'd49;
            2'b10:   terminal_count = 9'd9;
            2'b11:   terminal_count = 9'd4;
            default: terminal_count = 9'd499;
        endcase
    end

    // Synchronous counter and output toggle logic.
    always @(posedge clk) begin
        if (rst) begin
            counter  <= 9'd0;
            wave_out <= 1'b0;
        end else if (counter >= terminal_count) begin
            counter  <= 9'd0;
            wave_out <= ~wave_out;
        end else begin
            counter <= counter + 1'b1;
        end
    end

endmodule
