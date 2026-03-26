module clk_div (
    input clk,
    input rst,
    output reg sclk
);

    reg [5:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            sclk <= 0;
            counter <= 0;
        end
        else if (counter == 49) begin
            sclk <= ~sclk;
            counter <= 0;
        end
        else counter <= counter + 1;
    end

endmodule