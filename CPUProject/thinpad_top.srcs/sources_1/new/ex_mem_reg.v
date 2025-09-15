module ex_mem_reg(
    input wire clk,
    input wire rst,
    input wire flush_M,
    input wire [31:0] alu_out_E,
    input wire [31:0] write_data_E,
    input wire [4:0] write_reg_E,
    input wire reg_write_E,
    input wire mem_to_reg_E,
    input wire mem_write_E,
    input wire [31:0] pc_E,    
    output reg [31:0] pc_M,     
    output reg [31:0] alu_out_M,
    output reg [31:0] write_data_M,
    output reg [4:0] write_reg_M,
    output reg reg_write_M,
    output reg mem_to_reg_M,
    output reg mem_write_M

);

always @(posedge clk) begin
    if (rst || flush_M) begin
        pc_M <= 32'h0;          
        alu_out_M <= 32'h0;
        write_data_M <= 32'h0;
        write_reg_M <= 5'h0;
        reg_write_M <= 1'b0;
        mem_to_reg_M <= 1'b0;
        mem_write_M <= 1'b0;
    end
    else begin
        pc_M <= pc_E;            
        alu_out_M <= alu_out_E;
        write_data_M <= write_data_E;
        write_reg_M <= write_reg_E;
        reg_write_M <= reg_write_E;
        mem_to_reg_M <= mem_to_reg_E;
        mem_write_M <= mem_write_E;
    end
end



endmodule