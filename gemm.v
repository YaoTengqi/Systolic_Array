module gemm #(
    parameter integer ARRAY_N = 8,
    parameter integer ARRAY_M = 8,
    
    parameter integer INPUT_DATA_WIDTH   =  8,
    parameter integer WGT_DATA_WIDTH   =  8,
    parameter integer ACC_DATA_WIDTH   =  32,

    parameter integer  INP_MEM_ADDR_WIDTH_W               = 12,
    parameter integer  WGT_MEM_ADDR_WIDTH_W               = 13,
    parameter integer  ACC_MEM_ADDR_WIDTH_W               = 12,

    parameter integer  PE_OUT_WIDTH = INP_DATA_WIDTH + WGT_DATA_WIDTH + $clog2(ARRAY_N),
    parameter integer  ARRAY_N_W = $clog2(ARRAY_N),

    parameter integer  INP_MEM_DATA_WIDTH = ARRAY_N * INP_DATA_WIDTH,
    parameter integer  WGT_MEM_DATA_WIDTH = ARRAY_N * WGT_DATA_WIDTH,
    parameter integer  ACC_MEM_DATA_WIDTH = ARRAY_N * ACC_DATA_WIDTH,
    parameter integer  PE_OUT_DATA_WIDTH = ARRAY_N * PE_OUT_WIDTH
) (
    input wire clk,
    input wire reset_n,

    output wire [INP_MEM_ADDR_WIDTH_W - 1 : 0]  inp_mem_read_ADDR,
    output wire inp_mem_read_EN,
    input wire [INP_MEM_ADDR_WIDTH_W - 1 : 0]  inp_mem_read_DOUT,
    output wire inp_mem_read_WE,

    output wire [WGT_MEM_ADDR_WIDTH_W - 1 : 0]  wgt_mem_read_ADDR,
    output wire wgt_mem_read_EN,
    input wire [WGT_MEM_ADDR_WIDTH_W - 1 : 0]  wgt_mem_read_DOUT,
    output wire wgt_mem_read_WE,

    output wire [ACC_MEM_ADDR_WIDTH_W - 1 : 0]  acc_mem_read_ADDR,
    output wire acc_mem_read_EN,
    input wire [ACC_MEM_ADDR_WIDTH_W - 1 : 0]  acc_mem_read_DOUT,
    output wire acc_mem_read_WE,

    output wire [ACC_MEM_ADDR_WIDTH_W - 1 : 0]  acc_mem_write_ADDR,
    output wire acc_mem_write_EN,
    output wire [ACC_MEM_ADDR_WIDTH_W - 1 : 0]  acc_mem_write_DOUT,
    output wire acc_mem_write_WE
);

    assign inp_mem_read_WE = 'b0;
    assign wgt_mem_read_WE = 'b0;
    assign acc_mem_read_WE = 'b0;
    assign acc_mem_write_WE = 1'b1;

    reg [ARRAY_N - 1 : 0] b_en_reg;
    reg [ARRAY_N - 1 : 0] b_path_en_reg;
    reg start;
    reg load_inp_run;
    reg load_wgt_run;
    reg load_acc_run;

    // step 1: 先加载wgt
    localparam  integer LOAD_WGT_IDLE = 0;
    localparam  integer LOAD_WGT = 1;

    reg[2 : 0]  state_load_wgt;
    always @(posedge clk) begin
        if(!reset_n)    begin
            state_load_wgt <= LOAD_WGT_IDLE;
            load_wgt_run <= 1'b0;
        end
        else begin
            case (state_load_wgt)
                LOAD_WGT_IDLE:  begin
                    if (start) begin    //产生start信号则开始加载wgt
                        state_load_wgt <= LOAD_WGT;
                        load_wgt_run <= 1'b1;
                    end
                    else begin
                        state_load_wgt <= LOAD_WGT_IDLE;
                        load_wgt_run <= 1'b0;
                    end
                    end 
                LOAD_WGT: begin
                    if(wgt_done) begin  //wgt_done如何确定？
                        state_load_wgt <= LOAD_WGT_IDLE;
                        load_wgt_run <= 1'b0;    
                    end
                    else begin
                        state_load_wgt <= LOAD_WGT;
                        load_wgt_run <= 1'b1;
                    end
                end
                default: state_load_wgt <= state_load_wgt;
            endcase
        end
    end


    // step 2: wgt加载时完成b_path_en的准备
    localparam  integer PATH_EN_IDLE = 0;
    localparam  integer PATH_EN = 1;

    reg [2 : 0] state_path_en;
    reg [ARRAY_N_W + 1 : 0] path_en_count;
    always @(posedge clk) begin
        if(!reset_n) begin
            state_path_en <= PATH_EN_IDLE;
        end
        else begin
            case (state_path_en)
                PATH_EN_IDLE:   begin
                    if (load_wgt_run) begin     //当wgt正在加载时
                        state_path_en <= PATH_EN;
                        path_en_count <= 1'b0;  //准备的path_en数量初始化
                        b_path_en_reg <= 1'b1;  //准备寄存器参数
                    end
                    else begin
                        state_path_en <= PATH_EN_IDLE;
                        path_en_count <= 1'b0;  
                        b_path_en_reg <= 1'b0;  
                    end
                end 

                PATH_EN:    begin
                    if(path_en_count == ARRAY_N - 1) begin  //加载满一列时
                        path_en_count <= 1'b0;  //path_en数量清零
                        b_path_en_reg <= 1'b0;
                        state_path_en <= PATH_EN_IDLE; 
                        load_inp_run <= 1'b1;   //通知inp可以开始加载了
                    end
                    else begin
                        path_en_count <= path_en_count + 1'b1;
                        b_path_en_reg <= (b_path_en_reg << 1) + 1'b1;   //寄存器的值设置为向右传1
                        state_path_en <= PATH_EN;
                        load_inp_run <= 1'b0;
                    end
                end
                default:    state_path_en <= state_path_en;
            endcase
        end
    end


     // step 3: b_path_en准备好后可以开始load inp
    localparam  integer LOAD_INP_IDLE = 0;
    localparam  integer LOAD_INP = 1;

    reg [2 : 0] state_load_inp;
    reg [ARRAY_N_W + 1 : 0] load_inp_count;

    always @(posedge clk) begin
        if(!reset_n) begin
            state_load_inp <= LOAD_INP_IDLE;
        end
        else begin
            case (state_load_inp)
                LOAD_INP_IDLE:  begin
                    if(load_inp_run) begin
                        state_load_inp <= LOAD_INP;
                        load_inp_count <= 1'b0;
                    end
                    else begin
                        state_load_inp <= LOAD_INP_IDLE;
                        load_inp_count <= 1'b0;
                    end
                end

                LOAD_INP:   begin
                    if(load_inp_count == ARRAY_M + ARRAY_N + 1)   begin     //当inp加载完一整块时
                        state_load_inp <= LOAD_INP_IDLE;
                        load_inp_count <= 1'b0;
                        load_acc_run <= 1'b1;
                    end
                    else begin
                        state_load_inp <= LOAD_INP;
                        load_inp_count <= load_inp_count + 1'b1;
                        load_inp_run <= 1'b0;
                        load_acc_run <= 1'b0;
                    end
                end 
                default: state_load_inp <= state_load_inp;
            endcase
        end
    end


    // step 4: load_inp进行完成后可以开始准备b_en信号
    localparam  integer B_EN_IDLE = 0;
    localparam  integer B_EN = 1;

    reg [2 : 0] state_b_en;
    reg [ARRAY_N_W + 1 : 0] b_en_count;
    always @(posedge clk) begin
        if(!reset_n) begin
            b_path_en <= B_EN_IDLE;
        end
        else begin
            case (state_b_en)
                B_EN_IDLE:   begin
                    if (load_inp_run) begin     //当inp正在加载时
                        state_b_en <= B_EN;
                        b_en_count <= 1'b0;  //准备的b_en数量初始化
                        b_en_reg <= 1'b1;  //准备寄存器参数
                    end
                    else begin
                        b_path_en <= B_EN_IDLE;
                        b_en_count <= 1'b0;  
                        b_en_reg <= 1'b0;  
                    end
                end 

                B_EN:    begin
                    if(b_en_count == ARRAY_N - 1) begin  //加载满一列时
                        b_en_count <= 1'b0;  //b_en数量清零
                        b_en_reg <= (b_en_reg << 1); 
                        b_path_en <= B_EN_IDLE; 
                    end
                    else begin
                        b_en_count <= b_en_count + 1'b1;
                        b_en_reg <= (b_en_reg << 1);   //寄存器的值设置为向右传1
                        b_path_en <= B_EN;
                    end
                end
                default:    b_path_en <= b_path_en;
            endcase
        end
    end

    // step 5: 准备好b_en信号后进行数据打拍
    wire [INP_MEM_DATA_WIDTH - 1: 0] sync_inp_data;
    wire [WGT_MEM_DATA_WIDTH - 1: 0] sync_wgt_data;
    wire [PE_OUT_DATA_WIDTH - 1: 0] systolic_out_data;
    wire [PE_OUT_DATA_WIDTH - 1: 0] sync_out_data;

    mem_data_sync # (
        .DATA_WIDTH (INP_DATA_WIDTH),
        .ARRAY (ARRAY_M)
    ) inp_sync(
        .clk (clk),
        .data_in (inp_mem_read_DOUT),
        .data_out (sync_inp_data)
    );

    mem_data_sync # (
        .DATA_WIDTH (WGT_DATA_WIDTH),
        .ARRAY (ARRAY_M)
    ) wgt_sync(
        .clk (clk),
        .data_in (wgt_mem_read_DOUT),
        .data_out (sync_wgt_data)
    );

    mem_data_sync_out # (
        .DATA_WIDTH (PE_OUT_WIDTH),
        .ARRAY (ARRAY_M)
    ) wgt_sync(
        .clk (clk),
        .data_in (systolic_out_data),
        .data_out (sync_out_data)
    );

    // systolic_array begin
        wire [ARRAY_N - 1: 0] b_en;
        wire [ARRAY_N - 1: 0] b_path_en;

        assign b_en = b_en_reg;
        assign b_path_en = b_path_en_reg;

        systolic_array #(
            .ARRAY_M (ARRAY_M),
            .ARRAY_N (ARRAY_N),
            .INP_DATA_WIDTH (INP_DATA_WIDTH),
            .WGT_DATA_WIDT (WGT_DATA_WIDT)
        ) systolic_array(
            .clk (clk),
            .inp(sync_inp_data),
            .wgt(sync_wgt_data),
            .b_en(b_en),
            .b_path_en(b_path_en),
            .systolic_out(systolic_out)
        );
    
endmodule