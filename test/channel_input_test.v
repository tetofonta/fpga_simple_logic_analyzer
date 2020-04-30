`timescale 1ns/100ps
module channel_input_test;

reg i_clk = 0;
reg [2:0] start_trigger_index = 1;
reg start_trigger_edge = 0;
reg _start_trigger_enable = 0;
reg [2:0] end_trigger_index = 7;
reg end_trigger_edge = 1;
reg _end_trigger_enable = 0;
reg manual_toggle = 0;
reg [31:0] sample_limit = 5;
reg do_sample_limit = 1;
reg [31:0] time_prescaler = 1;
reg _mrst = 1;
reg [7:0] i_data = 0;
wire save;
wire [31:0] data;
wire run;

channel_input test (i_clk, start_trigger_index, start_trigger_edge, _start_trigger_enable, end_trigger_index, end_trigger_edge, _end_trigger_enable, manual_toggle, sample_limit, do_sample_limit, time_prescaler, _mrst, i_data, save, data, run);

initial begin
    $dumpfile("channel_input_test.v");
    $dumpvars(0, channel_input_test);

    #4  _mrst <= 0; //release mrst
    #4 _mrst <= 1; //release mrst
    #5 i_data <= 1;
    #5 i_data <= 3;
    #5 i_data <= 10;
    #5 i_data <= 127;
    #5 i_data <= 6;
    #5 i_data <= 18;
    #5 i_data <= 5;
    #5 i_data <= 1;
    #5 i_data <= 3;
    #5 i_data <= 128;
    #5 i_data <= 129;
    #5 i_data <= 127;
    #5 i_data <= 4;
    #5 i_data <= 5;
    #5 i_data <= 1;
    #20 i_data <= 3;
    #5 i_data <= 10;
    #5 i_data <= 127;
    #5 i_data <= 6;
    #5 i_data <= 18;
    #5 i_data <= 5;
    #5 i_data <= 1;
    #5 i_data <= 3;
    #5 i_data <= 128;
    #5 i_data <= 129;
    #5 i_data <= 127;
    #5 i_data <= 4;
    #5 i_data <= 5;
    #10     $finish;
end

always begin
    #0.5 i_clk <= 1;
    #1 i_clk <= 0;
    #0.5 i_clk <= 0;
end

endmodule