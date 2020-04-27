module pin_change_detector_test;

reg [7:0] sig = 0;
reg clk = 0;
reg inh = 1;
wire out;

pin_change_detector #(.WIDTH(8)) ret (sig, clk, inh, out);

initial begin
    $dumpfile("pin_change_detector_test.v");
    $dumpvars(0, pin_change_detector_test);

    sig <= 5;
    #10     sig <= 3;
    #11     inh <= 0;
    #20     sig <= 18;
    #25     $finish;
end

always begin
    #5 clk <= 1;
    #10 clk <= 0;
    #5 clk <= 0;
end

endmodule