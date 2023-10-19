module systolic_array #(
    parameter integer ARRAY_M = 32,//PE的行数
    parameter integer ARRAY_N = 32,//PE的列数
    parameter integer INP_DATA_WIDTH = 8,//INP位宽
    parameter integer WGT_DATA_WIDTH = 8,//WGT位宽
    parameter integer MULT_OUT_WIDTH = INP_DATA_WIDTH + WGT_DATA_WIDTH,//PE中存储INP*WGT乘积的位宽
    parameter integer PE_OUT_WIDTH = INP_DATA_WIDTH + WGT_DATA_WIDTH + $clog2(ARRAY_N),//PE输出位宽
    parameter integer INP_MEM_DATA_WIDTH = ARRAY_N * INP_DATA_WIDTH,//inp_mem的位宽等于PE行数乘上每个PE接收的INP的位宽
    parameter integer WGT_MEM_DATA_WIDTH = ARRAY_M * WGT_DATA_WIDT,//inp_mem的位宽等于PE列数乘上每个PE接收的WGT的位宽
    parameter integer PE_OUT_DATA_WIDTH = ARRAY_N * PE_OUT_WIDTH,//输出位宽等于PE行(列)数乘上每个PE的位宽
) (
    input wire clk,
    input wire [INP_DATA_WIDTH - 1 : 0] inp,
    input wire [WGT_DATA_WIDTH - 1 : 0] wgt,
    input wire [ARRAY_N - 1 : 0] b_en,
    input wire [ARRAY_N - 1 : 0] b_path_en,
    output wire [PE_OUT_DATA_WIDTH - 1 : 0] systolic_out
);

genvar m,n//循环变量
generate
    for(m = 0; i < ARRAY_M; m = m + 1)
    begin: LOOP_INPUT_FORWARD
        for(n = 0; n < ARRAY_N; n = n + 1)
        begin: LOOP_OUTPUT_FORWARD

        wire [INP_DATA_WIDTH - 1 : 0]   a_in;
        wire [INP_DATA_WIDTH - 1 : 0]   a_out;

        wire    b_en_in;
        wire    b_en_out;
        wire [WGT_DATA_WIDTH - 1 : 0]   b_path_in;
        wire [WGT_DATA_WIDTH - 1 : 0]   b_path_out;
        wire    b_path_en_in;
        wire    b_path_en_out;

        wire [PE_OUT_DATA_WIDTH - 1 : 0]   c_in;
        wire [PE_OUT_DATA_WIDTH - 1 : 0]   c_out;

        if(m == 0)//从第0列开始     横向流动的数据
        begin
            assign a_in = inp[n * INP_DATA_WIDTH+:INP_DATA_WIDTH];
            assign b_en_in = b_en[m+:1];
            assign b_path_en_in = b_path_en_in[m+:1];
        end
        else
        begin
            assign a_in = LOOP_INPUT_FORWARD[m-1].LOOP_OUTPUT_FORWARD[n].a_out;
            assign b_en_in = LOOP_INPUT_FORWARD[m-1].LOOP_OUTPUT_FORWARD[n].b_en_out;
            assign b_path_en_in = LOOP_INPUT_FORWARD[m-1].LOOP_OUTPUT_FORWARD[n].b_path_en_out;
        end
        if(n == 0)//从第0行开始     纵向流动的数据
        begin
            assign c_in = 'd0;
            assign b_path_in = wgt[m * WGT_DATA_WIDT+:WGT_DATA_WIDT];

        end
        else
        begin
            assign c_in = LOOP_INPUT_FORWARD[m].LOOP_OUTPUT_FORWARD[n - 1].c_out;
            assign b_path_in = LOOP_INPUT_FORWARD[m].LOOP_OUTPUT_FORWARD[n-1].b_path_out;
        end

        PE #(
            .INP_DATA_WIDTH(INP_DATA_WIDTH),
            .WGT_DATA_WIDT(WGT_DATA_WIDTH),
            .MULT_OUT_WIDTH(MULT_OUT_WIDTH),
            .PE_OUT_WIDTH(PE_OUT_WIDTH)
        ) PE_inst(
            .clk(clk),
            .a_in(a_in),
            .a_out(a_out),
            .b_en_in(b_en_in),
            .b_en_out(b_en_out),
            .b_path_en_in(b_path_en_in),
            .b_path_en_out(b_path_en_out),
            .c_in(c_in),
            .c_out(c_out)
        );

        if(n == ARRAY_N - 1) begin
            assign systolic_out[m * PE_OUT_WIDTH+:PE_OUT_WIDTH] = c_out;
        end
        end
    end
endgenerate
endmodule