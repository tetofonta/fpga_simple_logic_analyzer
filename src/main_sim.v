module main(
	input i_clk,
	input [7:0] data,
	input i_btn,
	input i_read,
	input _mrst,
	output o_available,
	output o_run,
	output [31:0] o_data
);

wire [2:0] trig_start = 0;
wire [2:0] trig_end = 1;
//wire [31:0] time_prescaler = 50000000;
wire [31:0] time_prescaler = 1; //
wire trig_edge = 0;
wire fifo_clr = 0;
wire btn;
wire o_trig;
wire save;
wire fifo_read;
wire fifo_read_in;
wire fifo_full = 0; //
wire fifo_empty = 0;//
wire limit_reached;
wire o_time;
wire do_limit = 1;
//wire [31:0] step_limit = 20;
wire [31:0] step_limit = 7;

//debouncer toggle(
//	.i_clk(i_clk),
//	.button(i_read),
//	.signal(fifo_read_in)
//);
assign fifo_read_in = i_btn; //

rising_edge_detector fifo_read_re(
	.i_signal(fifo_read_in),
	.i_clk(i_clk),
	.o_trig(fifo_read)
);

//debouncer read(
//	.i_clk(i_clk),
//	.button(i_btn),
//	.signal(btn)
//);

assign btn = i_btn; //

channel_trigger ch1 (
	.i_data(data),
	.i_trig_start_select(trig_start),
	.i_trig_end_select(trig_end),
	.i_trig_start_edge(trig_edge),
	.i_trig_end_edge(trig_edge),
	.i_clk(i_clk),
	.i_rst(fifo_full | limit_reached | ~_mrst),
	.i_man_toggle(btn),
	.o_trig(o_trig),
	.o_run(o_run)
);

time_stepper timer(
	.i_clk(i_clk),
	.prescaler(time_prescaler),
	.i_run(o_trig & _mrst),
	.o_time(o_time)
);

pin_change_detector pcint(
	.i_data(data),
	.i_clk(i_clk),
	.inhibit(~o_trig | ~_mrst),
	.o_changed(save)
);

//wire fifo_full;
//wire fifo_empty;

//channel_fifo(
//	.aclr(fifo_clr),
//	.clock(i_clk),
//	.data({o_time, data}),
//	.rdreq(fifo_read & ~fifo_empty),
//	.wrreq(save & ~fifo_full),
//	.empty(fifo_empty),
//	.full(fifo_full),
//	.q(o_data)
//);

step_limiter limit (
	.do_step_limit(do_limit),
	.step_limit(step_limit),
	.i_run(o_trig & _mrst),
	.i_step(save),
	.stop(limit_reached)
);

assign o_available = ~fifo_empty;

assign o_data = {o_time, data}; //


endmodule