module step_limiter(
    input do_step_limit,
    input [31:0] step_limit,
    input i_run,
    input i_step,
    output reg stop
);

reg [31:0] count = 0;

wire condition;
assign condition = i_step & do_step_limit | ~i_run;

always @(posedge condition)
begin
    if(i_run) begin
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