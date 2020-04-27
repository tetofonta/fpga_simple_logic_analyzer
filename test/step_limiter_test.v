module step_limiter_test;

reg clk = 0;
reg [31:0] limit = 5;
reg run = 0;
reg do_limit = 1;
wire stop;

step_limiter test (do_limit, limit, run, clk, stop);

initial begin
    $dumpfile("step_limiter_test.v");
    $dumpvars(0, step_limiter_test);

    #100 run <= 1;
    #50 $finish;
end

always @(posedge stop)
    #1 run <= 0;

always begin
    #1 clk <= 1;
    #2 clk <= 0;
    #1 clk <= 0;
end

endmodule