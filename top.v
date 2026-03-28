module top(
    input clk,
    input rst,
    input [7:0] sw,
    output servo1,
    output servo2,
    output servo3,
    output servo4,
    output servo5,
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
    reg [2:0] channel = 0;

    reg [9:0] pos0 = 0;
    reg [9:0] pos1 = 0;
    reg [9:0] pos2 = 0;
    reg [9:0] pos3 = 0;
    reg [9:0] pos4 = 0;

    always @(posedge clk) begin
        spi_done_prev <= spi_done;

        if (rst) begin
            spi_start <= 0;
            gap_counter <= 200;
            channel <= 0;
        end
        else if (spi_done && !spi_done_prev) begin
            case (channel)
                0: pos0 <= data;
                1: pos1 <= data;
                2: pos2 <= data;
                3: pos3 <= data;
                4: pos4 <= data;
            endcase
            channel <= (channel == 4) ? 0 : channel + 1;
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

    pwm pwm1 (.clk(clk), .rst(rst), .position(pos0[9:2]), .pwm_out(servo1));
    pwm pwm2 (.clk(clk), .rst(rst), .position(pos1[9:2]), .pwm_out(servo2));
    pwm pwm3 (.clk(clk), .rst(rst), .position(pos2[9:2]), .pwm_out(servo3));
    pwm pwm4 (.clk(clk), .rst(rst), .position(pos3[9:2]), .pwm_out(servo4));
    pwm pwm5 (.clk(clk), .rst(rst), .position(pos4[9:2]), .pwm_out(servo5));

    clk_div clk_div1 (
        .clk(clk),
        .rst(rst),
        .sclk(sclk)
    );

    spi spi1 (
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .channel(channel),
        .start(spi_start),
        .data(data),
        .done(spi_done),
        .cs(cs),
        .mosi(mosi),
        .miso(miso)
    );

endmodule
