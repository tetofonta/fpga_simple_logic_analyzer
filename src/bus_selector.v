module bus_selector
#(
    parameter BUS_NO = 4
)(
    input [32 * BUS_NO - 1:0] data,
    input [$clog2(BUS_NO) - 1:0] sel,
    output reg [31:0] out
);


integer i, j;
always @(*) begin
    for(i=0; i < BUS_NO; i=i+1) begin
        if(sel == i)
            for(j=0;j < 32; j=j+1) begin
                out[j] <= data[j+(i*32)];
            end
    end
end

endmodule