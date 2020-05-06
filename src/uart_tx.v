module uart_tx
#(
    parameter BAUD_PRESCALER = 200 //250000 baud @50MHz
)(
    input [31:0] data,
    input fetch,
    input transmit,
    input i_clk,
    input _rst,
    output busy,
    output reg tx_pin
);

initial tx_pin = 1;

wire bit_out;
wire shift;
reg shift_on_clk = 0;
assign shift = bit_clk & shift_on_clk;
shift_register #(.BITS(32)) register (.parallel_load(data), .fetch(fetch), .i_clk(shift | fetch), .ser_out(bit_out), .ser_in(1'b0));

wire send_status;
assign busy = send_status;

reg stop_transmit = 0;
wire stop_re;
rising_edge_detector stop_transmit_re(.i_clk(i_clk), .i_signal(stop_transmit), .o_trig(stop_re));
rs_flipflop tx_status (.i_set(transmit), .i_rst(stop_re | ~_rst), .q(send_status));

wire bit_clk;
prescaler #(.PRESCALER(BAUD_PRESCALER)) baud_gen (.i_clk(i_clk), .o_clk(bit_clk), .run(send_status));

localparam TX_START_BIT = 0;
localparam TX_SEND_BIT = 1;
localparam TX_STOP_BIT = 2;
localparam TX_CLEAR = 3;

reg [1:0] status = TX_START_BIT;
reg [5:0] bit_sent = 0;

always @(posedge bit_clk)
begin
    case (status)
        TX_START_BIT: begin
            tx_pin <= 0;
            stop_transmit <= 0;
            status <= TX_SEND_BIT;
        end
        TX_SEND_BIT: begin
				shift_on_clk <= 1;
            tx_pin <= bit_out;
            bit_sent <= bit_sent + 1;
            if(bit_sent == 7 || bit_sent == 15 || bit_sent == 23 || bit_sent == 31) begin
                status <= TX_STOP_BIT;
					 shift_on_clk <= 0;
            end
        end
        TX_STOP_BIT: begin
				shift_on_clk <= 0;
            tx_pin <= 1;
            if(bit_sent == 32) status = TX_CLEAR;
            else status = TX_START_BIT;
        end
        TX_CLEAR: begin
            bit_sent <= 0;
            stop_transmit <= 1;
            status <= TX_START_BIT;
        end
    endcase
end
endmodule