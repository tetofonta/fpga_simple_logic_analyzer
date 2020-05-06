module main
#(
    parameter CH_NO = 4,
    parameter BAUD_PRESC = 434
)(
    input [(CH_NO*8)-1:0] port_data,
    input [CH_NO - 1:0] ext_trigs,
    input [CH_NO - 1:0] _rsts,
    input [CH_NO - 1:0] togs,
    output [CH_NO - 1:0] runs,
    input i_clk,

	input rx,
    output tx,
    input _mrst
);

wire [CH_NO - 1:0] reads;
wire [CH_NO - 1:0] availables;
wire [(CH_NO * 32) - 1:0] data;

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
uart_rx #(.BAUD_PRESCALER(BAUD_PRESC)) recv_uart (.rx_pin(rx), ._rst(wire_rst), .i_clk(i_clk), .data(recv_data), .avail(recv));
//todo input fifo
shift_register data_in(.parallel_load(recv_data), .i_clk(recv_re | sh_clk), .ser_in(1'b0), .ser_out(c), .fetch(recv_re));
wire shift_en_clk;
rs_flipflop shift_en(.i_set(recv_re), .i_rst(~wire_rst | shift_clk_stp), .q(shift_en_clk));
wire [(CH_NO * 80) - 1:0] ch_conf;
shift_register #(.BITS(CH_NO * 80)) ch_conf_reg(.i_clk(sh_clk), .ser_in(c), .fetch(1'b0));

always @(posedge i_clk)
begin
    if(shift_en_clk)
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
    else
        sh_clk_stop <= 0;
end

genvar i;
generate
    for (i = 0; i < CH_NO; i = i + 1) begin : channel
         channel ch(
            i_clk,
            port_data[(i+1)*8 - 1 : i*8],
            togs[i],
            _rsts[i],
            ch_conf[i*80+2:i+80],
            ch_conf[i*80+10:i+80+8],
            ch_conf[i*80+3],
            ch_conf[i*80+11],
            ch_conf[i*80+4],
            ch_conf[i*80+12],
            ch_conf[i*80+15],
            ext_trigs[i],
            ch_conf[i*80+79:i+80+48],
            ch_conf[i*80+7],
            ch_conf[i*80+47:i+80+16], 
            reads[i],
            data[(i+1)*32 - 1:0],
            availables[i],
            runs[i]
         );
    end
endgenerate

//channel port_a(i_clk, port_data[7:0], togs[0], _rsts[0], 3'b001, 3'b000, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, ext_trigs[0], 32'h40, 1'b1, 32'h32, reads[0], data[31:0], availables[0], runs[0]);
//channel port_b(i_clk, port_data[15:8], togs[1], _rsts[1], 3'b001, 3'b000, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, ext_trigs[1], 32'h20, 1'b1, 32'hC350, reads[1], data[63:32], availables[1], runs[1]);
//channel port_c(i_clk, port_data[23:16], togs[2], _rsts[2], 3'b001, 3'b000, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, ext_trigs[2], 32'h20, 1'b1, 32'hC350, reads[2], data[95:64], availables[2], runs[2]);
//channel port_d(i_clk, port_data[31:24], togs[3], _rsts[3], 3'b001, 3'b000, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, ext_trigs[3], 32'h20, 1'b1, 32'hC350, reads[3], data[127:96], availables[3], runs[3]);

transfer #(.CH_NO(CH_NO), .BAUD_PRESCALER(BAUD_PRESC)) mux(data, availables, reads, i_clk, wire_rst, tx);

endmodule