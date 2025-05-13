module two_flop_sync(
    input logic clk,rst,
    input logic [3:0]data_in,
    output logic [3:0]data_out
);

logic [3:0]temp;

always_ff@(posedge clk) begin
    if(rst) begin
        data_out <= '0;
        temp     <= '0;
    end else begin
        temp <= data_in;
        data_out <= temp;
    end
end
endmodule
