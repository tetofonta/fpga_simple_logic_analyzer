module time_stepper
#(
    parameter TIME_LENGTH = 24
)(
    input i_clk,
    input [31:0] prescaler,
    input i_run,
    output reg [TIME_LENGTH - 1 : 0] o_time
);

reg [31:0] counter = 0;

always @(posedge i_clk)
begin
    if(i_run) begin
        counter <= counter + 1;
        if(counter >= prescaler) begin
            o_time <= o_time + 1;
            counter <= 0;
        end
    end
    else begin
        o_time <= 0;
        counter <= 0;
    end
end

endmodule