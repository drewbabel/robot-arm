module clk_div (
    input clk,
    input rst,
    output reg sclk
);

    reg [12:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            sclk <= 0;
            counter <= 0;
        end
        else if (counter == 4999) begin
            sclk <= ~sclk;
            counter <= 0;
        end
        else counter <= counter + 1;
    end

endmodule