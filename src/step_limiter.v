module step_limiter(
    input do_step_limit,
    input [31:0] step_limit,
    input i_run,
    input i_step,
    input i_reset,
    input i_clk,
    output reg stop
);

reg [31:0] count = 0;

reg last_run_p = 0;
always @(posedge i_clk)
    last_run_p <= i_run;

reg last_run_n = 0;
always @(negedge i_clk)
    last_run_n <= i_run;

wire condition;
assign condition = (i_step & do_step_limit) | (~last_run_n & ~last_run_p) | i_reset;

always @(posedge condition)
begin
    if(i_run & ~i_reset) begin
        count <= count + 1;
        if(count >= step_limit) begin
            stop <= 1;
            count <= 0;
        end
    end
    else begin
        count <= 0;
        stop <= 0;
    end
end

endmodule