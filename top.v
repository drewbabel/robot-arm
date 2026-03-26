module top(
    input clk,
    input rst,
    input [7:0] sw,
    output [0:0] servo
);

    pwm inst1 (
        .clk(clk),
        .rst(rst),
        .position(sw),
        .pwm_out(servo[0])
        );

endmodule