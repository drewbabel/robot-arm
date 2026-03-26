module top(
    input clk,
    input rst,
    input [7:0] sw,
    output servo
);

    pwm inst1 (
        .clk(clk),
        .rst(rst),
        .position(sw),
        .pwm_out(servo)
        );

endmodule