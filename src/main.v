module main(
    input [31:0] port_data,
    input [3:0] ext_trigs,
    input [3:0] _rsts,
    input [3:0] togs,
    output [3:0] runs,
    input i_clk,

    output tx,
    input _mrst
);

wire [3:0] reads;
wire [3:0] availables;
wire [127:0] data;

wire wire_rst;
reset_manager tx_rst(.i_clk(i_clk), ._rst(_mrst), .o_rst(wire_rst));

channel port_a(i_clk, port_data[7:0], togs[0], _rsts[0], 3'b001, 3'b000, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, ext_trigs[0], 32'h40, 1'b1, 32'h32, reads[0], data[31:0], availables[0], runs[0]);
channel port_b(i_clk, port_data[15:8], togs[1], _rsts[1], 3'b001, 3'b000, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, ext_trigs[1], 32'h20, 1'b1, 32'hC350, reads[1], data[63:32], availables[1], runs[1]);
channel port_c(i_clk, port_data[23:16], togs[2], _rsts[2], 3'b001, 3'b000, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, ext_trigs[2], 32'h20, 1'b1, 32'hC350, reads[2], data[95:64], availables[2], runs[2]);
channel port_d(i_clk, port_data[31:24], togs[3], _rsts[3], 3'b001, 3'b000, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, ext_trigs[3], 32'h20, 1'b1, 32'hC350, reads[3], data[127:96], availables[3], runs[3]);

transfer #(.CH_NO(4), .BAUD_PRESCALER(434)) mux(data, availables, reads, i_clk, tx);

endmodule