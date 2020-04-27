module timer_stepper_test;

reg clk = 0;
reg [31:0] prescaler = 5;
reg run = 0;
wire [23:0] data;

time_stepper #(.TIME_LENGTH(24)) test (clk, prescaler, run, data);

initial begin
    $dumpfile("timer_stepper_test.v");
    $dumpvars(0, timer_stepper_test);

    #10 run <= 1;
    #100 run <= 0;
    #10     $finish;
end

always begin
    #1 clk <= 1;
    #2 clk <= 0;
    #1 clk <= 0;
end

endmodule