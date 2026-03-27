module top(
    input clk,
    input rst,
    input [7:0] sw,
    output servo,
    output cs,
    output mosi,
    output sclk_out,
    input miso
);

    wire sclk;
    assign sclk_out = sclk;
    wire [9:0] data;
    wire spi_done;
    reg spi_done_prev;
    reg spi_start = 0;
    reg [7:0] gap_counter = 200;

    // delay between SPI conversions so CS stays high
    always @(posedge clk) begin
        spi_done_prev <= spi_done;

        if (rst) begin
            spi_start <= 0;
            gap_counter <= 200;
        end
        else if (spi_done && !spi_done_prev) begin
            gap_counter <= 1;
            spi_start <= 0;
        end
        else if (gap_counter > 0 && gap_counter < 200) begin
            gap_counter <= gap_counter + 1;
            spi_start <= 0;
        end
        else if (gap_counter == 200) begin
            spi_start <= 1;
            gap_counter <= 0;
        end
        else begin
            spi_start <= 0;
        end
    end

    pwm pwm1 (
        .clk(clk),
        .rst(rst),
        .position(data[9:2]),
        .pwm_out(servo)
        );

    clk_div clk_div1 (
        .clk(clk),
        .rst(rst),
        .sclk(sclk)
    );

    spi spi1 (
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .channel(3'b000),
        .start(spi_start),
        .data(data),
        .done(spi_done),
        .cs(cs),
        .mosi(mosi),
        .miso(miso)
    );

endmodule
