module if_stage(
    input wire clk,
    input wire rst,
    input wire stall_F,
    input wire pc_src_D,//��֧�����ź�
    input wire [31:0] pc_branch_D,//����ID�׶εķ�֧��ַ
    input wire jump_D,  //��ת�����ź�
    input wire [31:0] jump_addr_D, //��תĿ���ַ
    output reg [31:0] pc_F,//��ǰPCֵ
    output wire [31:0] pc_plus4_F 
);

wire [31:0] pc_next;
wire [31:0] pc_plus4;
wire [31:0] pc_branch_or_plus4;
assign pc_plus4_F = pc_F + 32'd4;
//���ȼ�����ת > ��֧ > ˳��ִ��
assign pc_branch_or_plus4 = pc_src_D ? pc_branch_D : pc_plus4_F; 
assign pc_next = jump_D ? jump_addr_D : pc_branch_or_plus4;
//PC�Ĵ�������
always @(posedge clk) begin
    if (rst)
        pc_F <= 32'h80000000;  
    else if (!stall_F)
        pc_F <= pc_next;
    else 
        pc_F <= pc_F;
end

endmodule