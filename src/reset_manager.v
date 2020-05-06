module reset_manager
#(
    parameter CLOCKS_BEFORE = 5,
    parameter CLOCKS_AFTER = 5
)(
    input i_clk,
    input _rst,
    output _o_rst,
    output o_rst
);

assign o_rst = ~_o_rst;

reg internal_rst = 1;
reg rst_ownership = 0;
assign _o_rst = (_rst & rst_ownership) | (internal_rst & ~rst_ownership);

reg [$clog2(CLOCKS_BEFORE + CLOCKS_AFTER + 1) : 0] counter = 0;

always @(posedge (i_clk & ~rst_ownership))
begin
    if(counter > CLOCKS_BEFORE)
        internal_rst <= 0;
    if(counter > CLOCKS_AFTER + CLOCKS_AFTER)
        rst_ownership <= 1;
    counter <= counter + 1'b1;
end

endmodule