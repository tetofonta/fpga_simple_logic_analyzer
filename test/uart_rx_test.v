`timescale 1ns/100ps
module uart_rx_test;

reg clk = 0;
reg rx = 1;
reg rst = 1;
uart_rx #(.BAUD_PRESCALER(5)) test(.i_clk(clk), .rx_pin(rx), ._rst(rst));

initial begin
    $dumpfile("uart_rx_test.v");
    $dumpvars(0, uart_rx_test);

    #8 rst <= 0;
    #8 rst <= 1;
    #10 rx <= 0;
    #10 rx <= 1;//error

    #80 rx <= 0; //start
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 1;
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 0;
    #24 rx <= 1; //stop

    #80 rx <= 0; //start
    #24 rx <= 0;
    #24 rx <= 1;
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 1;
    #24 rx <= 0;
    #24 rx <= 1; //stop

    #80 $finish;

end

always begin
    #1 clk <= 1;
    #2 clk <= 0;
    #1 clk <= 0;
end

endmodule