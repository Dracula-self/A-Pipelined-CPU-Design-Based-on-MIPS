module wb_stage(
    input wire [31:0] alu_out_W,
    input wire [31:0] read_data_W,
    input wire mem_to_reg_W,
    output wire [31:0] result_W
);

assign result_W = mem_to_reg_W ? read_data_W : alu_out_W;

endmodule