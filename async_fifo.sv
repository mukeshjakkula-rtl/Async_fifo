module async_fifo(
input logic wr_clk,rd_clk,
input logic [31:0]data_in,
input logic wr_rst,rd_rst,
input logic wr_en,rd_en,
output logic [31:0]data_out,
output logic full,empty
);

logic [31:0]fifo_mem[15:0];
logic [4:0]wr_ptr,rd_ptr;
logic [3:0]ws_rd_ptr,rs_wr_ptr;

// checking the full condition
assign full = ((wr_ptr[3:0] == rd_ptr[3:0]) &(wr_ptr[4] != rd_ptr[4]));

// checking the empty condition
assign empty = (wr_ptr == rd_ptr);


// fifo data pushing inside 
always_ff@(posedge wr_clk) begin 
    if(wr_rst) begin
        wr_ptr <= '0;
    end else
    if(wr_en & (~full)) begin
        fifo_mem[wr_ptr[3:0]] <= data_in;
        wr_ptr                <= wr_ptr + 1;
    end
end

// fifo data poping outside
always@(posedge rd_clk) begin
    if(rd_rst) begin
        rd_ptr <= '0;
    end else
    if(rd_en & (~empty)) begin  
        data_out     <= fifo_mem[rd_ptr[3:0]];
        rd_ptr   <= rd_ptr + 1;    
    end
end  
endmodule



