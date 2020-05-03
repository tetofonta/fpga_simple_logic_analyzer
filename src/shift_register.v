module shift_register
#(
    parameter BITS = 8
)(
    input [BITS - 1 : 0] parallel_load,
    input i_clk,
    input fetch,
    input ser_in,
    output ser_out
);

reg [BITS - 1 : 0] bits;

always @(posedge i_clk)
begin
    if(fetch)
        bits <= parallel_load;
    else
        bits <= {bits[BITS-2:0], ser_in};
end

assign ser_out = bits[BITS-1];

endmodule