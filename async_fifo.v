// need to update the parameters in -3- modules //

module async_fifo#(parameter DATA_WIDTH = 8,
                             FIFO_DEPTH = 16,
                             ADDR_WIDTH = $clog2(FIFO_DEPTH))(
   input wire clk_w,clk_r, rst,wr_en,rd_en,
   input wire [DATA_WIDTH-1:0]data_in,
   output reg [DATA_WIDTH-1:0]data_out,
   output wire empty,full
);

localparam FIFO_WRAP = FIFO_DEPTH - 1;
//////fifo_memory//////////
reg [DATA_WIDTH-1:0]mem[FIFO_DEPTH-1:0];
///////read write pointers/////////////
reg [ADDR_WIDTH-1:0]rd_ptr,wr_ptr;
//////////grey encoded read and write pointer////////////////
wire [ADDR_WIDTH-1:0]g_rd_ptr,g_wr_ptr;
/////////read sync with clk_w and write sync with clk_r/////////////////
wire [ADDR_WIDTH-1:0]g_rd_ptr_sync,g_wr_ptr_sync;
//////binary pointer converted from grey and sync with clk_w/////////////////
wire [ADDR_WIDTH-1:0]g_b_rd_ptr_sync;
integer i;

////////writing circuit//////////////////
always@(posedge clk_w,posedge rst) begin
   if(rst) begin
     wr_ptr <= {ADDR_WIDTH{1'b0}};
      for(i = 0; i<FIFO_DEPTH;i++) begin
         mem[i] <= {DATA_WIDTH{1'b0}};
      end
   end else begin
   if(wr_en && !full) begin
      mem[wr_ptr] <= data_in;
      wr_ptr <= wr_ptr + 1'b1;
   end else begin
      wr_ptr <= wr_ptr;
   end
   end
end 

///////reading circuit////////////////////
always@(posedge clk_r,posedge rst) begin
  if(rst) begin
    rd_ptr <= {ADDR_WIDTH{1'b0}};
    data_out <= {DATA_WIDTH{1'b0}};
  end else begin
    if(rd_en && !empty) begin
       data_out <= mem[rd_ptr];
       rd_ptr <= rd_ptr + 1'b1;
    end else begin
       rd_ptr <= rd_ptr;
    end
  end
end

//////////converting binary to grey//////////////////
assign g_wr_ptr = ((wr_ptr>>1)^wr_ptr);
assign g_rd_ptr = ((rd_ptr>>1)^rd_ptr);


///////////2 flop synchronizers to synchronise g_wr_ptr with clk_r and  g_rd_ptr with clk_w////////////////////
f_sync f0(.d(g_rd_ptr), .c(clk_w), .r(rst), .o(g_rd_ptr_sync));
f_sync f1(.d(g_wr_ptr), .c(clk_r), .r(rst), .o(g_wr_ptr_sync));
g_b f3(.g(g_rd_ptr_sync), .b(g_b_rd_ptr_sync));

//////////checking full condtion with wrap around condition///////////
assign full = (wr_ptr == FIFO_WRAP) ? (g_b_rd_ptr_sync == 0): (wr_ptr + 1'b1 == g_b_rd_ptr_sync);
assign empty = (g_rd_ptr == g_wr_ptr_sync);

endmodule 


//////2 flop synchronizer module///////////////
module f_sync#(parameter ADDR_WIDTH = 4)(
  input wire c,r,
  input wire [ADDR_WIDTH-1:0]d,
  output reg [ADDR_WIDTH-1:0]o
);
  (* ASYNC_REG = "TRUE" *)reg [ADDR_WIDTH-1:0]a;
  reg [ADDR_WIDTH-1:0]b;


  always@(posedge c, posedge r) begin
    if(r) begin
      o <= {ADDR_WIDTH{1'b0}};
      a <= {ADDR_WIDTH{1'b0}};
      b <= {ADDR_WIDTH{1'b0}};
    end else begin
      a <= d;
      b <= a;
      o <= b;
    end
  end
endmodule 


/////grey to binary converting module/////////////////
module g_b#(parameter ADDR_WIDTH = 4)(
  input wire [ADDR_WIDTH-1:0]g,
  output wire [ADDR_WIDTH-1:0]b
);
  assign b[ADDR_WIDTH-1] = g[ADDR_WIDTH-1];

generate 
  genvar i;
    for(i = ADDR_WIDTH-2; i>=0;i = i-1) begin
      assign b[i] = g[i] ^ b[i+1];
    end
  endgenerate

endmodule 
