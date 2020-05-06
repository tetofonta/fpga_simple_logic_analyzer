module uart_rx
#(
    parameter BAUD_PRESCALER = 200 //250000 baud @50MHz
)(
    input rx_pin,
    input _rst,
    input i_clk,
    output reg [7:0] data,
    output reg avail
);

initial avail <= 0;

reg start_recv = 0;
reg recv_end = 0;
wire recv_end_redge;
wire start_reception;
wire reading;
rising_edge_detector recv_end_re(.i_clk(i_clk), .i_signal(recv_end), .o_trig(recv_end_redge));
pin_change_detector #(.WIDTH(1)) start_change(.i_clk(i_clk), .i_data(start_recv), .o_changed(start_reception), ._inhibit(_rst));
rs_flipflop receiving (.i_set(start_reception & ~recv_end_redge), .i_rst(recv_end_redge | ~_rst), .q(reading));

wire bit_clk;
prescaler #(.PRESCALER(BAUD_PRESCALER), .START_VALUE(BAUD_PRESCALER/2)) baud_gen (.i_clk(i_clk), .o_clk(bit_clk), .run(reading));

always @(negedge rx_pin)
begin
    start_recv <= ~start_recv;
end

localparam START_BIT = 0;
localparam DATA_BIT = 1;
reg [4:0] bit_count = 0;
localparam STOP_BIT = 2;
reg [3:0] status = START_BIT;

always @(posedge bit_clk)
begin
    case (status)
        START_BIT:
            if(rx_pin == 0) begin
                status <= DATA_BIT;
                recv_end <= 0;
                bit_count <= 0;
                avail <= 0;
            end else
            begin
                recv_end = 0;
                recv_end = 1;
            end
        DATA_BIT:
            begin
                data[bit_count] = rx_pin;
                bit_count <= bit_count + 1;
                if(bit_count == 8) begin
                    status <= STOP_BIT;
                end
            end
        STOP_BIT:
            begin
                if(rx_pin == 1)
                    avail <= 1;
                recv_end <= 1;
                status <= START_BIT;
            end
    endcase
end

endmodule