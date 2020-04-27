module test;

reg clk = 0;
reg [7:0] data = 0;
reg i_btn = 0;
reg i_read = 0;
reg _rst = 0;
wire o_available;
wire o_run;
wire [31:0] o_data;

main main_test (clk, data, i_btn, i_read, _rst, o_available, o_run, o_data);

initial begin
    $dumpfile("test.v");
    $dumpvars(0, test);

    #5   _rst <= 1;
    #10  data <= 5; //triggers
    #10  data <= 4;
    #10  data <= 5;
    #10  data <= 4;
    #10  data <= 5;
    #10  data <= 9;
    #10  data <= 5;
    #10  data <= 4;
    #10  data <= 1;

    #10  data <= 5; //triggers
    #10  data <= 4;
    #10  data <= 5;
    #10  data <= 6;

    #10 $finish;
end

always begin
    #1 clk <= 1;
    #2 clk <= 0;
    #1 clk <= 0;
end

endmodule