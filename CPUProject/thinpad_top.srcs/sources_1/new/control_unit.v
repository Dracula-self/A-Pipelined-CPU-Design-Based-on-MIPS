`timescale 1ns / 1ps
module control_unit(
    input wire [5:0] op,         
    input wire [5:0] funct,     
    output reg reg_write,      
    output reg mem_to_reg,     
    output reg mem_write,     
    output reg branch,         
    output reg alu_src,        
    output reg reg_dst,       
    output reg jump,             
    output reg [1:0] alu_op    
);

always @(*) begin
    reg_write = 1'b0;
    mem_to_reg = 1'b0;
    mem_write = 1'b0;
    branch = 1'b0;
    alu_src = 1'b0;
    reg_dst = 1'b0;
    jump = 1'b0;
    alu_op = 2'b00;
    
    case(op)
        6'b000000: begin  //R型指令
            reg_dst = 1'b1;
            reg_write = 1'b1;
            alu_op = 2'b10;
        end
        6'b100011: begin  //lw
            alu_src = 1'b1;
            mem_to_reg = 1'b1;
            reg_write = 1'b1;
            alu_op = 2'b00;
        end
        6'b101011: begin  //sw
            alu_src = 1'b1;
            mem_write = 1'b1;
            alu_op = 2'b00;
        end
        6'b000100: begin  //beq
            branch = 1'b1;
            alu_op = 2'b01;
        end
        6'b000101: begin  //bne
            branch = 1'b1;
            alu_op = 2'b01;
        end
        6'b001000: begin  //addi
            alu_src = 1'b1;
            reg_write = 1'b1;
            alu_op = 2'b00;
        end
        6'b001001: begin  //addiu
            alu_src = 1'b1;
            reg_write = 1'b1;
            alu_op = 2'b00;
        end
        6'b001100: begin  //andi
            alu_src = 1'b1;
            reg_write = 1'b1;
            alu_op = 2'b11;
        end
        6'b001101: begin  //ori
            alu_src = 1'b1;
            reg_write = 1'b1;
            alu_op = 2'b11;
        end
        6'b001010: begin  //slti
            alu_src = 1'b1;
            reg_write = 1'b1;
            alu_op = 2'b11;
        end
        6'b000010: begin  //j
            jump = 1'b1;
        end
        6'b000011: begin  //jal
            jump = 1'b1;
            reg_write = 1'b1;
            //jal的特殊处理其他地方实现
        end
        6'b001111: begin  //lui
            alu_src = 1'b1;
            reg_write = 1'b1;
            alu_op = 2'b11;
        end
        default: begin
        end
    endcase
end

endmodule