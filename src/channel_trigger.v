module channel_trigger
#(
    parameter WIDTH = 8
)(
    input [WIDTH - 1:0] i_data,
    input [$clog2(WIDTH) - 1 : 0] i_trig_start_select,
    input i_trig_start_edge,
    input [$clog2(WIDTH) - 1 : 0] i_trig_end_select,
    input i_trig_end_edge,
    input i_clk,
    input i_rst,
    input i_man_toggle,
    output o_trig,
    output o_run
);

wire trig_start_condition;
wire trig_end_condition;
assign trig_start_condition = i_data[i_trig_start_select] ^ i_trig_start_edge;
assign trig_end_condition = i_data[i_trig_end_select] ^ i_trig_end_edge;

wire start_trig;
wire end_trig;
wire rst_trig;
wire man_ctrl;

rising_edge_detector set_re (trig_start_condition, i_clk, start_trig);
rising_edge_detector rst_re (trig_end_condition, i_clk, end_trig);
rising_edge_detector mrst_re (i_rst, i_clk, rst_trig);

rising_edge_detector tog_set_re (i_man_toggle, i_clk, man_ctrl);

reg r_trig = 0;

rs_flipflop trig_status ((start_trig | (man_ctrl & ~r_trig)) & ~i_rst, end_trig | rst_trig | (man_ctrl & r_trig), o_trig);

always @(posedge i_clk & ~man_ctrl)
    r_trig <= o_trig;

assign o_run = o_trig & ~i_rst;

endmodule