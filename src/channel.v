module channel(
    input i_clk,
	input [7:0] data,
	input i_btn,
	input _mrst,

	input [2:0] start_trigger_index,
	input [2:0] stop_trigger_index,
	input _start_trigger_enable,
	input _stop_trigger_enable,
	input start_edge,
	input stop_edge,

	input trig_once,
    input ext_trigger,

    input [31:0] sample_limit,
    input sample_limit_enable,

    input [31:0] time_prescaler,

    input read,
    output [31:0] o_data,
    output available,
    output o_run
);

wire rst_line;
reset_manager ch_rst(.i_clk(i_clk), ._rst(_mrst), ._o_rst(rst_line));

wire fifo_clear = 0;
wire fifo_read;
wire read_sig;
wire fifo_empty;
wire fifo_full;
wire save;
wire [31:0] save_data;

wire start_ext;
wire stop_ext;

rising_edge_detector ext_start(.i_clk(i_clk), .i_signal(ext_trigger), .o_trig(start_ext));
rising_edge_detector ext_start(.i_clk(i_clk), .i_signal(~ext_trigger), .o_trig(stop_edge));

channel_input port (
    .i_clk(i_clk),
    .start_trigger_index(start_trigger_index),
    .start_trigger_edge(start_edge),
    ._start_trigger_enable(_start_trigger_enable),
    .end_trigger_index(stop_trigger_index),
    .end_trigger_edge(stop_edge),
    ._end_trigger_enable(_stop_trigger_enable),
	.once(trig_once),
	.ext_trig_start(start_ext),
    .ext_trig_end(stop_ext),
    .manual_toggle(i_btn),
    .sample_limit(sample_limit),
    .do_sample_limit(sample_limit_enable),
    .time_prescaler(time_prescaler), //25M
    ._mrst(rst_line),
    .fifo_full(fifo_full),
    .i_data(data),
    .save(save),
    .data(save_data),
    .run(o_run)
);


rising_edge_detector read_edge(
	.i_signal(read),
	.i_clk(i_clk),
	.o_trig(fifo_read)
);

channel_fifo(
	.aclr(~rst_line),
	.clock(i_clk),
	.data(save_data),
	.rdreq(fifo_read & ~fifo_empty),
	.wrreq(save & ~fifo_full),
	.empty(fifo_empty),
	.full(fifo_full),
	.q(o_data)
);

assign available = ~fifo_empty;

endmodule