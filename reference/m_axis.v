`timescale 1ns/1ps
module m_axi
#(
  parameter integer DATA_WIDTH    = 8
)
(
  input   wire                            clk,
  input   wire                            reset_n,

  input   wire                            data_en,
  input   wire  [ DATA_WIDTH  -1 : 0 ]    data_in,
  output  wire                            done,

  output  wire                            TVALID,
  input   wire                            TREADY,
  output  wire  [ DATA_WIDTH  -1 : 0 ]    TDATA
);

  reg                         valid_reg;
  reg [ DATA_WIDTH  -1 : 0 ]  data_reg; 

  assign done = TREADY;
  assign TVALID = valid_reg;
  assign TDATA = data_reg;

  always @(posedge clk)
  begin
    if(TREADY && data_en) begin
      valid_reg <= 1'b1;
      data_reg <= data_in;
    end
    else begin
      valid_reg <= 1'b0;
      data_reg <= data_reg;
    end
  end

endmodule
