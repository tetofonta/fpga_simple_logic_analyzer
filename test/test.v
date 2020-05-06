`timescale 1ns/100ps
module test;

reg i_clk = 0;
reg _mrst = 1;
reg rx = 1;

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
uart_rx #(.BAUD_PRESCALER(5)) recv_uart (.rx_pin(rx), ._rst(wire_rst), .i_clk(i_clk), .data(recv_data), .avail(recv));
//todo input fifo
shift_register data_in(.parallel_load(recv_data), .i_clk(recv_re | sh_clk), .ser_in(1'b0), .ser_out(c), .fetch(recv_re));
wire shift_en_clk;
rs_flipflop shift_en(.i_set(recv_re), .i_rst(~wire_rst | shift_clk_stp), .q(shift_en_clk));
wire [(1 * 80) - 1:0] ch_conf;
shift_register #(.BITS(1 * 80)) ch_conf_reg(.i_clk(sh_clk), .ser_in(c), .fetch(1'b0));

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

initial begin
    $dumpfile("test.v");
    $dumpvars(0, test);

    #80 rx <= 0; //start
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 1;
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 0;
    #24 rx <= 1; //stop

    #100 rx <= 0; //start
    #24 rx <= 0;
    #24 rx <= 1;
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 1; //stop

    #80 $finish;
end

always begin
    #1 i_clk <= 1;
    #2 i_clk <= 0;
    #1 i_clk <= 0;
end

endmodule