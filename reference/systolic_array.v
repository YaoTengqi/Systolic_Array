`timescale 1ns/1ps
module systolic_array #(
  parameter integer  ARRAY_M                      = 16,
  parameter integer  ARRAY_N                      = 16,
  parameter integer  INP_DATA_WIDTH               = 8,
  parameter integer  WGT_DATA_WIDTH               = 8,
  parameter integer  MULT_OUT_WIDTH               = INP_DATA_WIDTH + WGT_DATA_WIDTH,
  parameter integer  PE_OUT_WIDTH                 = INP_DATA_WIDTH + WGT_DATA_WIDTH + $clog2(ARRAY_N),
  parameter integer  INP_MEM_DATA_WIDTH           = ARRAY_N * INP_DATA_WIDTH,
  parameter integer  WGT_MEM_DATA_WIDTH           = ARRAY_N * WGT_DATA_WIDTH,
  parameter integer  PE_OUT_DATA_WIDTH            = ARRAY_N * PE_OUT_WIDTH 
) (
  input  wire                                         clk,
  // input  wire                                         reset_n,
  input  wire  [ INP_MEM_DATA_WIDTH             -1 : 0 ]        a,
  input  wire  [ WGT_MEM_DATA_WIDTH             -1 : 0 ]        b,  
  input  wire  [ ARRAY_N                        -1 : 0 ]        b_en,
  input  wire  [ ARRAY_N                        -1 : 0 ]        b_path_en,  
  // input  wire  [ ARRAY_N                        -1 : 0 ]        b_mode,
  output wire  [ PE_OUT_DATA_WIDTH              -1 : 0 ]        systolic_out
);

genvar n, m;
generate
for (m=0; m<ARRAY_M; m=m+1)
begin: LOOP_INPUT_FORWARD
for (n=0; n<ARRAY_N; n=n+1)
begin: LOOP_OUTPUT_FORWARD

  wire [ INP_DATA_WIDTH       -1 : 0 ]        a_in;   
  wire [ INP_DATA_WIDTH       -1 : 0 ]        a_out;     
  // wire [ WGT_DATA_WIDTH            -1 : 0 ]        b_in; 
  // wire [ WGT_DATA_WIDTH            -1 : 0 ]        b_out;
  wire                                        b_en_in;      
  wire                                        b_en_out;  
  wire [ WGT_DATA_WIDTH       -1 : 0 ]        b_path_in;
  wire [ WGT_DATA_WIDTH       -1 : 0 ]        b_path_out; 
  wire                                        b_path_en_in;   
  wire                                        b_path_en_out;   
  // wire                                        b_mode_in;   
  // wire                                        b_mode_out;   
  wire [ PE_OUT_WIDTH         -1 : 0 ]        c_in;  
  wire [ PE_OUT_WIDTH         -1 : 0 ]        c_out;     
  //================================================================================================
  // Operands for the parametric PE
  // Operands are delayed by a cycle when forwarding
  if (m == 0)
  begin
    assign a_in = a[n*INP_DATA_WIDTH+:INP_DATA_WIDTH];
    // assign b_in = pmem_read_data_dly[n*WGT_DATA_WIDTH+:WGT_DATA_WIDTH];
    // assign b_en_in = b_en[n+:1];
    // assign b_path_en_in = b_path_en[n+:1];
    // assign b_mode_in = b_mode[n+:1];
    assign b_path_in = b[n*WGT_DATA_WIDTH+:WGT_DATA_WIDTH];
  end
  else
  begin
    assign a_in = LOOP_INPUT_FORWARD[m-1].LOOP_OUTPUT_FORWARD[n].a_out;
    // assign b_in = LOOP_INPUT_FORWARD[m-1].LOOP_OUTPUT_FORWARD[n].b_out;
    // assign b_en_in = LOOP_INPUT_FORWARD[m-1].LOOP_OUTPUT_FORWARD[n].b_en_out;
    // assign b_path_en_in = LOOP_INPUT_FORWARD[m-1].LOOP_OUTPUT_FORWARD[n].b_path_en_out;
    // assign b_mode_in = LOOP_INPUT_FORWARD[m-1].LOOP_OUTPUT_FORWARD[n].b_mode_out;
    assign b_path_in = LOOP_INPUT_FORWARD[m-1].LOOP_OUTPUT_FORWARD[n].b_path_out;
  end

  //================================================================================================
  if (n == 0)
  begin
    // assign b_path_in = b[m*WGT_DATA_WIDTH+:WGT_DATA_WIDTH];
    assign c_in = 'd0;
    assign b_en_in = b_en[m+:1];
    assign b_path_en_in = b_path_en[m+:1];    
  end
  else
  begin
    // assign b_path_in = LOOP_INPUT_FORWARD[m].LOOP_OUTPUT_FORWARD[n-1].b_path_out;
    assign c_in = LOOP_INPUT_FORWARD[m].LOOP_OUTPUT_FORWARD[n-1].c_out; 

    assign b_en_in = LOOP_INPUT_FORWARD[m].LOOP_OUTPUT_FORWARD[n-1].b_en_out;
    assign b_path_en_in = LOOP_INPUT_FORWARD[m].LOOP_OUTPUT_FORWARD[n-1].b_path_en_out;    
  end

  pe #(
    .INP_DATA_WIDTH                 ( INP_DATA_WIDTH                 ),
    .WGT_DATA_WIDTH                 ( WGT_DATA_WIDTH                 ),
    .PE_OUT_WIDTH                   ( PE_OUT_WIDTH                   )
  ) pe_inst (
    .clk                            ( clk                            ),  
    // .reset_n                          ( reset_n                          ),  
    .a_in                           ( a_in                           ),  
    .a_out                          ( a_out                          ),  
    // .b_in                           ( b_in                           ),  
    // .b_out                          ( b_out                          ),  
    .b_en_in                        ( b_en_in                        ),  
    .b_en_out                       ( b_en_out                       ),  
    .b_path_in                      ( b_path_in                      ),  
    .b_path_out                     ( b_path_out                     ),  
    .b_path_en_in                   ( b_path_en_in                   ),  
    .b_path_en_out                  ( b_path_en_out                  ),  
    // .b_mode_in                      ( b_mode_in                      ),  
    // .b_mode_out                     ( b_mode_out                     ),  
    .c_in                           ( c_in                           ),  
    .c_out                          ( c_out                          ) // c_out = a_in * b_path_in + c_in
    );

  if (n == ARRAY_N - 1)
  begin
    assign systolic_out[m*PE_OUT_WIDTH+:PE_OUT_WIDTH] = c_out;
  end

end
end
endgenerate
endmodule