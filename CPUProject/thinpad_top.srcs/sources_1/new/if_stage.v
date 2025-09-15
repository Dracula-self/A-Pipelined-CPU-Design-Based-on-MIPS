module if_stage(
    input wire clk,
    input wire rst,
    input wire stall_F,
    input wire pc_src_D,//分支控制信号
    input wire [31:0] pc_branch_D,//来自ID阶段的分支地址
    input wire jump_D,  //跳转控制信号
    input wire [31:0] jump_addr_D, //跳转目标地址
    output reg [31:0] pc_F,//当前PC值
    output wire [31:0] pc_plus4_F 
);

wire [31:0] pc_next;
wire [31:0] pc_plus4;
wire [31:0] pc_branch_or_plus4;
assign pc_plus4_F = pc_F + 32'd4;
//优先级：跳转 > 分支 > 顺序执行
assign pc_branch_or_plus4 = pc_src_D ? pc_branch_D : pc_plus4_F; 
assign pc_next = jump_D ? jump_addr_D : pc_branch_or_plus4;
//PC寄存器更新
always @(posedge clk) begin
    if (rst)
        pc_F <= 32'h80000000;  
    else if (!stall_F)
        pc_F <= pc_next;
    else 
        pc_F <= pc_F;
end

endmodule