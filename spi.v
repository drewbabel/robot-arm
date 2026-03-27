// === SPI Module: Talk to MCP3008 ADC ===
//
// This module runs one conversation with the MCP3008 to get a pot reading.
// The conversation is 24 clock pulses on SCLK. CS is low the whole time.
//
// === What happens during those 24 clocks ===
//
// Clocks 1-7:   MOSI sends 0 (padding, chip ignores these)
// Clock 8:      MOSI sends 1 (start bit -- chip wakes up)
// Clock 9:      MOSI sends 1 (single-ended mode)
// Clock 10:     MOSI sends channel[2] (MSB of which pot)
// Clock 11:     MOSI sends channel[1]
// Clock 12:     MOSI sends channel[0] (LSB of which pot)
// Clock 13:     MCP3008 is sampling the pot -- ignore MISO
// Clock 14:     Null bit on MISO (always 0, ignore it)
// Clocks 15-24: MCP3008 sends 10 data bits on MISO (MSB first: B9 down to B0)
//
// === State machine ===
//
// IDLE:    cs = 1, waiting for start signal
// RUNNING: cs = 0, shifting bits out on MOSI and in from MISO, counting 24 clocks
// DONE:    data is ready, pulse done = 1, go back to IDLE
//
// === Implementation plan ===
//
// - Use a 5-bit counter (0-23) to track which clock cycle you're on
// - On each SCLK rising edge, send the right bit on MOSI based on the counter
// - On each SCLK rising edge (clocks 15-24), shift MISO bits into a 10-bit register
// - After clock 24, pull CS high, set done = 1, return to IDLE

module spi(
    input clk,
    input rst,
    input sclk,           // slow clock from clk_div
    input [2:0] channel,  // which pot (0-7)
    input start,          // pulse high to begin a conversion
    output reg [9:0] data, // 10-bit result
    output reg done,      // pulses high when data is ready
    output reg cs,        // to MCP3008
    output reg mosi,      // to MCP3008
    input miso            // from MCP3008
);

    reg [4:0] counter = 0;
    reg sclk_prev = 0;
    reg running = 0;

    always @(posedge clk) begin
        sclk_prev <= sclk;

        if (rst) begin
            cs <= 1;
            counter <= 0;
            done <= 0;
            running <= 0;
        end
        else if (start && !running) begin
            cs <= 0;
            counter <= 0;
            done <= 0;
            running <= 1;
        end
        else if (running && sclk && !sclk_prev) begin
            counter <= counter + 1;

            if (counter < 6) mosi <= 0;
            else if (counter == 6 || counter == 7) mosi <= 1;
            else if (counter == 8) mosi <= channel[2];
            else if (counter == 9) mosi <= channel[1];
            else if (counter == 10) mosi <= channel[0];
            else if (counter >= 14 && counter < 23) data <= {data[8:0], miso};
            else if (counter == 23) begin
                data <= {data[8:0], miso};
                counter <= 0;
                cs <= 1;
                done <= 1;
                running <= 0;
            end
        end
    end

endmodule
