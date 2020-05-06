module shift_register
#(
    parameter BITS = 8
)(
    input [BITS - 1 : 0] parallel_load,
    input i_clk,
    input fetch,
    input ser_in,
    output ser_out,
	 output [BITS-1:0] par_out
);

reg [BITS - 1 : 0] bits;

always @(posedge i_clk)
begin
    if(fetch)
        bits <= parallel_load;
    else
        bits <= {ser_in, bits[BITS-1:1]};
end

assign ser_out = bits[0];
assign par_out = bits;

endmodule
