module rising_edge_detector(
    input i_signal,
    input i_clk,
    output o_trig
);

reg previous_pos;
reg previous_neg;

always @(posedge i_clk)
    previous_pos <= i_signal;

always @(negedge i_clk)
    previous_neg <= i_signal;

assign o_trig = (i_signal & ~previous_pos) | (i_signal & ~previous_neg);

endmodule