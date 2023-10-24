`timescale 1ns/1ps
module mem_data_sync_out
#(
  parameter integer DATA_WIDTH           = 8,
  parameter integer ARRAY                = 32,
  parameter integer MEM_DATA_WIDTH       = DATA_WIDTH*ARRAY
)
(
  input   wire                             clk,
  input   wire [ MEM_DATA_WIDTH  -1 : 0 ]  data_in,
  output  wire [ MEM_DATA_WIDTH  -1 : 0 ]  data_out
);

  genvar n, m;
  generate
    for (n = 0; n < ARRAY; n = n + 1)
    begin: SYNC_N
      for (m = 0; m < (ARRAY - n); m = m + 1)
      begin: SYNC_M
  
        wire [ DATA_WIDTH           -1 : 0 ]        a;
        wire [ DATA_WIDTH           -1 : 0 ]        a_dly;
        wire [ DATA_WIDTH           -1 : 0 ]        a_dly_fwd;
  
        assign a = data_in[n*DATA_WIDTH+:DATA_WIDTH];     
      
        if (m == 0)
          assign a_dly = a;
        else 
          assign a_dly = SYNC_N[n].SYNC_M[m-1].a_dly_fwd;
  
        if (m == (ARRAY - 1 - n))
          assign data_out[n*DATA_WIDTH+:DATA_WIDTH] = SYNC_N[n].SYNC_M[m].a_dly_fwd; 
  
        register_sync #(DATA_WIDTH) read_addr_fwd (clk, a_dly, a_dly_fwd);
      end
  end
  endgenerate
  endmodule