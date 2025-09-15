module id_stage(
    input wire clk,
    input wire rst,
    input wire [31:0] inst_D,
    input wire [31:0] pc_plus4_D,
    input wire reg_write_W,
    input wire [4:0] write_reg_W,
    input wire [31:0] result_W,
    output wire [4:0] rs_D,
    output wire [4:0] rt_D,
    output wire [4:0] rd_D,
    output wire [31:0] sign_imm_D,
    output wire [31:0] rd1_D,
    output wire [31:0] rd2_D,
    output wire [3:0] alu_ctrl_D,  
    output wire reg_write_D,
    output wire mem_to_reg_D,
    output wire mem_write_D,
    output wire branch_D,
    output wire alu_src_D,
    output wire reg_dst_D,
    output wire jump_D,
    output wire [5:0] op_D,
    output wire [5:0] funct_D
);


assign rs_D = inst_D[25:21];
assign rt_D = inst_D[20:16];
assign rd_D = inst_D[15:11];
wire [5:0] op = inst_D[31:26];
wire [5:0] funct = inst_D[5:0];
wire [15:0] imm = inst_D[15:0];
assign op_D = op;
assign funct_D = funct;

assign sign_imm_D = {{16{imm[15]}}, imm};

register_file regfile(
    .clk(clk),
    .rst(rst),
    .RegWrite(reg_write_W),
    .read_reg1(rs_D),
    .read_reg2(rt_D),
    .write_reg(write_reg_W),
    .write_data(result_W),
    .read_data1(rd1_D),
    .read_data2(rd2_D)
);

wire [1:0] alu_op;
control_unit ctrl_unit(
    .op(op),
    .funct(funct),
    .reg_write(reg_write_D),
    .mem_to_reg(mem_to_reg_D),
    .mem_write(mem_write_D),
    .branch(branch_D),
    .alu_src(alu_src_D),
    .reg_dst(reg_dst_D),
    .jump(jump_D),
    .alu_op(alu_op)
);

wire shift_v; 
alu_control alu_ctrl_unit(
    .ALUOp1(alu_op[1]),
    .ALUOp0(alu_op[0]),
    .funct(funct),
    .opcode(op),
    .ALUCtrl(alu_ctrl_D),
    .shift_v(shift_v)
);

endmodule