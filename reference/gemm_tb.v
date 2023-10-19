`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/27 14:11:05
// Design Name: 
// Module Name: gemm_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gemm_tb #(
    parameter integer  ARRAY_N                            = 32,
    parameter integer  ARRAY_M                            = 32,

    parameter integer  INP_DATA_WIDTH                     = 8,
    parameter integer  WGT_DATA_WIDTH                     = 8,
    parameter integer  ACC_DATA_WIDTH                     = 32,
    parameter integer  UOP_DATA_WIDTH                     = 32,
    parameter integer  INSN_DATA_WIDTH                    = 256,
    parameter integer  CTRL_QUEUE_DATA_WIDTH              = 8,

    parameter integer  INP_MEM_ADDR_WIDTH_W               = 12,//need reedit
    parameter integer  WGT_MEM_ADDR_WIDTH_W               = 13,//need reedit
    parameter integer  ACC_MEM_ADDR_WIDTH_W               = 12,//need reedit
    parameter integer  ACC_MEM_ADDR_OUT_WIDTH_W           = ACC_MEM_ADDR_WIDTH_W-1,
    parameter integer  UOP_MEM_ADDR_WIDTH_W               = 13,//need reedit

    parameter integer  INSN_UOP_W                         = UOP_MEM_ADDR_WIDTH_W,
    parameter integer  INSN_ITER_W                        = 14,//need reedit
    parameter integer  INSN_INP_FAC_W                     = INP_MEM_ADDR_WIDTH_W,
    parameter integer  INSN_WGT_FAC_W                     = WGT_MEM_ADDR_WIDTH_W,
    parameter integer  INSN_ACC_FAC_W                     = ACC_MEM_ADDR_WIDTH_W,

    parameter integer  PE_OUT_WIDTH                       = INP_DATA_WIDTH + WGT_DATA_WIDTH + $clog2(ARRAY_N),
    parameter integer  ARRAY_N_W                          = $clog2(ARRAY_N),

    parameter integer  INP_MEM_DATA_WIDTH                 = ARRAY_N * INP_DATA_WIDTH,
    parameter integer  WGT_MEM_DATA_WIDTH                 = ARRAY_N * WGT_DATA_WIDTH,
    parameter integer  ACC_MEM_DATA_WIDTH                 = ARRAY_N * ACC_DATA_WIDTH,
    parameter integer  PE_OUT_DATA_WIDTH                  = ARRAY_N * PE_OUT_WIDTH

//    parameter integer  INP_MEM_WE_WIDTH                   = INP_MEM_DATA_WIDTH/8,
//    parameter integer  WGT_MEM_WE_WIDTH                   = WGT_MEM_DATA_WIDTH/8,
//    parameter integer  ACC_MEM_WE_WIDTH                   = ACC_MEM_DATA_WIDTH/8,
//    parameter integer  UOP_MEM_WE_WIDTH                   = UOP_DATA_WIDTH/8
    )
  ();
  reg                                                     start;
  wire                                                     clk;
  wire                                                     reset_n;

  wire  [ INP_MEM_ADDR_WIDTH_W            -1 : 0 ]        inp_mem_read_addr;
  wire                                                    inp_mem_read_req;
  wire  [ INP_MEM_DATA_WIDTH              -1 : 0 ]        inp_mem_read_data;


  // wire  [ WGT_MEM_ADDR_WIDTH_W            -1 : 0 ]        pmem_read_addr;
  // wire                                                    pmem_read_req;
  // wire  [ WGT_MEM_DATA_WIDTH              -1 : 0 ]        pmem_read_data;

  wire  [ WGT_MEM_ADDR_WIDTH_W            -1 : 0 ]        wgt_mem_read_addr;
  wire                                                    wgt_mem_read_req;
  wire  [ WGT_MEM_DATA_WIDTH              -1 : 0 ]        wgt_mem_read_data;

  wire  [ ACC_MEM_ADDR_WIDTH_W            -1 : 0 ]        acc_mem_read_addr;
  wire                                                    acc_mem_read_req;
  wire  [ ACC_MEM_DATA_WIDTH              -1 : 0 ]        acc_mem_read_data;  

  wire  [ ACC_MEM_ADDR_WIDTH_W            -1 : 0 ]        acc_mem_write_addr;
  wire                                                    acc_mem_write_req;
  wire  [ ACC_MEM_DATA_WIDTH              -1 : 0 ]        acc_mem_write_data;  

  wire  [ UOP_MEM_ADDR_WIDTH_W            -1 : 0 ]        inp_uop_read_addr;
  wire                                                    inp_uop_read_req;
  wire  [ UOP_DATA_WIDTH                  -1 : 0 ]        inp_uop_read_data;

  wire  [ UOP_MEM_ADDR_WIDTH_W            -1 : 0 ]        wgt_uop_read_addr;
  wire                                                    wgt_uop_read_req;
  wire  [ UOP_DATA_WIDTH                  -1 : 0 ]        wgt_uop_read_data;

  wire  [ UOP_MEM_ADDR_WIDTH_W            -1 : 0 ]        acc_uop_read_addr;
  wire                                                    acc_uop_read_req;
  wire  [ UOP_DATA_WIDTH                  -1 : 0 ]        acc_uop_read_data;

  wire  [ ACC_MEM_ADDR_OUT_WIDTH_W        -1 : 0 ]        acc_mem_ref0_read_addr;
  wire                                                    acc_mem_ref0_read_req;
  wire  [ ACC_MEM_DATA_WIDTH              -1 : 0 ]        acc_mem_ref0_read_data; 

  wire  [ ACC_MEM_ADDR_OUT_WIDTH_W        -1 : 0 ]        acc_mem_ref1_read_addr;
  wire                                                    acc_mem_ref1_read_req;
  wire  [ ACC_MEM_DATA_WIDTH              -1 : 0 ]        acc_mem_ref1_read_data; 

  wire  [ 4                               -1 : 0 ]        insn_mem_read_addr;
  wire                                                    insn_mem_read_req;
  wire  [ INSN_DATA_WIDTH                  -1 : 0 ]        insn_mem_read_data;



  ram #(
    .ADDR_WIDTH                     ( UOP_MEM_ADDR_WIDTH_W            ),
    .DATA_WIDTH                     ( UOP_DATA_WIDTH                  ),
    .OUTPUT_REG                     ( 1                               )
  ) uop_inp (
    .clk                            ( clk                             ),
    .reset_n                          ( reset_n                           ),
    .s_write_addr                   (                                 ),
    .s_write_req                    (                                 ),
    .s_write_data                   (                                 ),
    .s_read_addr                    ( inp_uop_read_addr               ),
    .s_read_req                     ( inp_uop_read_req                ),
    .s_read_data                    ( inp_uop_read_data               )
    );

  ram #(
    .ADDR_WIDTH                     ( UOP_MEM_ADDR_WIDTH_W            ),
    .DATA_WIDTH                     ( UOP_DATA_WIDTH                  ),
    .OUTPUT_REG                     ( 1                               )
  ) uop_wgt (
    .clk                            ( clk                             ),
    .reset_n                          ( reset_n                           ),
    .s_write_addr                   (                                 ),
    .s_write_req                    (                                 ),
    .s_write_data                   (                                 ),
    .s_read_addr                    ( wgt_uop_read_addr               ),
    .s_read_req                     ( wgt_uop_read_req                ),
    .s_read_data                    ( wgt_uop_read_data               )
    );

  ram #(
    .ADDR_WIDTH                     ( UOP_MEM_ADDR_WIDTH_W            ),
    .DATA_WIDTH                     ( UOP_DATA_WIDTH                  ),
    .OUTPUT_REG                     ( 1                               )
  ) uop_acc (
    .clk                            ( clk                             ),
    .reset_n                          ( reset_n                           ),
    .s_write_addr                   (                                 ),
    .s_write_req                    (                                 ),
    .s_write_data                   (                                 ),
    .s_read_addr                    ( acc_uop_read_addr               ),
    .s_read_req                     ( acc_uop_read_req                ),
    .s_read_data                    ( acc_uop_read_data               )
    );

  ram #(
    .ADDR_WIDTH                     ( INP_MEM_ADDR_WIDTH_W            ),
    .DATA_WIDTH                     ( INP_MEM_DATA_WIDTH              ),
    .OUTPUT_REG                     ( 1                               )
  ) inp_mem (
    .clk                            ( clk                             ),
    .reset_n                          ( reset_n                           ),
    .s_write_addr                   (                                 ),
    .s_write_req                    (                                 ),
    .s_write_data                   (                                 ),
    .s_read_addr                    ( inp_mem_read_addr               ),
    .s_read_req                     ( inp_mem_read_req                ),
    .s_read_data                    ( inp_mem_read_data               )
    );

  // ram #(
  //   .ADDR_WIDTH                     ( WGT_MEM_ADDR_WIDTH_W            ),
  //   .DATA_WIDTH                     ( WGT_MEM_DATA_WIDTH              ),
  //   .OUTPUT_REG                     ( 1                               )
  // ) p_mem (
  //   .clk                            ( clk                             ),
  //   .reset_n                          ( reset_n                           ),
  //   .s_write_addr                   (                                 ),
  //   .s_write_req                    (                                 ),
  //   .s_write_data                   (                                 ),
  //   .s_read_addr                    ( pmem_read_addr                  ),
  //   .s_read_req                     ( pmem_read_req                   ),
  //   .s_read_data                    ( pmem_read_data                  )
  //   );

  ram #(
    .ADDR_WIDTH                     ( WGT_MEM_ADDR_WIDTH_W              ),
    .DATA_WIDTH                     ( WGT_MEM_DATA_WIDTH                ),
    .OUTPUT_REG                     ( 1                                 )
  ) wgt_mem ( 
    .clk                            ( clk                               ),
    .reset_n                          ( reset_n                             ),
    .s_write_addr                   (                                   ),
    .s_write_req                    (                                   ),
    .s_write_data                   (                                   ),
    .s_read_addr                    ( wgt_mem_read_addr                 ),
    .s_read_req                     ( wgt_mem_read_req                  ),
    .s_read_data                    ( wgt_mem_read_data                 )
    );  

  ram #(  
    .ADDR_WIDTH                     ( ACC_MEM_ADDR_OUT_WIDTH_W              ),
    .DATA_WIDTH                     ( ACC_MEM_DATA_WIDTH                ),
    .OUTPUT_REG                     ( 1                                 )
  ) acc_mem ( 
    .clk                            ( clk                               ),
    .reset_n                          ( reset_n                             ),
    .s_write_addr                   ( acc_mem_write_addr                ),
    .s_write_req                    ( acc_mem_write_req                 ),
    .s_write_data                   ( acc_mem_write_data                ),
    .s_read_addr                    ( acc_mem_read_addr                 ),
    .s_read_req                     ( acc_mem_read_req                  ),
    .s_read_data                    ( acc_mem_read_data                 )
    );    

  // ram #(  
  //   .ADDR_WIDTH                     ( ACC_MEM_ADDR_OUT_WIDTH_W              ),
  //   .DATA_WIDTH                     ( ACC_MEM_DATA_WIDTH                ),
  //   .OUTPUT_REG                     ( 1                                 )
  // ) acc_mem_ref0 ( 
  //   .clk                            ( clk                               ),
  //   .reset_n                          ( reset_n                             ),
  //   .s_write_addr                   (                 ),
  //   .s_write_req                    (                  ),
  //   .s_write_data                   (                 ),
  //   .s_read_addr                    ( acc_mem_ref0_read_addr                 ),
  //   .s_read_req                     ( acc_mem_ref0_read_req                  ),
  //   .s_read_data                    ( acc_mem_ref0_read_data                 )
  //   );

  // ram #(  
  //   .ADDR_WIDTH                     ( ACC_MEM_ADDR_OUT_WIDTH_W              ),
  //   .DATA_WIDTH                     ( ACC_MEM_DATA_WIDTH                ),
  //   .OUTPUT_REG                     ( 1                                 )
  // ) acc_mem_ref1 ( 
  //   .clk                            ( clk                               ),
  //   .reset_n                          ( reset_n                             ),
  //   .s_write_addr                   (                 ),
  //   .s_write_req                    (                  ),
  //   .s_write_data                   (                 ),
  //   .s_read_addr                    ( acc_mem_ref1_read_addr                 ),
  //   .s_read_req                     ( acc_mem_ref1_read_req                  ),
  //   .s_read_data                    ( acc_mem_ref1_read_data                 )
  //   );

  ram #(  
    .ADDR_WIDTH                     ( 4                                 ),
    .DATA_WIDTH                     ( INSN_DATA_WIDTH                   ),
    .OUTPUT_REG                     ( 1                                 )
  ) insn_mem ( 
    .clk                            ( clk                               ),
    .reset_n                        ( reset_n                           ),
    .s_write_addr                   (                                   ),
    .s_write_req                    (                                   ),
    .s_write_data                   (                                   ),
    .s_read_addr                    ( insn_mem_read_addr                 ),
    .s_read_req                     ( insn_mem_read_req                  ),
    .s_read_data                    ( insn_mem_read_data                 )
    );

  wire                                                      c2g_TVALID;
  wire                                                      c2g_TREADY;
  wire  [ CTRL_QUEUE_DATA_WIDTH           -1 : 0 ]          c2g_TDATA;

  wire                                                      g2c_TVALID;
  wire                                                      g2c_TREADY = 1'b1;
  wire  [ CTRL_QUEUE_DATA_WIDTH           -1 : 0 ]          g2c_TDATA;

  wire                                                      insn_TVALID;
  // wire                                                      insn_TREADY = 1'b1;
  wire  [ INSN_DATA_WIDTH                 -1 : 0 ]          insn_TDATA;

  reg   [ 4                               -1 : 0 ]          insn_mem_read_addr_reg;
  reg                                                       insn_mem_read_req_reg;
  reg   insn_TVALID_reg;

  assign insn_mem_read_addr = insn_mem_read_addr_reg;
  assign insn_mem_read_req = insn_mem_read_req_reg;

  assign insn_TDATA = insn_mem_read_data;
  assign insn_TVALID = insn_TVALID_reg;
  gemm 
  #(
    .ARRAY_N                        ( ARRAY_N                           ),
    .ARRAY_M                        ( ARRAY_M                           ),
    .INP_DATA_WIDTH                 ( INP_DATA_WIDTH                    ),
    .WGT_DATA_WIDTH                 ( WGT_DATA_WIDTH                    ),
    .ACC_DATA_WIDTH                 ( ACC_DATA_WIDTH                    ),
    .UOP_DATA_WIDTH                 ( UOP_DATA_WIDTH                    ),
    .INSN_DATA_WIDTH                ( INSN_DATA_WIDTH                   ),
    .CTRL_QUEUE_DATA_WIDTH          ( CTRL_QUEUE_DATA_WIDTH             ),
    .INP_MEM_ADDR_WIDTH_W           ( INP_MEM_ADDR_WIDTH_W              ),
    .WGT_MEM_ADDR_WIDTH_W           ( WGT_MEM_ADDR_WIDTH_W              ),
    .ACC_MEM_ADDR_WIDTH_W           ( ACC_MEM_ADDR_WIDTH_W              ),
    .UOP_MEM_ADDR_WIDTH_W           ( UOP_MEM_ADDR_WIDTH_W              )
  ) 
    uut (
    .clk                            ( clk                            ),
    .reset_n                          ( reset_n                          ),

    .inp_mem_read_CLK               (                   ),
    .inp_mem_read_ADDR              ( inp_mem_read_addr                 ),
    .inp_mem_read_EN                ( inp_mem_read_req                   ),
    .inp_mem_read_DOUT              ( inp_mem_read_data                 ),
    .inp_mem_read_WE                (                    ),

    .wgt_mem_read_CLK               (                   ),
    .wgt_mem_read_ADDR              ( wgt_mem_read_addr                 ),
    .wgt_mem_read_EN                ( wgt_mem_read_req                   ),
    .wgt_mem_read_DOUT              ( wgt_mem_read_data                 ),
    .wgt_mem_read_WE                (                    ),

    .acc_mem_read_CLK               (                   ),
    .acc_mem_read_ADDR              ( acc_mem_read_addr                 ),
    .acc_mem_read_EN                ( acc_mem_read_req                   ),
    .acc_mem_read_DOUT              ( acc_mem_read_data                 ),
    .acc_mem_read_WE                (                    ),

    .acc_mem_write_CLK               (                   ),
    .acc_mem_write_ADDR              ( acc_mem_write_addr                 ),
    .acc_mem_write_EN                ( acc_mem_write_req                   ),
    .acc_mem_write_DIN              ( acc_mem_write_data                 ),
    .acc_mem_write_WE                (                    ),

    .inp_uop_read_CLK               (                   ),
    .inp_uop_read_ADDR              ( inp_uop_read_addr                 ),
    .inp_uop_read_EN                ( inp_uop_read_req                   ),
    .inp_uop_read_DOUT              ( inp_uop_read_data                 ),
    .inp_uop_read_WE                (                    ),

    .wgt_uop_read_CLK               (                   ),
    .wgt_uop_read_ADDR              ( wgt_uop_read_addr                 ),
    .wgt_uop_read_EN                ( wgt_uop_read_req                   ),
    .wgt_uop_read_DOUT              ( wgt_uop_read_data                 ),
    .wgt_uop_read_WE                (                    ),

    .acc_uop_read_CLK               (                   ),
    .acc_uop_read_ADDR              ( acc_uop_read_addr                 ),
    .acc_uop_read_EN                ( acc_uop_read_req                   ),
    .acc_uop_read_DOUT              ( acc_uop_read_data                 ),
    .acc_uop_read_WE                (                    ),

    .g2c_TVALID                     ( g2c_TVALID                        ),
    .g2c_TREADY                     ( g2c_TREADY                        ),
    .g2c_TDATA                      ( g2c_TDATA                         ),
    .c2g_TVALID                     ( c2g_TVALID                        ),
    .c2g_TREADY                     ( c2g_TREADY                        ),
    .c2g_TDATA                      ( c2g_TDATA                         ),
    .insn_TVALID                    ( insn_TVALID                       ),
    .insn_TREADY                    ( insn_TREADY                       ),
    .insn_TDATA                     ( insn_TDATA                        )
    );  


  // mem_addr_mux 
  // #(
  //   .DATA_WIDTH                     ( ACC_MEM_DATA_WIDTH                ),
  //   .ADDR_WIDTH_W_IN                ( ACC_MEM_ADDR_WIDTH_W              )
  // ) 
  //   mem_addr_mux_tb (
  //   .clk                            ( clk                            ),
  //   .reset_n                          ( reset_n                         ),

  //   .mem_en_A_in                    (  acc_mem_read_req                      ),
  //   // .mem_wea_A_in                   (  mem_wea_A_in                     ),
  //   .mem_addr_A_in                  (  acc_mem_read_addr                    ),
  //   .mem_din_A_in                   (  acc_mem_read_data                     ),
  //   // .mem_dout_A_in                  (  acc_mem_write_data_a                    ),
  //   .mem_en_B_in                    (  acc_mem_write_req                      ),
  //   // .mem_wea_B_in                   (  mem_wea_B_in                     ),
  //   .mem_addr_B_in                  (  acc_mem_write_addr                    ),
  //   // .mem_din_B_in                   (  acc_mem_write_data                     ),
  //   .mem_dout_B_in                  (  acc_mem_write_data                    ),
  //   // .mem_en_C_in                    (  mem_en_C_in                      ),
  //   // .mem_wea_C_in                   (  mem_wea_C_in                     ),
  //   // .mem_addr_C_in                  (  mem_addr_C_in                    ),
  //   // .mem_din_C_in,                  (  mem_din_C_in                     ),
  //   // .mem_dout_C_in                  (  mem_dout_C_in                    ),
  //   // .mem_en_D_in                    (  mem_en_D_in                      ),
  //   // .mem_wea_D_in                   (  mem_wea_D_in                     ),
  //   // .mem_addr_D_in                  (  mem_addr_D_in                    ),
  //   // .mem_din_D_in                   (  mem_din_D_in                     ),
  //   // .mem_dout_D_in                  (  mem_dout_D_in                    ),
  //   .mem_en_A_out                   (  mem_en_A_out                     ),
  //   // .mem_wea_A_out                  (  mem_wea_A_out                    ),
  //   .mem_addr_A_out                 (  mem_addr_A_out                   ),
  //   .mem_din_A_out                  (  mem_din_A_out                    ),
  //   // .mem_dout_A_out                 (  mem_dout_A_out                   ),
  //   .mem_en_B_out                   (  mem_en_B_out                     ),
  //   // .mem_wea_B_out                  (  mem_wea_B_out                    ),
  //   .mem_addr_B_out                 (  mem_addr_B_out                   ),
  //   // .mem_din_B_out                  (  mem_din_B_out                    )
  //   .mem_dout_B_out                 (  mem_dout_B_out                   )
  //   // .mem_en_C_out                   (  mem_en_C_out                     ),
  //   // .mem_wea_C_out                  (  mem_wea_C_out                    ),
  //   // .mem_addr_C_out                 (  mem_addr_C_out                   ),
  //   // .mem_din_C_out                  (  mem_din_C_out                    ),
  //   // .mem_dout_C_out                 (  mem_dout_C_out                   ),
  //   // .mem_en_D_out                   (  mem_en_D_out                     ),
  //   // .mem_wea_D_out                  (  mem_wea_D_out                    ),
  //   // .mem_addr_D_out                 (  mem_addr_D_out                   ),
  //   // .mem_din_D_out                  (  mem_din_D_out                    ),
  //   // .mem_dout_D_out                 (  mem_dout_D_out                   )
  //   );  


//==================================================================================
//gen_insn
//==================================================================================
  wire  [ 7                                   -1 : 0 ]          opcode;
  wire                                                          reset_reg;
  
  wire  [ INSN_UOP_W                          -1 : 0 ]          uop_bgn;
  wire  [ INSN_UOP_W                             : 0 ]          uop_end;   

  wire  [ INSN_ITER_W                         -1 : 0 ]          iter_in;
  wire  [ INSN_ITER_W                         -1 : 0 ]          iter_out;

  wire  [ INSN_ACC_FAC_W                          -1 : 0 ]          acc_factor_in;
  wire  [ INSN_ACC_FAC_W                          -1 : 0 ]          acc_factor_out; 
  wire  [ INSN_INP_FAC_W                          -1 : 0 ]          inp_factor_in;
  wire  [ INSN_INP_FAC_W                          -1 : 0 ]          inp_factor_out;   
  wire  [ INSN_WGT_FAC_W                          -1 : 0 ]          wgt_factor_in;
  wire  [ INSN_WGT_FAC_W                          -1 : 0 ]          wgt_factor_out;   
   
  wire  [ 8                                   -1 : 0 ]          inp_num;



  always @(posedge clk)
  begin
    if(insn_TREADY)
      insn_TVALID_reg <= 1'b1;
  end
//==================================================================================

  m_axi #(
    .DATA_WIDTH                         ( CTRL_QUEUE_DATA_WIDTH           )
  ) c2g_queue_tb (
    .clk                                ( clk                             ),
    .reset_n                              ( reset_n                           ),
    .data_en                            ( c2g_queue_en                    ),
    .data_in                            ( c2g_queue_data                  ),
    .done                               ( c2g_queue_start                 ),
    .TVALID                             ( c2g_TVALID                      ),
    .TREADY                             ( c2g_TREADY                      ),
    .TDATA                              ( c2g_TDATA                       )
    );

//==================================================================================
// ctrl
//==================================================================================

  // reg gemm_done;

  // always @(posedge clk)
  // begin
  //   if(g2c_TVALID)
  //     gemm_done <= 1'b1;
  //   else
  //     gemm_done <= 1'b0;
  // end

  // localparam integer  COMP_IDLE                       = 0;
  // localparam integer  COMP_START                      = 1;
  // localparam integer  COMP_DONE                       = 2;

  // reg   [ 1                      : 0  ]                     state_comp;

  // always @(posedge clk)
  // begin
  //   if(!reset_n) begin
  //     state_comp <= COMP_IDLE;
  //     insn_mem_read_addr <= 'd0;
  //   end
  //   else begin
  //   case (state_comp)
  //     COMP_IDLE: begin





  localparam integer  TB_IDLE                       = 0;
  localparam integer  TB_START                      = 1;
  localparam integer  TB_DONE                       = 2;

  reg   [ 1                      : 0  ]                     state_tb;
  reg                                                       c2g_queue_en_reg;
  reg   [ CTRL_QUEUE_DATA_WIDTH             -1 : 0 ]        c2g_queue_data_reg;
  wire   [ CTRL_QUEUE_DATA_WIDTH             -1 : 0 ]        c2g_queue_data;

  assign c2g_queue_en = c2g_queue_en_reg;
  assign c2g_queue_data = c2g_queue_data_reg;

  always @(posedge clk)
  begin
    if(!reset_n) begin
      state_tb <= TB_IDLE;
    end
    else begin
    case (state_tb)
      TB_IDLE: begin
        if (start) begin
          c2g_queue_data_reg <= 'b1;
          c2g_queue_en_reg <= 1'b1;
          state_tb <= TB_START;
          end
        else begin
          state_tb <= TB_IDLE;
          c2g_queue_en_reg <= 1'b0;
          c2g_queue_data_reg <= c2g_queue_data_reg;
        end
      end 
      TB_START: begin
          state_tb <= TB_DONE;
          c2g_queue_en_reg <= 1'b0;
      end  
      TB_DONE: begin
          state_tb <= TB_DONE;
          c2g_queue_en_reg <= 1'b0;
      end          
        default : state_tb <= state_tb;
  endcase
    end
  end
//==================================================================================
  reg                                                    clk_tb;
  reg                                                    reset_n_tb;
  assign clk = clk_tb;
  assign reset_n = reset_n_tb;

  integer i;
  integer bt;
  
  initial begin
    clk_tb = 1'b0;
    forever begin
    #1 clk_tb = ~clk_tb;
  end
  end

  initial begin
  #10 start = 1'b0;
  reset_n_tb = 1'b1;
  #10 reset_n_tb = 1'b0;
  #10 reset_n_tb= 1'b1;

//ARRAY=16
  $readmemh("/media/sy/data/project/verilog/sim_data/uop_wgt.txt", uop_wgt.mem);
  $readmemh("/media/sy/data/project/verilog/sim_data/uop_inp.txt", uop_inp.mem);
  $readmemh("/media/sy/data/project/verilog/sim_data/uop_acc.txt", uop_acc.mem);
  $readmemh("/media/sy/data/project/verilog/sim_data/wgt.txt", wgt_mem.mem);
  $readmemh("/media/sy/data/project/verilog/sim_data/inp.txt", inp_mem.mem);
  $readmemh("/media/sy/data/project/verilog/sim_data/acc_initial.txt", acc_mem.mem);
  $readmemh("/media/sy/data/project/verilog/sim_data/ins.txt", insn_mem.mem);

  #10 insn_mem_read_req_reg = 1'b1;
      insn_mem_read_addr_reg = 'd0;
  #2 insn_mem_read_req_reg = 1'b0;

  #10 start = 1'b1;
  #2 start = 1'b0;

  #90000 bt = $fopen("gemm_acc.txt","wb");
  #2 for(i=0;i<4096;i=i+1)
        begin              
          $fwrite(bt,"%128x\n",acc_mem.mem[i]);
        end
        $fclose(bt);

  start = 1'b1;
  #2 start = 1'b0;
end


endmodule
