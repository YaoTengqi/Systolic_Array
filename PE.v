module PE #(
    parameter integer INP_DATA_WIDTH = 8,//INP位宽
    parameter integer WGT_DATA_WIDTH = 8,//WGT位宽
    parameter integer MULT_OUT_WIDTH = INP_DATA_WIDTH + WGT_DATA_WIDTH,//PE中存储INP*WGT乘积的位宽
    parameter integer PE_OUT_WIDTH = INP_DATA_WIDTH + WGT_DATA_WIDTH + $clog2(ARRAY_N),//PE输出位宽
) (
    input wire clk,
    input wire [INP_DATA_WIDTH - 1 : 0] a_in,
    output wire [INP_DATA_WIDTH - 1 : 0] a_out,

    input wire  b_en_in,
    output wire  b_en_out,
    input wire  b_path_en_in,
    output wire  b_path_en_out,
    input wire [WGT_DATA_WIDTH - 1 : 0] b_path_in,
    output wire [WGT_DATA_WIDTH - 1 : 0] b_path_out,

    input wire signed [PE_OUT_WIDTH - 1 : 0] c_in;
    output wire signed [PE_OUT_WIDTH - 1 : 0] c_out;
);

    reg signed [INP_DATA_WIDTH - 1 : 0] a_reg;
    reg signed [WGT_DATA_WIDTH - 1 : 0] b_reg;
    reg signed [WGT_DATA_WIDTH - 1 : 0] b_path_reg;
    reg b_en_reg;
    reg b_path_en_reg;

    reg signed [PE_OUT_WIDTH - 1 : 0]   out_mult_reg;   //inp * wgt结果存储的寄存器
    reg signed [PE_OUT_WIDTH - 1 : 0]   out_add_reg;   //累加结果寄存器 


    assign a_out = a_reg;  
    assign b_path_out = b_path_reg;
    assign b_en_out = b_en_reg;
    assign b_path_en_out = b_path_en_reg;
    assign c_out = out_add_reg;

    //数据流动
    always @(posedge clk) begin
        a_reg <= a_in;
        b_en_reg <= b_en_in;
        b_path_en_reg <= b_path_en_in;
    end

    //wgt数据纵向流动到临时寄存器b_path_reg
    always @(posedge clk) begin
        if(b_path_en_reg) begin
            b_path_reg <= b_path_in;
        end
        else begin
            b_path_reg <= b_path_reg;
        end
    end

    //wgt数据从临时寄存器b_path_reg流动到正常寄存器b_reg
    always @(posedge clk) begin
        if(b_en_reg) begin
            b_reg <= b_path_reg;
        end
        else begin
            b_reg <= b_reg;
        end
    end

    //PE中的计算单元
    always @(posedge clk) begin
        out_mult_reg <= a_reg * b_reg;
        out_add_reg <= out_mult_reg + c_in;
    end
endmodule