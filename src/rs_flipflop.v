module rs_flipflop(
    input i_set,
    input i_rst,
    output q
);

wire _q;

assign q = ~(i_rst | _q);
assign _q = ~(i_set | q);

endmodule