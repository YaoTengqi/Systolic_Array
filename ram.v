module ram # (
    parameter integer DATA_WIDTH = 10,
    parameter integer ADDR_WIDTH = 12,
    parameter integer OUTPUT_REG = 0
)   (
    input wire clk,
    input wire reset_n,

    input wire read_req,    //读请求
    input wire  [ADDR_WIDTH - 1 : 0] read_address, //读写地址
    output wire  [DATA_WIDTH - 1 : 0]   read_data,  //读出数据

    input wire write_req,    //写请求
    input wire [ADDR_WIDTH - 1 : 0] write_address,  //写入地址
    input wire  [DATA_WIDTH - 1 : 0]   write_data,  //写入数据
);

    reg [DATA_WIDTH - 1 : 0]    mem [0 : (1 << ADDR_WIDTH) - 1];

    //  写数据
    always @(posedge clk) begin: RAM_WRITE
        if(write_req) begin
            mem[write_address] <= write_data;
        end
    end

    //  读数据
    generate
        if(OUTPUT_REG == 0) //输出无寄存器
        begin
            assign  read_data = mem[read_address];
        end
        else begin  //输出为寄存器
            reg [DATA_WIDTH - 1: 0] read_data_reg;
            always @(posedge clk) begin
                if(!reset_n) begin  //初始化
                    read_data_reg <= 0;
                end
                else if(write_req)  begin
                    read_data_reg <= mem[read_address];
                end
            end
            assign read_data = read_data_reg;
        end
    endgenerate
endmodule