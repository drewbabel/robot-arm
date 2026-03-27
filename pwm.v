module pwm(
    input clk,
    input rst,
    input [7:0] position,
    output pwm_out
);

    reg [20:0] counter;

    always @(posedge clk) begin
        if (rst | counter == 1999999) counter <= 0;
        else counter <= counter + 1;
    end

    assign pwm_out = (counter < 100000 + (position * 400)) ? 1 : 0;

endmodule
