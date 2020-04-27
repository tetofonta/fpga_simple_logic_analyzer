module debouncer
#(
    parameter CLK_WAIT = 25000000
)(
    input i_clk,
    input button,
    output reg signal
);

reg idle = 1;
reg [$clog2(CLK_WAIT) - 1 : 0] count = 0;
initial signal = 0;

always @(posedge i_clk)
begin
    if(idle && button != signal) begin
        idle <= 0;
        count <= 0;
        signal <= button;
    end
    else if (!idle) begin
        count <= count + 1;
        if(count >= CLK_WAIT) begin
            idle <= 1;
        end
    end
end

endmodule