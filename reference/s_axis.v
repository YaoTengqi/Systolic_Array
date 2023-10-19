`timescale 1ns/1ps
module s_axi
#(
  parameter integer DATA_WIDTH    = 8
)
(
  input   wire                          clk,
  input   wire                          reset_n,

  output  wire                          data_en,
  output  wire  [ DATA_WIDTH  -1 : 0 ]  data_out,
  input   wire                          start,

  input   wire                          TVALID,
  output  wire                          TREADY,
  input   wire  [ DATA_WIDTH  -1 : 0 ]  TDATA
);

  reg [ DATA_WIDTH  -1 : 0 ] data_reg = 'd0;
  // reg [ DATA_WIDTH  -1 : 0 ] data_reg;
  reg                       data_en_reg;
  assign TREADY = start;
  assign data_out = data_reg;
  assign data_en = data_en_reg;
  
  always @(posedge clk)
  begin
    if(TVALID && start) begin
      data_reg <= TDATA;
      data_en_reg <= 1'b1;
    end
    else begin
      data_reg <= data_reg;
      data_en_reg <= 1'b0;
    end
  end  
endmodule
