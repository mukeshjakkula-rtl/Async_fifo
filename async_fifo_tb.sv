class packet;
   rand bit [7:0]d[];
   function new(int a);
    d = new[a];  
   endfunction

   constraint val{foreach(d[i]){d[i] inside{[0:500]};}}

endclass

module async_fifo_tb#(parameter DATA_WIDTH = 8,
                             FIFO_DEPTH = 16,
                             ADDR_WIDTH = $clog2(FIFO_DEPTH));
   
   reg clk_r,clk_w,rst;
   reg rd_en,wr_en;
   reg [DATA_WIDTH-1:0]data_in;
   wire [DATA_WIDTH-1:0]data_out;
   wire empty,full;

 async_fifo dut(.clk_r(clk_r), .clk_w(clk_w), .rst(rst), .rd_en(rd_en), .wr_en(wr_en), .data_in(data_in), .data_out(data_out), .empty(empty), .full(full));

  packet p;

  initial begin
  clk_r = 1'b0;
  clk_w = 1'b0;
  rst = 1'b1;
  rd_en = 1'b0;
  #3 rst = 1'b0;
  p = new(16);
  p.randomize();
  foreach(p.d[i]) begin
    @(posedge clk_w) data_in = p.d[i];
                     wr_en = 1'b1;
  end

  rd_en = 1'b1;
  wr_en = 1'b0;
 repeat(50) @(posedge clk_r);

  end 

   always  #20 clk_r = ~clk_r;
   always  #10 clk_w = ~clk_w;



  initial begin
    $dumpfile("async_fifo_wave.vcd");
    $dumpvars(0,async_fifo_tb);
  end

  initial begin
 #1000 $finish;
end
endmodule 
