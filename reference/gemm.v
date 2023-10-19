`timescale 1ns/1ps
module gemm #(
    parameter integer  ARRAY_N                            = 32,
    parameter integer  ARRAY_M                            = 32,

    parameter integer  INP_NUM_W                          = 10,

    parameter integer  INP_DATA_WIDTH                     = 8,
    parameter integer  WGT_DATA_WIDTH                     = 8,
    parameter integer  ACC_DATA_WIDTH                     = 32,
    parameter integer  UOP_DATA_WIDTH                     = 32,
    parameter integer  INSN_DATA_WIDTH                    = 256,
    parameter integer  CTRL_QUEUE_DATA_WIDTH              = 8,

    parameter integer  INP_MEM_ADDR_WIDTH_W               = 12,//need reedit
    parameter integer  WGT_MEM_ADDR_WIDTH_W               = 13,//need reedit
    parameter integer  ACC_MEM_ADDR_WIDTH_W               = 12,//need reedit
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
    parameter integer  PE_OUT_DATA_WIDTH                  = ARRAY_N * PE_OUT_WIDTH)

//    parameter integer  INP_MEM_WE_WIDTH                   = INP_MEM_DATA_WIDTH/8,
//    parameter integer  WGT_MEM_WE_WIDTH                   = WGT_MEM_DATA_WIDTH/8,
//    parameter integer  ACC_MEM_WE_WIDTH                   = ACC_MEM_DATA_WIDTH/8,
//    parameter integer  UOP_MEM_WE_WIDTH                   = UOP_DATA_WIDTH/8 
    (
    input   wire                                                      clk,
    input   wire                                                      reset_n,

    // output  wire                                                      inp_mem_read_CLK,
    output  wire  [ INP_MEM_ADDR_WIDTH_W            -1 : 0 ]          inp_mem_read_ADDR,
    output  wire                                                      inp_mem_read_EN,
    input   wire  [ INP_MEM_DATA_WIDTH              -1 : 0 ]          inp_mem_read_DOUT,
    output  wire                                                      inp_mem_read_WE,

    // output  wire                                                      wgt_mem_read_CLK,
    output  wire  [ WGT_MEM_ADDR_WIDTH_W            -1 : 0 ]          wgt_mem_read_ADDR,
    output  wire                                                      wgt_mem_read_EN,
    input   wire  [ WGT_MEM_DATA_WIDTH              -1 : 0 ]          wgt_mem_read_DOUT,
    output  wire                                                      wgt_mem_read_WE,

    // output  wire                                                      acc_mem_read_CLK,
    output  wire  [ ACC_MEM_ADDR_WIDTH_W            -1 : 0 ]          acc_mem_read_ADDR,
    output  wire                                                      acc_mem_read_EN,
    input   wire  [ ACC_MEM_DATA_WIDTH              -1 : 0 ]          acc_mem_read_DOUT,
    output  wire                                                      acc_mem_read_WE,

    // output  wire                                                      acc_mem_write_CLK,
    output  wire  [ ACC_MEM_ADDR_WIDTH_W            -1 : 0 ]          acc_mem_write_ADDR,
    output  wire                                                      acc_mem_write_EN,
    output  wire  [ ACC_MEM_DATA_WIDTH              -1 : 0 ]          acc_mem_write_DIN, 
    output  wire                                                      acc_mem_write_WE,

    // output  wire                                                      inp_uop_read_CLK,
    output  wire  [ UOP_MEM_ADDR_WIDTH_W            -1 : 0 ]          inp_uop_read_ADDR,
    output  wire                                                      inp_uop_read_EN,
    input   wire  [ UOP_DATA_WIDTH                  -1 : 0 ]          inp_uop_read_DOUT,
    output  wire                                                      inp_uop_read_WE,

    // output  wire                                                      wgt_uop_read_CLK,
    output  wire  [ UOP_MEM_ADDR_WIDTH_W            -1 : 0 ]          wgt_uop_read_ADDR,
    output  wire                                                      wgt_uop_read_EN,
    input   wire  [ UOP_DATA_WIDTH                  -1 : 0 ]          wgt_uop_read_DOUT,
    output  wire                                                      wgt_uop_read_WE,

    // output  wire                                                      acc_uop_read_CLK,
    output  wire  [ UOP_MEM_ADDR_WIDTH_W            -1 : 0 ]          acc_uop_read_ADDR,
    output  wire                                                      acc_uop_read_EN,
    input   wire  [ UOP_DATA_WIDTH                  -1 : 0 ]          acc_uop_read_DOUT, 
    output  wire                                                      acc_uop_read_WE,

    output  wire                                                      g2c_TVALID,
    input   wire                                                      g2c_TREADY,
    output  wire  [ CTRL_QUEUE_DATA_WIDTH           -1 : 0 ]          g2c_TDATA,

    input   wire                                                      c2g_TVALID,
    output  wire                                                      c2g_TREADY,
    input   wire  [ CTRL_QUEUE_DATA_WIDTH           -1 : 0 ]          c2g_TDATA,

    input   wire                                                      insn_TVALID,
    output  wire                                                      insn_TREADY,
    input   wire  [ INSN_DATA_WIDTH                 -1 : 0 ]          insn_TDATA

  
);
//==================================================================================
  assign inp_mem_read_WE = 'b0;
  assign wgt_mem_read_WE = 'b0;
  assign acc_mem_read_WE = 'b0;
  assign acc_mem_write_WE = 1'b1;
  assign inp_uop_read_WE = 'b0;
  assign wgt_uop_read_WE = 'b0;
  assign acc_uop_read_WE = 'b0;
  assign insn_mem_read_wea = 'b0;

  // assign inp_mem_read_CLK = clk;
  // assign wgt_mem_read_CLK = clk;
  // assign acc_mem_read_CLK = clk;
  // assign acc_mem_write_CLK = clk;
  // assign inp_uop_read_CLK = clk;
  // assign wgt_uop_read_CLK = clk;
  // assign acc_uop_read_CLK = clk;

//==================================================================================
  reg   [ ARRAY_N                         -1 : 0  ]         b_path_en_reg;
  reg   [ ARRAY_N                         -1 : 0  ]         b_en_reg;
  // reg   [ ARRAY_N                         -1 : 0  ]         b_mode;

  wire  [ ACC_MEM_ADDR_WIDTH_W            -1 : 0 ]          acc_read_addr;
  wire                                                      acc_read_req;
  
  reg                                                       load_inp_start;
  reg                                                       load_wgt_start;
  reg                                                       load_acc_start;

  wire                                                      update_wgt;
  wire                                                      wgt_done;
  wire                                                      wgt_ld_done;
  wire                                                      acc_uop_done;
  wire                                                      inp_done;
  wire                                                      acc_done;
  reg                                                       start; 
  wire                                                      inp_start;
  wire                                                      wgt_start;
  wire                                                      acc_start;

//==================================================================================
  assign inp_start = load_inp_start;
  assign wgt_start = load_wgt_start;
  assign acc_start = load_acc_start;
//==================================================================================
  wire                                                      c2g_queue_en;
  wire                                                      c2g_queue_start;
  wire  [ CTRL_QUEUE_DATA_WIDTH             -1 : 0 ]        c2g_queue_data;

  wire                                                      g2c_queue_en;
  wire                                                      g2c_queue_start;
  wire  [ CTRL_QUEUE_DATA_WIDTH             -1 : 0 ]        g2c_queue_data;

  s_axi #(
    .DATA_WIDTH                         ( CTRL_QUEUE_DATA_WIDTH           )
  ) c2g_queue (
    .clk                                ( clk                             ),
    .reset_n                              ( reset_n                           ),
    .data_en                            ( c2g_queue_en                    ),
    .data_out                           ( c2g_queue_data                  ),
    .start                              ( c2g_queue_start                 ),
    .TVALID                             ( c2g_TVALID                      ),
    .TREADY                             ( c2g_TREADY                      ),
    .TDATA                              ( c2g_TDATA                       )
    );

  m_axi #(
    .DATA_WIDTH                         ( CTRL_QUEUE_DATA_WIDTH           )
  ) g2c_queue (
    .clk                                ( clk                             ),
    .reset_n                              ( reset_n                           ),
    .data_en                            ( g2c_queue_en                    ),
    .data_in                            ( g2c_queue_data                  ),
    .done                               ( g2c_queue_start                 ),
    .TVALID                             ( g2c_TVALID                      ),
    .TREADY                             ( g2c_TREADY                      ),
    .TDATA                              ( g2c_TDATA                       )
    );

//==================================================================================
  wire                                                      insn_queue_en;
  wire                                                      insn_queue_start;
  wire  [ INSN_DATA_WIDTH                   -1 : 0 ]        insn_queue_data;

  s_axi #(
    .DATA_WIDTH                         ( INSN_DATA_WIDTH                 )
  ) insn_queue (
    .clk                                ( clk                              ),
    .reset_n                              ( reset_n                            ),
    .data_en                            ( insn_queue_en                    ),
    .data_out                           ( insn_queue_data                  ),
    .start                              ( insn_queue_start                 ),
    .TVALID                             ( insn_TVALID                      ),
    .TREADY                             ( insn_TREADY                      ),
    .TDATA                              ( insn_TDATA                       )
    );
//==================================================================================
// ctrl
//==================================================================================
  wire  [ 7                                   -1 : 0 ]          opcode;
  wire                                                          reset_n_reg;
  
  wire  [ INSN_UOP_W                          -1 : 0 ]          acc_uop_bgn;
  wire  [ INSN_UOP_W                             : 0 ]          acc_uop_end;   
  wire  [ INSN_UOP_W                          -1 : 0 ]          inp_uop_bgn;
  wire  [ INSN_UOP_W                             : 0 ]          inp_uop_end;  

  wire  [ 1                                   -1 : 0 ]          need_load_uop;
  wire  [ INP_NUM_W                           -1 : 0 ]          inp_num;

  wire  [ INSN_ITER_W                         -1 : 0 ]          iter_in;
  wire  [ INSN_ITER_W                         -1 : 0 ]          iter_out;

  wire  [ INSN_ACC_FAC_W                      -1 : 0 ]          acc_factor_in;
  wire  [ INSN_ACC_FAC_W                      -1 : 0 ]          acc_factor_out; 
  wire  [ INSN_INP_FAC_W                      -1 : 0 ]          inp_factor_in;
  wire  [ INSN_INP_FAC_W                      -1 : 0 ]          inp_factor_out;   
  wire  [ INSN_WGT_FAC_W                      -1 : 0 ]          wgt_factor_in;
  wire  [ INSN_WGT_FAC_W                      -1 : 0 ]          wgt_factor_out;   

//  wire  [ 12                      -1 : 0 ]          wgt_factor_in;
//  wire  [ 12                      -1 : 0 ]          wgt_factor_out;  

  wire  [ 1                                   -1 : 0 ]          fix_1b;
  wire  [ 2                                   -1 : 0 ]          fix_2b;
  assign {wgt_factor_in, wgt_factor_out, inp_factor_in, inp_factor_out, fix_2b, acc_factor_in, 
          acc_factor_out, iter_in, iter_out, inp_num, fix_1b, need_load_uop, inp_uop_end, 
          inp_uop_bgn, acc_uop_end, acc_uop_bgn, reset_n_reg, opcode} = insn_queue_data;

//==================================================================================
  localparam integer  CTRL_IDLE                       = 0;
  localparam integer  CTRL_WAIT                       = 1;
  localparam integer  CTRL_START                      = 2;
  localparam integer  CTRL_DONE                       = 3;

  reg   [ 1                      : 0  ]                     state_ctrl;
  reg                                                       insn_queue_start_reg;
  reg                                                       c2g_queue_start_reg;
  reg                                                       g2c_queue_en_reg;
  reg   [ CTRL_QUEUE_DATA_WIDTH             -1 : 0 ]        g2c_queue_data_reg;

  assign insn_queue_start = insn_queue_start_reg;
  assign c2g_queue_start = c2g_queue_start_reg;
  assign g2c_queue_en = g2c_queue_en_reg;
  assign g2c_queue_data = g2c_queue_data_reg;

  always @(posedge clk)
  begin
    if(!reset_n) begin
      state_ctrl <= CTRL_IDLE;
      start <= 1'b0;
      insn_queue_start_reg <= 'b0;
      c2g_queue_start_reg <= 'b0;
      g2c_queue_en_reg <= 'b0;
      g2c_queue_data_reg <= 'b0;
    end
    else begin
    case (state_ctrl)
      CTRL_IDLE: begin
        if (c2g_queue_en) begin
          start <= 1'b1;
          c2g_queue_start_reg <= 1'b0;
          insn_queue_start_reg <= 1'b1;
          g2c_queue_en_reg <= 1'b0;        
          state_ctrl <= CTRL_WAIT;
          end
        else begin
          state_ctrl <= CTRL_IDLE;
          c2g_queue_start_reg <= 1'b1;
          g2c_queue_en_reg <= 1'b0; 
          // insn_queue_start_reg <= 1'b0;
          // start <= 1'b0;
        end
      end 
       CTRL_WAIT: begin
          if(acc_start) begin
            state_ctrl <= CTRL_START;
          end
          else begin
            state_ctrl <= CTRL_WAIT;
            insn_queue_start_reg <= 1'b0;
            start <= 1'b0;
          end
        end      
       CTRL_START: begin
          if(acc_done) begin
            state_ctrl <= CTRL_DONE;
          end
          else begin
            state_ctrl <= CTRL_START;
          end
        end
       CTRL_DONE: begin
          if(g2c_queue_start) begin
            state_ctrl <= CTRL_IDLE;
            g2c_queue_en_reg <= 1'b1;
            g2c_queue_data_reg <= reset_n_reg + 1'b1;
          end
          else begin
            state_ctrl <= CTRL_DONE;
            g2c_queue_en_reg <= 1'b0;
            g2c_queue_data_reg <= 'd0;
          end
        end        
        default : state_ctrl <= state_ctrl;
  endcase
    end
  end

//==================================================================================

  address_offset #(
    .ARRAY_N                        ( ARRAY_N                         ),
    .UOP_DATA_WIDTH                 ( UOP_DATA_WIDTH                  ),

    .INP_NUM_W                      ( INP_NUM_W                       ),
    .INSN_UOP_W                     ( INSN_UOP_W                      ),
    .INSN_ITER_W                    ( INSN_ITER_W                     ),
    .INSN_FAC_W                     ( INSN_INP_FAC_W                  ),

    .MEM_ADDR_WIDTH_W               ( INP_MEM_ADDR_WIDTH_W            ),
    .UOP_MEM_ADDR_WIDTH_W           ( UOP_MEM_ADDR_WIDTH_W            )
  ) inp_addr (
    .clk                            ( clk                             ),
    .reset_n                        ( reset_n                         ),
    .start                          ( inp_start                       ),
    .insn_done                      ( inp_done                        ),
    .load_done                      ( update_wgt                      ),
    .mem_read_addr                  ( inp_mem_read_ADDR               ),
    .mem_read_req                   ( inp_mem_read_EN                 ),
    .inp_num                        ( inp_num                         ),
    .uop_bgn                        ( inp_uop_bgn                     ),
    .uop_end                        ( inp_uop_end                     ),
    .iter_in                        ( iter_in                         ),
    .iter_out                       ( iter_out                        ),
    .factor_in                      ( inp_factor_in                   ),
    .factor_out                     ( inp_factor_out                  ),
    .uop_read_addr                  ( inp_uop_read_ADDR               ),
    .uop_read_req                   ( inp_uop_read_EN                 ),
    .uop_read_data                  ( inp_uop_read_DOUT               )
    );

  address_offset_wgt #(
    .ARRAY_N                        ( ARRAY_N                         ),
    .UOP_DATA_WIDTH                 ( UOP_DATA_WIDTH                  ),

    .INP_NUM_W                      ( INP_NUM_W                       ),

    .INSN_UOP_W                     ( INSN_UOP_W                      ),
    .INSN_ITER_W                    ( INSN_ITER_W                     ),
    .INSN_FAC_W                     ( INSN_WGT_FAC_W                      ),

    .MEM_ADDR_WIDTH_W               ( WGT_MEM_ADDR_WIDTH_W            ),
    .UOP_MEM_ADDR_WIDTH_W           ( UOP_MEM_ADDR_WIDTH_W            )
  ) wgt_addr (
    .clk                            ( clk                             ),
    .reset_n                          ( reset_n                       ),
    .start                          ( wgt_start                       ),
    .insn_done                      ( wgt_done                        ),
    .load_done                      ( wgt_ld_done                     ),
    .mem_read_addr                  ( wgt_mem_read_ADDR               ),
    .mem_read_req                   ( wgt_mem_read_EN                 ),
    .inp_num                        ( inp_num                         ),
    .uop_bgn                        ( inp_uop_bgn                     ),
    .uop_end                        ( inp_uop_end                     ),
    .iter_in                        ( iter_in                         ),
    .iter_out                       ( iter_out                        ),
    .factor_in                      ( wgt_factor_in                   ),
    .factor_out                     ( wgt_factor_out                  ),
    .uop_read_addr                  ( wgt_uop_read_ADDR               ),
    .uop_read_req                   ( wgt_uop_read_EN                 ),
    .uop_read_data                  ( wgt_uop_read_DOUT               )
    );

  address_offset #(
    .ARRAY_N                        ( ARRAY_N                         ),
    .UOP_DATA_WIDTH                 ( UOP_DATA_WIDTH                  ),

    .INP_NUM_W                      ( INP_NUM_W                       ),

    .INSN_UOP_W                     ( INSN_UOP_W                      ),
    .INSN_ITER_W                    ( INSN_ITER_W                     ),
    .INSN_FAC_W                     ( INSN_ACC_FAC_W                      ),

    .MEM_ADDR_WIDTH_W               ( ACC_MEM_ADDR_WIDTH_W            ),
    .UOP_MEM_ADDR_WIDTH_W           ( UOP_MEM_ADDR_WIDTH_W            )
  ) acc_addr (
    .clk                            ( clk                             ),
    .reset_n                          ( reset_n                       ),
    .start                          ( acc_start                       ),
    .insn_done                      ( acc_done                        ),
    .load_done                      ( acc_uop_done                    ),
    .mem_read_addr                  ( acc_read_addr                   ),
    .mem_read_req                   ( acc_read_req                    ),
    .inp_num                        ( inp_num                         ),
    .uop_bgn                        ( acc_uop_bgn                     ),
    .uop_end                        ( acc_uop_end                     ),
    .iter_in                        ( iter_in                         ),
    .iter_out                       ( iter_out                        ),
    .factor_in                      ( acc_factor_in                   ),
    .factor_out                     ( acc_factor_out                  ),
    .uop_read_addr                  ( acc_uop_read_ADDR               ),
    .uop_read_req                   ( acc_uop_read_EN                 ),
    .uop_read_data                  ( acc_uop_read_DOUT               )
    );    


//==================================================================================
// control load_wgt_start
//==================================================================================

  localparam integer  LOAD_WGT_IDLE                 = 0;
  localparam integer  LOAD_WGT                      = 1;
  localparam integer  LOAD_WGT_1                    = 2;

  reg   [ 2                      : 0  ]         state_ld_wgt;
  reg                                           update_wgt_dly1;
  reg                                           update_wgt_dly2;

//delay
  always @(posedge clk)
  begin
    update_wgt_dly1 <= update_wgt;    
    update_wgt_dly2 <= update_wgt_dly1; 
  end

  always @(posedge clk)
  begin
    if(!reset_n) begin
      state_ld_wgt <= LOAD_WGT_IDLE;
      load_wgt_start <= 1'b0;
    end
    else begin
    case (state_ld_wgt)
      LOAD_WGT_IDLE: begin
        if (start) begin
          state_ld_wgt <= LOAD_WGT;
          load_wgt_start <= 1'b1;
          end
        else begin
          state_ld_wgt <= LOAD_WGT_IDLE;
          load_wgt_start <= 1'b0;
        end
      end 
      LOAD_WGT: begin
        if(wgt_ld_done) begin
          state_ld_wgt <= LOAD_WGT_1;
          load_wgt_start <= 1'b1;
        end
        else begin
          load_wgt_start <= 1'b0;
          state_ld_wgt <= LOAD_WGT;
        end
      end
      LOAD_WGT_1: begin
        if(wgt_done) begin
          state_ld_wgt <= LOAD_WGT_IDLE;
          load_wgt_start <= 1'b0;
        end
        else if(update_wgt_dly2) begin
          load_wgt_start <= 1'b1;
        end       
        else begin
          state_ld_wgt <= LOAD_WGT_1;
          load_wgt_start <= 1'b0;      
        end
      end
      default : state_ld_wgt <= state_ld_wgt;
    endcase
    end
  end
//==================================================================================
// gen b_en_reg
//==================================================================================
  localparam integer  GEN_UPDATE_IDLE                 = 0;
  localparam integer  GEN_UPDATE                      = 1;

  reg   [ 2                      : 0  ]         state_gen_update;
  reg                                           update_b_en;

  always @(posedge clk)
  begin
    if(!reset_n) begin
      state_gen_update <= GEN_UPDATE_IDLE;
      update_b_en <= 1'b0;
    end
    else begin
    case (state_gen_update)
      GEN_UPDATE_IDLE: begin
        if (wgt_ld_done) begin
          update_b_en <= 1'b1;
          state_gen_update <= GEN_UPDATE;
        end
        else begin
          update_b_en <= 1'b0;
        end
      end
      GEN_UPDATE: begin
        if(inp_done) begin
          update_b_en <= 1'b0;
          state_gen_update <= GEN_UPDATE_IDLE;
        end
        else if(update_wgt_dly2) begin
          update_b_en <= 1'b1;
          state_gen_update <= GEN_UPDATE;
        end
        else begin
          update_b_en <= 1'b0;
          state_gen_update <= GEN_UPDATE;
        end
      end
    endcase
    end
  end

//==================================================================================
// gen b_path_en_reg
//==================================================================================
  localparam integer  GEN_PATH_IDLE                 = 0;
  localparam integer  GEN_PATH                      = 1;

  reg   [ 1                      : 0  ]         state_gen_path;
  reg   [ ARRAY_N_W           +1 : 0  ]         gen_path_cnt;
  reg                                           load_wgt_start_dly1;
  reg                                           load_wgt_start_dly2;

//delay
  always @(posedge clk)
  begin
    load_wgt_start_dly1 <= load_wgt_start;    
    load_wgt_start_dly2 <= load_wgt_start_dly1; 
  end

  always @(posedge clk)
  begin
    if(!reset_n) begin
      state_gen_path <= GEN_PATH_IDLE;
    end
    else begin
    case (state_gen_path)
      GEN_PATH_IDLE: begin
        if (load_wgt_start_dly2) begin
          gen_path_cnt <= 1'b0;
          state_gen_path <= GEN_PATH;
          b_path_en_reg <= 'b1;
          end
        else begin
          state_gen_path <= GEN_PATH_IDLE;
          gen_path_cnt <= 1'b0;
          b_path_en_reg <= 'b0;
        end
      end 
       GEN_PATH: begin
          if(gen_path_cnt == ARRAY_N-1) begin
            gen_path_cnt <= 1'b0;
            b_path_en_reg <= 'b0;
            state_gen_path <= GEN_PATH_IDLE;
          end
          else begin
            gen_path_cnt <= gen_path_cnt + 1'b1;
            b_path_en_reg <= (b_path_en_reg << 1) + 1'b1;
            state_gen_path <= GEN_PATH;
          end
        end
        default : state_gen_path <= state_gen_path;
  endcase
    end
  end

//==================================================================================
// gen b_en_reg
//==================================================================================
  localparam integer  GEN_EN_IDLE                 = 0;
  localparam integer  GEN_EN                      = 1;

  reg   [ 1                      : 0  ]         state_gen_en;
  reg   [ ARRAY_N_W           +1 : 0  ]         gen_en_cnt;

  always @(posedge clk)
  begin
    if(!reset_n) begin
      state_gen_en <= GEN_EN_IDLE;
    end
    else begin
    case (state_gen_en)
      GEN_EN_IDLE: begin
        if (update_b_en) begin
          gen_en_cnt <= 'b0;
          state_gen_en <= GEN_EN;
          b_en_reg <= 'b1;
          end
        else begin
          state_gen_en <= GEN_EN_IDLE;
          gen_en_cnt <= 'b0;
          b_en_reg <= 'b0;
        end
      end 
       GEN_EN: begin
          if(gen_en_cnt == ARRAY_N-1) begin
            gen_en_cnt <= 1'b0;
            b_en_reg <= (b_en_reg << 1);
            state_gen_en <= GEN_EN_IDLE;
          end
          else begin
            gen_en_cnt <= gen_en_cnt + 1'b1;
            b_en_reg <= b_en_reg << 1;
            state_gen_en <= GEN_EN;
          end
        end
        default : state_gen_en <= state_gen_en;
  endcase
    end
  end

//==================================================================================
// 
//==================================================================================
  localparam integer  LOAD_INP_IDLE                   = 0;
  localparam integer  LOAD_WAIT                       = 1;
  localparam integer  LOAD_INP                        = 2;

  reg   [ 1                      : 0  ]         state_ld_inp;
  reg   [ ARRAY_N_W           +2 : 0  ]         load_inp_cnt;

   always @(posedge clk)
  begin
        if(!reset_n) begin
      state_ld_inp <= LOAD_INP_IDLE;
      load_inp_start <= 1'b0;
      load_acc_start <= 1'b0;
    end
    else begin
    case (state_ld_inp)
      LOAD_INP_IDLE: begin
        if (start) begin
          state_ld_inp <= LOAD_WAIT;
          end
        else begin
          load_inp_cnt <= 'b0;
          load_inp_start <= 1'b0;
          load_acc_start <= 1'b0;
        end
      end 
      LOAD_WAIT: begin
        if(load_inp_cnt == ARRAY_N-2) begin
          state_ld_inp <= LOAD_INP;
          load_inp_start <= 1'b1;
          load_inp_cnt <= 'b0;
          end
        else begin
           load_inp_cnt <= load_inp_cnt + 1'b1;
           load_inp_start <= 1'b0;
        end
      end 
       LOAD_INP: begin
        if(load_inp_cnt == ARRAY_N + ARRAY_N + 1) begin
          load_acc_start <= 1'b1;
          state_ld_inp <= LOAD_INP_IDLE;
          load_inp_cnt <= 'b0;
        end
        else begin
          load_inp_cnt <= load_inp_cnt + 1'b1;
          load_inp_start <= 1'b0;
          load_acc_start <= 1'b0;
        end
       end
       default : state_ld_inp <= state_ld_inp;
  endcase
    end
  end

//==================================================================================
  reg  [ ACC_MEM_ADDR_WIDTH_W               -1 : 0 ]        acc_mem_read_ADDR_dly1;
  reg                                                       acc_mem_read_EN_dly1;
  reg  [ ACC_MEM_ADDR_WIDTH_W               -1 : 0 ]        acc_mem_read_ADDR_dly2;
  reg                                                       acc_mem_read_EN_dly2;
  reg  [ ACC_MEM_ADDR_WIDTH_W               -1 : 0 ]        acc_mem_read_ADDR_dly3;
  reg                                                       acc_mem_read_EN_dly3;     
//delay
  always @(posedge clk)
  begin
    acc_mem_read_ADDR_dly1 <= acc_read_addr;    
    acc_mem_read_EN_dly1 <= acc_read_req; 
    acc_mem_read_ADDR_dly2 <= acc_mem_read_ADDR_dly1;    
    acc_mem_read_EN_dly2 <= acc_mem_read_EN_dly1; 
    acc_mem_read_ADDR_dly3 <= acc_mem_read_ADDR_dly2;    
    acc_mem_read_EN_dly3 <= acc_mem_read_EN_dly2;     
  end

  assign acc_mem_write_ADDR = acc_mem_read_ADDR_dly3;
  assign acc_mem_write_EN = acc_mem_read_EN_dly3;
  assign  acc_mem_read_ADDR = acc_mem_read_ADDR_dly1;
  assign  acc_mem_read_EN = acc_mem_read_EN_dly1;
//==================================================================================
// Systolic Array - Begin
//==================================================================================
  wire  [ INP_MEM_DATA_WIDTH        -1 : 0 ]        inp_mem_DOUT_dly;
  // wire  [ WGT_MEM_DATA_WIDTH        -1 : 0 ]        pmem_read_data_dly;
  // wire  [ ARRAY_N                   -1 : 0 ]        wgt_en_dly;
  wire  [ WGT_MEM_DATA_WIDTH        -1 : 0 ]        wgt_mem_read_DOUT_dly;
  // wire  [ ARRAY_N                   -1 : 0 ]        wgt_path_en_dly;
  // wire  [ ARRAY_N                   -1 : 0 ]        wgt_mode_dly;
  wire  [ PE_OUT_DATA_WIDTH         -1 : 0 ]        systolic_out;
  wire  [ PE_OUT_DATA_WIDTH         -1 : 0 ]        systolic_out_dly;

  mem_data_sync #(
    .DATA_WIDTH                       ( INP_DATA_WIDTH                ),
    .ARRAY                            ( ARRAY_M                       )
  ) inp_sync (
    .clk                              ( clk                           ),  
    .data_in                          ( inp_mem_read_DOUT             ),  
    .data_out                         ( inp_mem_DOUT_dly         )
    );

  // mem_data_sync #(
  //   .DATA_WIDTH                       ( WGT_DATA_WIDTH                ),
  //   .ARRAY                            ( ARRAY_M                       )
  // ) p_sync (
  //   .clk                              ( clk                           ),  
  //   .data_in                          ( pmem_read_data                ),  
  //   .data_out                         ( pmem_read_data_dly            )
  //   );

  mem_data_sync #(
    .DATA_WIDTH                       ( WGT_DATA_WIDTH                ),
    .ARRAY                            ( ARRAY_M                       )
  ) wgt_sync (
    .clk                              ( clk                           ),  
    .data_in                          ( wgt_mem_read_DOUT             ),  
    .data_out                         ( wgt_mem_read_DOUT_dly         )
    );

  mem_data_sync_out #(
    .DATA_WIDTH                       ( PE_OUT_WIDTH                  ),
    .ARRAY                            ( ARRAY_M                       )
  ) acc_sync (
    .clk                              ( clk                           ),  
    .data_in                          ( systolic_out                  ),  
    .data_out                         ( systolic_out_dly              )
    );

//==================================================================================
// Systolic Array - Begin
//==================================================================================
  wire  [ ARRAY_N                        -1 : 0 ]        b_en;
  wire  [ ARRAY_N                        -1 : 0 ]        b_path_en;  

  assign b_en = b_en_reg;
  assign b_path_en = b_path_en_reg;

// TODO: Add groups
  systolic_array #(
    .ARRAY_M                          ( ARRAY_M                       ),
    .ARRAY_N                          ( ARRAY_N                       ),
    .INP_DATA_WIDTH                   ( INP_DATA_WIDTH                ),
    .WGT_DATA_WIDTH                   ( WGT_DATA_WIDTH                )
  ) systolic_array (
    .clk                              ( clk                           ),  
    .a                                ( inp_mem_DOUT_dly         ),  
    .b                                ( wgt_mem_read_DOUT_dly         ),  
    .b_en                             ( b_en                          ),  
    .b_path_en                        ( b_path_en                     ),   
    .systolic_out                     ( systolic_out                  )
    );

genvar p;
generate
for (p=0; p<ARRAY_M; p=p+1)
begin: ADD
  wire signed [ ACC_DATA_WIDTH                 -1 : 0 ]        acc_in;  
  reg  signed [ ACC_DATA_WIDTH                 -1 : 0 ]        acc_out; 
  wire signed [ PE_OUT_WIDTH              -1 : 0 ]        acc_systolic; 

  assign acc_systolic = systolic_out_dly[p*PE_OUT_WIDTH+:PE_OUT_WIDTH];
  assign acc_in = acc_mem_read_DOUT[p*ACC_DATA_WIDTH+:ACC_DATA_WIDTH];

  always @(posedge clk)
  begin
    if(reset_n_reg)
      acc_out <= 'd0; 
    else
      acc_out <= acc_in + acc_systolic;
  end
  assign acc_mem_write_DIN[p*ACC_DATA_WIDTH+:ACC_DATA_WIDTH] = acc_out;
end
endgenerate

//=========================================
// Systolic Array - End
//=========================================

endmodule
