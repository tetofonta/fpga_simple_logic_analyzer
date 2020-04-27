module rising_edge_detector_test;

reg sig = 0;
reg clk = 0;
wire out;

rising_edge_detector ret (sig, clk, out);

initial begin
    $dumpfile("rising_edge_detector_test.v");
    $dumpvars(0, rising_edge_detector_test);

    # 10    sig <= 1;
    # 30    sig <= 0;
    # 30    sig <= 1;
    # 30    sig <= 0;
    # 10    $finish;
end

always begin
    #5 clk <= 1;
    #10 clk <= 0;
    #5 clk <= 0;
end

endmodule