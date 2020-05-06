module transfer
#(
    parameter CH_NO = 4,
    parameter BAUD_PRESCALER = 200
)(
    input [32*CH_NO - 1:0] data_in,
    input [CH_NO - 1:0] available,
    output reg [CH_NO - 1:0] read,
    input i_clk,
    input _rst,
    output tx_pin
);

reg [$clog2(CH_NO) - 1 : 0] bus_sel = 0;
wire [31:0] ch_data;
wire [31:0] uart_data;
reg uart_load = 0;
reg start_transmit = 0;
wire uart_busy;
bus_selector #(.BUS_NO(CH_NO)) mux (.data(data_in), .sel(bus_sel), .out(ch_data));

assign uart_data = {bus_sel, ch_data[31-$clog2(CH_NO):0]};
uart_tx #(.BAUD_PRESCALER(BAUD_PRESCALER)) tx (.i_clk(i_clk), .fetch(uart_load), .data(uart_data), .transmit(start_transmit), .busy(uart_busy), ._rst(_rst), .tx_pin(tx_pin));

localparam ST_CH_AVAILABLE = 0;
localparam ST_CH_READ = 1;
localparam ST_CH_START_SEND = 2;
localparam ST_CH_WAIT_COMPLETE = 3;

reg [5:0] status = ST_CH_AVAILABLE;

always @(negedge i_clk)
begin
    case (status)
        ST_CH_AVAILABLE: begin
            read <= 0;
            if(available[bus_sel])
                status <= ST_CH_READ;
            else bus_sel <= bus_sel + 1;
        end
        ST_CH_READ: begin
            read[bus_sel] <= 1;
            status <= ST_CH_START_SEND;
        end
        ST_CH_START_SEND: begin
            read[bus_sel] <= 0;
            uart_load <= 1;
            start_transmit <= 1;
            status <= ST_CH_WAIT_COMPLETE;
        end
        ST_CH_WAIT_COMPLETE: begin
            uart_load <= 0;
            start_transmit <= 0;
            if(~uart_busy) begin
                bus_sel <= bus_sel + 1;
                status <= ST_CH_AVAILABLE;
            end
        end
    endcase
end

endmodule