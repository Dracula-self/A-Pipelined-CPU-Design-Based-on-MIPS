module ex_stage(
    input wire [31:0] rd1_E,
    input wire [31:0] rd2_E,
    input wire [31:0] sign_imm_E,
    input wire [31:0] pc_plus4_E,    
    input wire [4:0] rt_E,
    input wire [4:0] rd_E,
    input wire [3:0] alu_ctrl_E,
    input wire alu_src_E,
    input wire reg_dst_E,
    input wire [1:0] forward_AE,
    input wire [1:0] forward_BE,
    input wire [31:0] alu_out_M,
    input wire [31:0] result_W,
    output wire [31:0] alu_out_E,
    output wire [31:0] write_data_E,
    output wire [4:0] write_reg_E

);

    reg [31:0] src_a_E;
    wire [31:0] src_b_E;
    wire zero_internal;  //内部使用的zero

    always @(*) begin
        case(forward_AE)
            2'b00: src_a_E = rd1_E;
            2'b01: src_a_E = result_W;
            2'b10: src_a_E = alu_out_M;
            default: src_a_E = rd1_E;
        endcase
    end

    reg [31:0] src_b_mux;
    always @(*) begin
        case(forward_BE)
            2'b00: src_b_mux = rd2_E;
            2'b01: src_b_mux = result_W;
            2'b10: src_b_mux = alu_out_M;
            default: src_b_mux = rd2_E;
        endcase
    end

    assign src_b_E = alu_src_E ? sign_imm_E : src_b_mux;
    
    alu alu(
        .a(src_a_E),
        .b(src_b_E),
        .ALUCtrl(alu_ctrl_E),
        .shift_amount(5'd0),
        .result(alu_out_E),
        .zero(zero_internal)
    );

    assign write_reg_E = reg_dst_E ? rd_E : rt_E;

    assign write_data_E = src_b_mux;

    // wire equal_E = (src_a_E == src_b_mux);
    // assign branch_result_E = (is_beq_E & equal_E) | (is_bne_E & ~equal_E);
    // always @(*) begin
    //     pc_branch_E = pc_plus4_E + {sign_imm_E[29:0], 2'b00};
    // end

endmodule