`timescale 1ns/1ps
module pe #(
  parameter integer  INP_DATA_WIDTH                    = 8,
  parameter integer  WGT_DATA_WIDTH                    = 8,
  parameter integer  MULT_OUT_WIDTH               = INP_DATA_WIDTH + WGT_DATA_WIDTH,
  parameter integer  PE_OUT_WIDTH                 = MULT_OUT_WIDTH

) (
  input  wire                                         clk,
  // input  wire                                         reset_n,
  input  wire  [ INP_DATA_WIDTH       -1 : 0 ]        a_in,
  output wire  [ INP_DATA_WIDTH       -1 : 0 ]        a_out,  
  // input  wire  [ WGT_DATA_WIDTH            -1 : 0 ]        b_in,
  // output wire  [ WGT_DATA_WIDTH            -1 : 0 ]        b_out,  
  input  wire                                         b_en_in,
  output wire                                         b_en_out,    
  input  wire  [ WGT_DATA_WIDTH       -1 : 0 ]        b_path_in,
  output wire  [ WGT_DATA_WIDTH       -1 : 0 ]        b_path_out, 
  input  wire                                         b_path_en_in,
  output wire                                         b_path_en_out,   
  // input  wire                                         b_mode_in,
  // output wire                                         b_mode_out,       
  input wire  signed  [ PE_OUT_WIDTH         -1 : 0 ]        c_in,
  output wire signed  [ PE_OUT_WIDTH         -1 : 0 ]        c_out
);

  reg signed [ PE_OUT_WIDTH       -1 : 0 ]            mult_out_reg;
  reg signed [ PE_OUT_WIDTH       -1 : 0 ]            mult_add_out;

  reg signed [ INP_DATA_WIDTH            -1 : 0 ]            a_reg;
  reg signed [ WGT_DATA_WIDTH            -1 : 0 ]            b_reg;
  reg [ WGT_DATA_WIDTH            -1 : 0 ]            b_path_reg;
  // reg                                                 b_mode_reg;
  reg                                                 b_en_reg;
  reg                                                 b_path_en_reg;

  assign a_out = a_reg;
  // assign b_out = b_reg;
  // assign b_mode_out = b_mode_reg;
  assign b_en_out = b_en_reg;
  assign b_path_en_out = b_path_en_reg;
  assign b_path_out = b_path_reg;
  assign c_out = mult_add_out;  

  always @(posedge clk)
  begin
    a_reg <= a_in;
    // b_mode_reg <= b_mode_in;
    b_en_reg <= b_en_in;
    b_path_en_reg <= b_path_en_in;
  end

  always @(posedge clk)
  begin
    if (b_path_en_reg)
      b_path_reg <= b_path_in;
    else
      b_path_reg <= b_path_reg;
  end

  always @(posedge clk)
  begin
    if (b_en_reg)
      // if (b_mode_reg)
      //   b_reg <= b_in;
      // else
        b_reg <= b_path_reg;
    else
      b_reg <= b_reg;
  end

  always @(posedge clk)
  begin
    mult_out_reg <= a_reg * b_reg;
    mult_add_out <= mult_out_reg + c_in;
  end
endmodule