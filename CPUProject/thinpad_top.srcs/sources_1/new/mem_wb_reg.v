module mem_wb_reg(
    input wire clk,
    input wire rst,
    input wire flush_W,
    input wire [31:0] alu_out_M,
    input wire [31:0] read_data_M,
    input wire [4:0] write_reg_M,
    //¿ØÖÆ
    input wire reg_write_M,
    input wire mem_to_reg_M,
    input wire [31:0] pc_M,        
    output reg [31:0] pc_W,       

    output reg [31:0] alu_out_W,
    output reg [31:0] read_data_W,
    output reg [4:0] write_reg_W,

    output reg reg_write_W,
    output reg mem_to_reg_W
    
);

always @(posedge clk) begin
    if (rst || flush_W) begin
        pc_W <= 32'h0;             
        alu_out_W <= 32'h0;
        read_data_W <= 32'h0;
        write_reg_W <= 5'h0;
        reg_write_W <= 1'b0;
        mem_to_reg_W <= 1'b0;
    end
    else begin
        pc_W <= pc_M; 
        alu_out_W <= alu_out_M;
        read_data_W <= read_data_M;
        write_reg_W <= write_reg_M;
        reg_write_W <= reg_write_M;
        mem_to_reg_W <= mem_to_reg_M;
    end
end

endmodule