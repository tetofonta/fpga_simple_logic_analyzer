`timescale 1ns/100ps
module xfer_test;

reg [127:0] in = 128'hAAAAAAAABBBBBBBBCCCCCCCCDDDDDDDD;
reg [3:0] available = 0;
reg clk = 0;
wire [31:0] out;
wire [3:0] read;

transfer #(.BAUD_PRESCALER(5)) test (.data_in(in), .available(available), .read(read), .i_clk(clk));

initial begin
    $dumpfile("xfer_test.v");
    $dumpvars(0, xfer_test);

    #60 available[2] = 1;

    #5000 $finish;
end

always begin
    #1 clk <= 1;
    #2 clk <= 0;
    #1 clk <= 0;
end

endmodule