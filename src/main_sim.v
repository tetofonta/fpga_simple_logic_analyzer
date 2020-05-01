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

wire rst_line;
reg internal_rst = 1;
reg rst_ownership = 0;
assign rst_line = (_mrst & rst_ownership) | (internal_rst & ~rst_ownership);

parameter clocks_before = 5;
parameter clocks_after = 5;
reg [$clog2(clocks_before + clocks_after + 1) : 0] counter = 0;

always @(posedge i_clk & ~rst_ownership)
begin
    counter <= counter + 1;
    if(counter > clocks_before)
        internal_rst <= 0;
    if(counter > clocks_before + clocks_after)
        rst_ownership <= 1;
end

wire fifo_clear;
wire fifo_read;
wire fifo_empty;
wire fifo_full;
wire save;
wire [31:0] save_data;

channel_input port_a (
    .i_clk(i_clk),
    .start_trigger_index(3'b000),
    .start_trigger_edge(1'b0),
    ._start_trigger_enable(1'b0),
    .end_trigger_index(3'b001),
    .end_trigger_edge(1'b1),
    ._end_trigger_enable(1'b0),
    .manual_toggle(i_btn),
    .sample_limit(32'h07),
    .do_sample_limit(1'b1),
    .time_prescaler(32'h01), //25M
    ._mrst(rst_line),
    .fifo_full(fifo_full),
    .i_data(data),
    .save(save),
    .data(save_data),
    .run(o_run)
);

//channel_fifo(
//	.aclr(fifo_clr),
//	.clock(i_clk),
//	.data(save_data),
//	.rdreq(fifo_read & ~fifo_empty),
//	.wrreq(save & ~fifo_full),
//	.empty(fifo_empty),
//	.full(fifo_full),
//	.q(o_data)
//);

//assign o_available = ~fifo_empty;

endmodule