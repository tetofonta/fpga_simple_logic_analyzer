module channel_trigger
#(
    parameter WIDTH = 8
)(
    input [WIDTH - 1:0] i_data,
    input [$clog2(WIDTH) - 1 : 0] i_trig_start_select,
    input i_trig_start_edge,
    input [$clog2(WIDTH) - 1 : 0] i_trig_end_select,
    input i_trig_end_edge,
    input ext_trig_start,
    input ext_trig_end,
    input i_clk,
    input i_rst_0,
    input _i_rst_1,
    input i_man_toggle,
    input _enable_start,
    input _enable_end,
	 input once,
    output o_trig,
    output o_run
);

wire trig_start_condition;
wire trig_end_condition;
wire asserted;
assign trig_start_condition = (i_data[i_trig_start_select] ^ i_trig_start_edge) & ~_enable_start & ~asserted;
assign trig_end_condition = (i_data[i_trig_end_select] ^ i_trig_end_edge) & ~_enable_end;

rs_flipflop once_filter (trig_start_condition & once & _i_rst_1, ~_i_rst_1, asserted);

wire start_trig;
wire end_trig;
wire man_ctrl;
wire rst_0_trig;
wire rst_1_trig;
wire rst_trig;
wire ext_start_trig;
wire ext_end_trig;

rising_edge_detector ext_set_re (ext_trig_start & _enable_start, i_clk, ext_start_trig);
rising_edge_detector ext_rst_re (ext_trig_end & _enable_end, i_clk, ext_end_trig);

rising_edge_detector set_re (trig_start_condition, i_clk, start_trig);
rising_edge_detector rst_re (trig_end_condition, i_clk, end_trig);
rising_edge_detector tog_set_re (i_man_toggle, i_clk, man_ctrl);

rising_edge_detector rst_0_re (i_rst_0, i_clk, rst_0_trig);
rising_edge_detector rst_1_re (~_i_rst_1, i_clk, rst_1_trig);
assign rst_trig = (rst_0_trig & _i_rst_1) | rst_1_trig;

reg r_trig = 0;

wire trig_set;
wire trig_reset;
assign trig_set = (start_trig | ext_start_trig | (man_ctrl & ~r_trig & _i_rst_1)) & ~r_trig;
assign trig_reset = (end_trig | ext_end_trig | (man_ctrl & r_trig & _i_rst_1)) & r_trig | rst_trig;

rs_flipflop trig_status (trig_set, trig_reset, o_trig);
wire update_condition;
always @(posedge (i_clk & ~man_ctrl & ~trig_set & ~trig_reset))
    r_trig <= o_trig;

assign o_run = o_trig & _i_rst_1;

endmodule