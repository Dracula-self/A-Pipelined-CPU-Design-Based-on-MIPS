module id_ex_reg(
    input wire clk,
    input wire rst,
    input wire flush_E,
    input wire stall_E,
    input wire [31:0] rd1_D,
    input wire [31:0] rd2_D,
    input wire [4:0] rs_D,
    input wire [4:0] rt_D,
    input wire [4:0] rd_D,
    input wire [31:0] sign_imm_D,
    input wire [31:0] pc_D,
    input wire [31:0] pc_plus4_D,
    input wire [3:0] alu_ctrl_D,
    input wire reg_write_D,
    input wire mem_to_reg_D,
    input wire mem_write_D,
    input wire branch_D,
    input wire alu_src_D,
    input wire reg_dst_D,
    output reg [31:0] rd1_E,
    output reg [31:0] rd2_E,
    output reg [4:0] rs_E,
    output reg [4:0] rt_E,
    output reg [4:0] rd_E,
    output reg [31:0] sign_imm_E,
    output reg [31:0] pc_E,
    output reg [31:0] pc_plus4_E,
    output reg [3:0] alu_ctrl_E,
    output reg reg_write_E,
    output reg mem_to_reg_E,
    output reg mem_write_E,
    output reg branch_E,
    output reg alu_src_E,
    output reg reg_dst_E
);

    always @(posedge clk) begin
        if (rst || flush_E) begin
            rd1_E <= 32'h0;
            rd2_E <= 32'h0;
            rs_E <= 5'h0;
            rt_E <= 5'h0;
            rd_E <= 5'h0;
            sign_imm_E <= 32'h0;
            pc_E <= 32'h0;
            pc_plus4_E <= 32'h0;
            alu_ctrl_E <= 4'h0;
            reg_write_E <= 1'b0;
            mem_to_reg_E <= 1'b0;
            mem_write_E <= 1'b0;
            branch_E <= 1'b0;
            alu_src_E <= 1'b0;
            reg_dst_E <= 1'b0;
        end
        else if (!stall_E) begin
            rd1_E <= rd1_D;
            rd2_E <= rd2_D;
            rs_E <= rs_D;
            rt_E <= rt_D;
            rd_E <= rd_D;
            sign_imm_E <= sign_imm_D;
            pc_E <= pc_D;
            pc_plus4_E <= pc_plus4_D;
            alu_ctrl_E <= alu_ctrl_D;
            reg_write_E <= reg_write_D;
            mem_to_reg_E <= mem_to_reg_D;
            mem_write_E <= mem_write_D;
            branch_E <= branch_D;
            alu_src_E <= alu_src_D;
            reg_dst_E <= reg_dst_D;
        end
    end

endmodule