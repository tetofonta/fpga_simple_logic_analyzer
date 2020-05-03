module prescaler
#(
    parameter PRESCALER = 1000
)(
    input i_clk,
    input run,
    output reg o_clk
);

initial o_clk = 0;

reg [$clog2(PRESCALER) - 1:0] count = 0;

always @(posedge i_clk)
begin
    if(run)
        if(count == PRESCALER) begin
            o_clk <= 1;
            count <= 0;
        end
        else begin
            count <= count + 1;
            o_clk <= 0;
        end
    else begin
        count <= 0;
        o_clk <= 0;
    end
end

endmodule