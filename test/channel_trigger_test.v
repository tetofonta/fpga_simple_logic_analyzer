module channel_trigger_test;

reg [7:0] data = 0;
reg [2:0] trig_index_start = 1;
reg [2:0] trig_index_end = 1;
reg trig_edge_start = 0;
reg trig_edge_end = 1;
reg clk = 0;
reg internal_reset = 0;
reg manual_toggle = 0;
wire o_trig;
wire o_run;

channel_trigger #(.WIDTH(8)) test (data, trig_index_start, trig_edge_start, trig_index_end, trig_edge_end, clk, internal_reset, manual_toggle, o_trig, o_run);

initial begin
    $dumpfile("channel_trigger_test.v");
    $dumpvars(0, channel_trigger_test);

    internal_reset <= 1;
    #2  internal_reset <= 0;
    #10 data <= 15;
    #5  data <= 17;
    #5  data <= 13;
    #5  data <= 22;
    #5  internal_reset <= 1;
    #5  internal_reset <= 0;
    #5  data <= 20;
    #5  data <= 22;
    #5  manual_toggle <= 1;
    #5  manual_toggle <= 0;
    #5  manual_toggle <= 1;
    #10     $finish;
end

always begin
    #1 clk <= 1;
    #2 clk <= 0;
    #1 clk <= 0;
end

endmodule