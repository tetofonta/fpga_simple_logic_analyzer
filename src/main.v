module main(
    input [31:0] port_data,
    input [3:0] ext_trigs,
    input [3:0] _rsts,
    input [3:0] togs,
    output [3:0] runs,
    input i_clk,

	 input rx,
    output tx,
    input _mrst
);

wire [3:0] reads;
wire [3:0] availables;
wire [127:0] data;

wire wire_rst;
reset_manager tx_rst(.i_clk(i_clk), ._rst(_mrst), ._o_rst(wire_rst));

wire [7:0] recv_data;
wire recv;
wire recv_re;
wire c;
reg sh_clk = 0;
reg sh_clk_stop = 0;
reg [5:0] shifted = 0;
wire shift_clk_stp;
rising_edge_detector recv_red(.i_clk(i_clk), .i_signal(recv), .o_trig(recv_re));
rising_edge_detector shift_clock_stop(.i_clk(i_clk), .i_signal(sh_clk_stop), .o_trig(shift_clk_stp));
uart_rx recv_uart (.rx_pin(rx), ._rst(wire_rst), .i_clk(i_clk), .data(recv_data), .avail(recv));
//todo input fifo
shift_register data_in(.parallel_load(recv_data), .i_clk(recv_re | sh_clk), .ser_in(1'b0), .ser_out(c), .fetch(recv_re));
wire shift_en_clk;
rs_flipflop shift_en(.i_set(recv_re), .i_rst(~wire_rst | shift_clk_stp), .q(shift_en_clk));

always @(posedge (i_clk & shift_en_clk))
begin
	if(shifted >= 16) begin
		shifted <= 0;
		sh_clk <= 0;
		sh_clk_stop <= 1;
	end else
	begin
		sh_clk_stop <= 0;
		sh_clk <= ~sh_clk;
		shifted <= shifted + 1;
	end
end

wire [79:0] ch_conf;
shift_register #(.BITS(80)) ch_conf(.i_clk(sh_clk), .ser_in(c), .fetch(1'b0));
channel port_a(i_clk, port_data[7:0], togs[0], _rsts[0], , 3'b000, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, ext_trigs[0], 32'h40, 1'b1, 32'h32, reads[0], data[31:0], availables[0], runs[0]);

channel port_b(i_clk, port_data[15:8], togs[1], _rsts[1], 3'b001, 3'b000, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, ext_trigs[1], 32'h20, 1'b1, 32'hC350, reads[1], data[63:32], availables[1], runs[1]);
channel port_c(i_clk, port_data[23:16], togs[2], _rsts[2], 3'b001, 3'b000, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, ext_trigs[2], 32'h20, 1'b1, 32'hC350, reads[2], data[95:64], availables[2], runs[2]);
channel port_d(i_clk, port_data[31:24], togs[3], _rsts[3], 3'b001, 3'b000, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, ext_trigs[3], 32'h20, 1'b1, 32'hC350, reads[3], data[127:96], availables[3], runs[3]);

transfer #(.CH_NO(4), .BAUD_PRESCALER(434)) mux(data, availables, reads, i_clk, wire_rst, tx);

endmodule