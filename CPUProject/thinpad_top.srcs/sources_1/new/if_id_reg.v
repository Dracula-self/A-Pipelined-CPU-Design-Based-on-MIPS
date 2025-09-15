module if_id_reg(
    input wire clk,
    input wire rst,
    input wire flush_D,
    input wire stall_D,
    input wire [31:0] pc_F,    
    input wire [31:0] pc_plus4_F,
    input wire [31:0] inst_F,
    output reg [31:0] pc_D,      
    output reg [31:0] pc_plus4_D,
    output reg [31:0] inst_D
);

//always @(posedge clk) begin
//    if (rst || flush_D) begin
//        pc_D <= 32'h0;          
//        pc_plus4_D <= 32'h0;
//        inst_D <= 32'h0;
//    end
//    else if (!stall_D) begin
//        pc_D <= pc_F;          
//        pc_plus4_D <= pc_plus4_F;
//        inst_D <= inst_F;
//    end
//    else begin
//        pc_D<=pc_D;
//        pc_plus4_D<=pc_plus4_D;
//        inst_D<=inst_D;
//    end
//end
always @(posedge clk) begin
    if (rst) begin 
        pc_D <= 32'h0;
        pc_plus4_D <= 32'h0;
        inst_D <= 32'h0;
    end
    else if (stall_D) begin  
        //保持原值
    end
    else if (flush_D) begin 
        pc_D <= 32'h0;
        pc_plus4_D <= 32'h0;
        inst_D <= 32'h0;
    end
    else begin
        pc_D <= pc_F;
        pc_plus4_D <= pc_plus4_F;
        inst_D <= inst_F;
    end
end
endmodule