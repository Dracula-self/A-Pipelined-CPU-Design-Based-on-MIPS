`timescale 1ns / 1ps
module mips_pipeline_cpu(
    input wire clk,
    input wire rst,
    output wire [31:0] inst_sram_addr,
    input wire [31:0] inst_sram_rdata,
    output wire inst_sram_en,
    output wire [31:0] data_sram_addr,
    input wire [31:0] data_sram_rdata,
    output wire [31:0] data_sram_wdata,
    output wire [3:0] data_sram_wen,
    output wire data_sram_en
);

wire stall_F, stall_D, stall_E, stall_M, stall_W;
wire flush_F, flush_D, flush_E, flush_M, flush_W;

//IF stage signals
wire [31:0] pc_F;
wire [31:0] pc_plus4_F;
wire [31:0] inst_F;
wire [31:0] pc_M;       
wire [31:0] pc_W;        


wire [31:0] pc_D;
wire [31:0] inst_D;
wire [31:0] pc_plus4_D;
wire [4:0] rs_D, rt_D, rd_D;
wire [5:0] op_D, funct_D;
wire [31:0] sign_imm_D;
wire [31:0] zero_imm_D;
wire [31:0] rd1_D, rd2_D;

//EX
wire [31:0] pc_E;
wire [31:0] rd1_E, rd2_E;
wire [4:0] rs_E, rt_E, rd_E;
wire [31:0] sign_imm_E;
wire [31:0] alu_out_E;
wire [31:0] write_data_E;
wire [4:0] write_reg_E;
wire zero_E; 

//MEM 
wire [31:0] alu_out_M;
wire [31:0] write_data_M;
wire [4:0] write_reg_M;
wire [31:0] read_data_M;

//WB
wire [31:0] alu_out_W;
wire [31:0] read_data_W;
wire [4:0] write_reg_W;
wire [31:0] result_W;


wire [3:0] alu_ctrl_D, alu_ctrl_E; 
wire reg_write_D, reg_write_E, reg_write_M, reg_write_W;
wire mem_to_reg_D, mem_to_reg_E, mem_to_reg_M, mem_to_reg_W;
wire mem_write_D, mem_write_E, mem_write_M;
wire branch_D, branch_E;
wire alu_src_D, alu_src_E;
wire reg_dst_D, reg_dst_E;
wire jump_D;

//分支和跳转相关信号
wire pc_src_D;//分支跳转控制信号
wire [31:0] pc_branch_D; //分支目标地址
wire [31:0] jump_addr_D;//跳转目标地址
wire pc_branch_E;
//计算分支目标地址
//assign pc_branch_D = pc_plus4_D + (sign_imm_D << 2); 
assign jump_addr_D = {pc_plus4_D[31:28], inst_D[25:0], 2'b00};  //J型指令绝对寻址
wire branch_cond;  //分支条件满足信号
wire zero_D;      
//指令类型判断
wire is_beq = (op_D == 6'b000100);  
wire is_bne = (op_D == 6'b000101);  
assign pc_branch_D = pc_plus4_D + (sign_imm_D << 2);
//wire branch_equal = (rd1_D == rd2_D);
//分支比较需要前递！
wire [31:0] branch_src1_D, branch_src2_D;
//操作数1前递
assign branch_src1_D = (reg_write_M && (write_reg_M != 5'b0) && (write_reg_M == rs_D)) ? 
                       (mem_to_reg_M ? read_data_M : alu_out_M) :
                       (reg_write_W && (write_reg_W != 5'b0) && (write_reg_W == rs_D)) ? 
                       result_W : rd1_D;

//操作数2前递  
assign branch_src2_D = (reg_write_M && (write_reg_M != 5'b0) && (write_reg_M == rt_D)) ? 
                       (mem_to_reg_M ? read_data_M : alu_out_M) :
                       (reg_write_W && (write_reg_W != 5'b0) && (write_reg_W == rt_D)) ? 
                       result_W : rd2_D;
//wire branch_equal = (branch_src1_D == branch_src2_D);
//assign pc_src_D = branch_D && ((is_beq && branch_equal) || (is_bne && !branch_equal));
wire branch_equal = (branch_src1_D == branch_src2_D);
assign pc_src_D = branch_D && ((is_beq && branch_equal) || (is_bne && !branch_equal));
//前递单元控制信号
wire [1:0] forward_AE;  //ALU操作数A的前递控制
wire [1:0] forward_BE;  //ALU操作数B的前递控制
assign op_D = inst_D[31:26];    
assign funct_D = inst_D[5:0];  
//清除和暂停控制信号的默认值
assign flush_F = 1'b0;          
assign flush_M = 1'b0;         
assign flush_W = 1'b0;       
assign stall_M = 1'b0;      
assign stall_W = 1'b0;        
//SW-LW前递相关信号
wire sw_to_lw_forward;           
wire [31:0] sw_lw_forward_data;  
wire mem_read_E;                 
//将LW的读使能信号连接
assign mem_read_E = mem_to_reg_E; //LW指令在EX阶段的读使能
reg [31:0] cycle_count; //周期计数器
always @(posedge clk) begin
    if (rst)
        cycle_count <= 32'd0;
    else
        cycle_count <= cycle_count + 1;
end


if_stage if_stage(
    .clk(clk),
    .rst(rst),
    .stall_F(stall_F),
    .pc_src_D(pc_src_D),
    .pc_branch_D(pc_branch_D),   
    .jump_D(jump_D),
    .jump_addr_D(jump_addr_D),
    .pc_F(pc_F),
    .pc_plus4_F(pc_plus4_F)
);

if_id_reg if_id_reg(
    .clk(clk),
    .rst(rst),
    .flush_D(flush_D),
    .stall_D(stall_D),
    .pc_F(pc_F),        
    .pc_plus4_F(pc_plus4_F),
    .inst_F(inst_sram_rdata),
    .pc_D(pc_D),         
    .pc_plus4_D(pc_plus4_D),
    .inst_D(inst_D)
);


id_stage id_stage(
    .clk(clk),
    .rst(rst),
    .inst_D(inst_D),
    .pc_plus4_D(pc_plus4_D),
    .reg_write_W(reg_write_W),
    .write_reg_W(write_reg_W),
    .result_W(result_W),
    .rs_D(rs_D),
    .rt_D(rt_D),
    .rd_D(rd_D),
    .sign_imm_D(sign_imm_D),
    .rd1_D(rd1_D),
    .rd2_D(rd2_D),
    .alu_ctrl_D(alu_ctrl_D),
    .reg_write_D(reg_write_D),
    .mem_to_reg_D(mem_to_reg_D),
    .mem_write_D(mem_write_D),
    .branch_D(branch_D),
    .alu_src_D(alu_src_D),
    .reg_dst_D(reg_dst_D),
    .jump_D(jump_D),
    .op_D(op_D),        
    .funct_D(funct_D)  
);


id_ex_reg id_ex_reg(
    .clk(clk),
    .rst(rst),
    .flush_E(flush_E),
    .stall_E(stall_E),
    .rd1_D(rd1_D),
    .rd2_D(rd2_D),
    .rs_D(rs_D),
    .rt_D(rt_D),
    .rd_D(rd_D),
    .sign_imm_D(sign_imm_D),
    .pc_D(pc_D),            
    .pc_plus4_D(pc_plus4_D),
    .alu_ctrl_D(alu_ctrl_D),
    .reg_write_D(reg_write_D),
    .mem_to_reg_D(mem_to_reg_D),
    .mem_write_D(mem_write_D),
    .branch_D(branch_D),
    .alu_src_D(alu_src_D),
    .reg_dst_D(reg_dst_D),
    .rd1_E(rd1_E),
    .rd2_E(rd2_E),
    .rs_E(rs_E),
    .rt_E(rt_E),
    .rd_E(rd_E),
    .sign_imm_E(sign_imm_E),
    .pc_E(pc_E),              
    .pc_plus4_E(pc_plus4_E),
    .alu_ctrl_E(alu_ctrl_E),
    .reg_write_E(reg_write_E),
    .mem_to_reg_E(mem_to_reg_E),
    .mem_write_E(mem_write_E),
    .branch_E(branch_E),
    .alu_src_E(alu_src_E),
    .reg_dst_E(reg_dst_E)
);


ex_stage ex_stage(
    .rd1_E(rd1_E),
    .rd2_E(rd2_E),
    .sign_imm_E(sign_imm_E),
    .pc_plus4_E(pc_plus4_E),
    .rt_E(rt_E),
    .rd_E(rd_E),
    .alu_ctrl_E(alu_ctrl_E),
    .alu_src_E(alu_src_E),
    .reg_dst_E(reg_dst_E),
    .forward_AE(forward_AE),
    .forward_BE(forward_BE),
    .alu_out_M(alu_out_M),
    .result_W(result_W),
    .alu_out_E(alu_out_E),
    .write_data_E(write_data_E),
    .write_reg_E(write_reg_E)
);


ex_mem_reg ex_mem_reg(
    .clk(clk),
    .rst(rst),
    .flush_M(flush_M),
    .alu_out_E(alu_out_E),
    .write_data_E(write_data_E),
    .write_reg_E(write_reg_E),
    .reg_write_E(reg_write_E),
    .mem_to_reg_E(mem_to_reg_E),
    .mem_write_E(mem_write_E),
    .pc_E(pc_E),             
    .pc_M(pc_M),            
    .alu_out_M(alu_out_M),
    .write_data_M(write_data_M),
    .write_reg_M(write_reg_M),
    .reg_write_M(reg_write_M),
    .mem_to_reg_M(mem_to_reg_M),
    .mem_write_M(mem_write_M)
);


mem_stage mem_stage_inst (
    .alu_out_M(alu_out_M),
    .write_data_M(write_data_M),
    .mem_write_M(mem_write_M),
    .data_sram_rdata(data_sram_rdata),
    .sw_to_lw_forward(sw_to_lw_forward),
    .sw_lw_forward_data(sw_lw_forward_data),
    .read_data_M(read_data_M)
);


mem_wb_reg mem_wb_reg(
    .clk(clk),
    .rst(rst),
    .flush_W(flush_W),
    .alu_out_M(alu_out_M),
    .read_data_M(read_data_M),
    .write_reg_M(write_reg_M),
    .reg_write_M(reg_write_M),
    .mem_to_reg_M(mem_to_reg_M),
    .pc_M(pc_M),             
    .pc_W(pc_W),            
    .alu_out_W(alu_out_W),
    .read_data_W(read_data_W),
    .write_reg_W(write_reg_W),
    .reg_write_W(reg_write_W),
    .mem_to_reg_W(mem_to_reg_W)
);


wb_stage wb_stage(
    .alu_out_W(alu_out_W),
    .read_data_W(read_data_W),
    .mem_to_reg_W(mem_to_reg_W),
    .result_W(result_W)
);


hazard_unit hazard_unit(
    .rs_D(rs_D),
    .rt_D(rt_D),
    .rs_E(rs_E),
    .rt_E(rt_E),
    .write_reg_E(write_reg_E),
    .write_reg_M(write_reg_M),
    .write_reg_W(write_reg_W),
    .reg_write_E(reg_write_E),
    .reg_write_M(reg_write_M),
    .reg_write_W(reg_write_W),
    .mem_to_reg_E(mem_to_reg_E),
    .mem_to_reg_M(mem_to_reg_M),
    .branch_D(branch_D),
    .jump_D(jump_D),
    .pc_src_D(pc_src_D),
    .forward_AE(forward_AE),
    .forward_BE(forward_BE),
    .stall_F(stall_F),
    .stall_D(stall_D),
    .stall_E(stall_E), 
    .flush_D(flush_D),
    .flush_E(flush_E),
    .mem_write_M(mem_write_M),
    .mem_read_E(mem_read_E),
    .alu_out_M(alu_out_M),
    .alu_out_E(alu_out_E),
    .write_data_M(write_data_M),
    .sw_to_lw_forward(sw_to_lw_forward),
    .forward_data(sw_lw_forward_data)
);


assign inst_sram_addr = pc_F;
assign inst_sram_en = 1'b1;
assign data_sram_addr = alu_out_M;
assign data_sram_wdata = write_data_M;
assign data_sram_wen = mem_write_M ? 4'b1111 : 4'b0000;
assign data_sram_en = mem_to_reg_M | mem_write_M;


endmodule