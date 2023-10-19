`timescale 1ns/1ps
module address_offset_wgt #(
  // Internal Parameters
  parameter integer  ARRAY_N                          = 16,
  parameter integer  UOP_DATA_WIDTH                   = 8,
  parameter integer  MEM_ADDR_WIDTH_W                 = 48,
  parameter integer  UOP_MEM_ADDR_WIDTH_W             = 48,

  parameter integer  INP_NUM_W                        = 10,

  parameter integer  INSN_UOP_W                       = 16,
  parameter integer  INSN_ITER_W                      = 16,
  parameter integer  INSN_FAC_W                       = 16,

  parameter integer  CNT_W                            = 8
) ( 
  input  wire                                          clk,
  input  wire                                          reset_n,

  input  wire                                          start,
  output wire                                          insn_done,
  output wire                                          load_done,

  output wire  [ MEM_ADDR_WIDTH_W    -1 : 0  ]         mem_read_addr,
  output wire                                          mem_read_req,
  input  wire  [ INP_NUM_W           -1 : 0  ]         inp_num,
  input  wire  [ INSN_UOP_W          -1 : 0  ]         uop_bgn,
  input  wire  [ INSN_UOP_W             : 0  ]         uop_end,    
  input  wire  [ INSN_ITER_W         -1 : 0  ]         iter_in,
  input  wire  [ INSN_ITER_W         -1 : 0  ]         iter_out,
  input  wire  [ INSN_FAC_W          -1 : 0  ]         factor_in,
  input  wire  [ INSN_FAC_W          -1 : 0  ]         factor_out,

  output wire  [ UOP_MEM_ADDR_WIDTH_W    -1 : 0  ]     uop_read_addr,
  output wire                                          uop_read_req,
  input  wire  [ UOP_DATA_WIDTH      -1 : 0  ]         uop_read_data  
);

//=============================================================
// Wires/Regs
//=============================================================
  reg  [ CNT_W                        -1 : 0 ]        iter_in_cnt;
  reg  [ CNT_W                        -1 : 0 ]        iter_out_cnt;
  reg  [ CNT_W                        -1 : 0 ]        uop_cnt;
  reg  [ CNT_W                        -1 : 0 ]        cnt;
  reg  [ MEM_ADDR_WIDTH_W             -1 : 0 ]        addr_offset;
  reg  [ MEM_ADDR_WIDTH_W             -1 : 0 ]        addr_iter_out;
  reg  [ MEM_ADDR_WIDTH_W             -1 : 0 ]        addr_temp;
  reg  [ UOP_DATA_WIDTH               -1 : 0 ]        uop_data;
  reg                                                 en;
  wire                                                uop_done;

  wire                                                iter_in_done;
  wire                                                iter_out_done;
  wire                                                ld_done;

  reg                                                 iter_in_done_dly1;
  reg                                                 uop_done_dly1;
  reg                                                 mem_read_req_reg;  

  // reg  [ UOP_MEM_ADDR_WIDTH_W    -1 : 0  ]            uop_offset;
//=============================================================
//Output mem_read_addr for the last two cycles of start
//=============================================================
  assign uop_read_req = start;
  assign uop_read_addr = uop_bgn + uop_cnt;
  assign mem_read_req = mem_read_req_reg;
  
  assign mem_read_addr = addr_offset + uop_data;
  
  assign ld_done = (cnt == ARRAY_N);
  // assign uop_done = (uop_cnt == (uop_end - uop_bgn + 1'b1));
  assign uop_done = (uop_cnt == (uop_end - uop_bgn));//edit by sy 0923
  
  // assign iter_in_done = (iter_in_cnt == iter_in + 1'b1);
  // assign iter_out_done = (iter_out_cnt == iter_out + 1'b1);
  assign iter_in_done = (iter_in_cnt == iter_in);//edit by sy 0923
  assign iter_out_done = (iter_out_cnt == iter_out);//edit by sy 0923

  assign insn_done = iter_out_done;
  assign load_done = ld_done;
  
//compute mem_read_addr  
  localparam integer  IDLE_ADDR                   = 0;
  localparam integer  GEN_ADDR                    = 1;
  
  reg   [ 1                      : 0  ]         state_addr;
  
  always @(posedge clk)
  begin
  if(!reset_n) begin
    state_addr <= IDLE_ADDR;
    end
    else begin
    case (state_addr)
      IDLE_ADDR: begin
        if (start) begin
          addr_iter_out <= factor_out;
          addr_temp <= 'b0;
          state_addr <= GEN_ADDR;
          end
        else begin
          state_addr <= IDLE_ADDR;
          addr_iter_out <= factor_out;
          addr_temp <= 'b0;
        end
      end 
      GEN_ADDR: begin
        if(insn_done) begin
          addr_iter_out <= factor_out;
          addr_temp <= 'b0;
          state_addr <= IDLE_ADDR;
        end
        else if(iter_in_done_dly1) begin
          addr_iter_out <= addr_iter_out + factor_out;
          addr_temp <= addr_iter_out;
          addr_offset <= addr_iter_out;
        end
        else if(uop_done_dly1) begin
          addr_temp <= addr_temp + factor_in;
          addr_offset <= addr_temp;    
        end
        else begin
          addr_offset <= addr_temp + ARRAY_N -1 - cnt;    
        end
        end        
  endcase
    end
  end
  
  always @(posedge clk)
    begin
      uop_data <= uop_read_data;
    end
  
//cnt ++
  always @(posedge clk)
  begin
    if(!reset_n) begin
      cnt <= 'b0;
    end
    else if(ld_done) begin
      cnt <= 'b0;
    end
    else if (en) begin
      cnt <= cnt + 1'b1;
    end
    end
  
//uop_cnt ++
  always @(posedge clk)
  begin
    if(!reset_n) begin
      uop_cnt <= 'b0;
    end
    else if(uop_done) begin
      uop_cnt <= 'b0;
    end
    else if (ld_done) begin
      uop_cnt <= uop_cnt + inp_num;
    end
  end
  
//iter_in_cnt ++ when uop_cnt loop done
  always @(posedge clk)
  begin
    if(!reset_n) begin
      iter_in_cnt <= 'b0;
    end    
    if(iter_in_done) begin
      iter_in_cnt <= 'b0;
    end
    else if(uop_done)begin
      iter_in_cnt <= iter_in_cnt + 1'b1;
    end
  end
  
//iter_out_cnt ++ when iter_in_cnt loop done
  always @(posedge clk)
  begin
    if(!reset_n) begin
      iter_out_cnt <= 'b0;
    end    
    else if (insn_done)
      iter_out_cnt <= 1'b0;
    else if(iter_in_done) 
      iter_out_cnt <= iter_out_cnt + 1'b1;
  end
  
  localparam integer  IDLE                 = 0;
  localparam integer  START                   = 1;
  
  reg   [ 1                      : 0  ]         state;
  // reg   [ 3                      : 0  ]         dely_cnt;
  
  always @(posedge clk)
  begin
  if(!reset_n) begin
    state <= IDLE;
    end
    else begin
    case (state)
      IDLE: begin
        if (start) begin
          state <= START;
          mem_read_req_reg <= 1'b0;
          en <= 1'b1;
          end
        else begin
          state <= IDLE;
          en <= 1'b0;
          mem_read_req_reg <= 1'b0;
        end
      end 
      START: begin
        if(ld_done) begin
          en <= 1'b0;
          mem_read_req_reg <= 1'b0;
          state <= IDLE;
          end
        else begin
          en <= 1'b1;
          mem_read_req_reg <= 1'b1;
          state <= START;          
        end
        end        
  endcase
    end
  end
  
//delay
  always @(posedge clk)
  begin
    uop_done_dly1 <= uop_done;   
    iter_in_done_dly1 <= iter_in_done;   
  end
  endmodule
