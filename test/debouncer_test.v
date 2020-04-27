module debouncer_test;

reg clk = 0;
reg signal = 0;
wire out;

debouncer #(.CLK_WAIT(5)) test (clk, signal, out);

initial begin
    $dumpfile("debouncer_test.v");
    $dumpvars(0, debouncer_test);

    #2 signal <= 1;
    #3 signal <= 0;
    #5 signal <= 1;
    #10 signal <= 0;
    #11 signal <= 1;

    #50 signal <= 0;
    #5 signal <= 1;
    #10 signal <= 0;
    #10 $finish;
end

always begin
    #1 clk <= 1;
    #2 clk <= 0;
    #1 clk <= 0;
end

endmodule