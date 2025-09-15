module hazard_unit(
    //数据冒险检测输入
    input wire [4:0] rs_D, rt_D,   //ID阶段的源寄存器
    input wire [4:0] rs_E, rt_E,           //EX阶段的源寄存器
    input wire [4:0] write_reg_E,   //EX阶段的目标寄存器
    input wire [4:0] write_reg_M,          //MEM阶段的目标寄存器
    input wire [4:0] write_reg_W,      //WB阶段的目标寄存器
    input wire reg_write_E,       //EX阶段的寄存器写使能
    input wire reg_write_M,                //MEM阶段的寄存器写使能
    input wire reg_write_W,      //WB阶段的寄存器写使能
    input wire mem_to_reg_E,               //EX阶段的load信号
    input wire mem_to_reg_M,               //MEM阶段的load信号
    input wire branch_D,         //ID阶段的分支信号
    input wire jump_D,                     //ID阶段的跳转信号
    input wire pc_src_D,                   //分支跳转信号
    // 添加SW-LW前递相关信号
    input wire mem_write_M, //MEM阶段的内存写使能
    input wire mem_read_E,                 //EX阶段的内存读使能
    input wire [31:0] alu_out_M,   //MEM阶段的内存地址
    input wire [31:0] alu_out_E,          //EX阶段的内存地址
    input wire [31:0] write_data_M,       //MEM阶段的写数据
    output reg [1:0] forward_AE,   //ALU端口A的前递控制
    output reg [1:0] forward_BE,           //ALU端口B的前递控制
    output reg stall_F,     //IF阶段停顿
    output reg stall_D,    //ID阶段停顿
    output reg stall_E,
    output reg flush_D,      //ID阶段冲刷
    output reg flush_E,      //EX阶段冲刷
    output wire sw_to_lw_forward,   //SW-LW前递使能
    output wire [31:0] forward_data   //SW-LW前递数据
);


// SW-LW冒险检测和前递
wire sw_lw_hazard = mem_write_M && mem_read_E && 
                    (alu_out_M == alu_out_E) && 
                    (alu_out_M != 32'h0);

assign sw_to_lw_forward = sw_lw_hazard;
assign forward_data = write_data_M;

    // 前递逻辑
    always @(*) begin
        // 默认值：不前递
        forward_AE = 2'b00;
        forward_BE = 2'b00;

        // ALU端口A的前递逻辑
        if (reg_write_M && (write_reg_M != 5'b0) && (write_reg_M == rs_E))
            forward_AE = 2'b10;    // 从MEM阶段前递
        else if (reg_write_W && (write_reg_W != 5'b0) && (write_reg_W == rs_E))
            forward_AE = 2'b01;    // 从WB阶段前递

        // ALU端口B的前递逻辑
        if (reg_write_M && (write_reg_M != 5'b0) && (write_reg_M == rt_E))
            forward_BE = 2'b10;    // 从MEM阶段前递
        else if (reg_write_W && (write_reg_W != 5'b0) && (write_reg_W == rt_E))
            forward_BE = 2'b01;    // 从WB阶段前递
    end


wire data_hazard = mem_to_reg_E && 
                   ((write_reg_E == rs_D) || (write_reg_E == rt_D));

//wire load_use_hazard = mem_to_reg_E && 
//                       ((rt_E == rs_D) || (rt_E == rt_D));  
wire load_use_hazard = mem_to_reg_E && 
                       (write_reg_E != 5'b0) &&
                       ((write_reg_E == rs_D) || (write_reg_E == rt_D));  

wire lw_stall = data_hazard || load_use_hazard;
 wire branch_stall = branch_D &&
                   reg_write_E &&
                   (write_reg_E != 5'b0) &&
                   ((write_reg_E == rs_D) || (write_reg_E == rt_D)) &&
                   mem_to_reg_E;  // 只有LW指令才需要阻塞分支
always @(*) begin
    // 默认值
    stall_F = 1'b0;
    stall_D = 1'b0;
    stall_E = 1'b0;
    flush_D = 1'b0;
    flush_E = 1'b0;
    
    // SW-LW冒险 - 最高优先级
    if (sw_lw_hazard) begin
        stall_F = 1'b1;
        stall_D = 1'b1;
    end
    // 普通Load-Use冒险处理
    else if (lw_stall) begin
        stall_F = 1'b1;    
        stall_D = 1'b1;    
    end
    // 分支-LW冒险
    else if (branch_stall) begin
        stall_F = 1'b1;    
        stall_D = 1'b1;    
    end
    // 分支跳转处理 - 较低优先级
    else if ((branch_D && pc_src_D) || jump_D) begin
        flush_D = 1'b1;    
        flush_E = 1'b1;    
    end
end


















//always @(*) begin
//    stall_F = 1'b0;
//    stall_D = 1'b0;
//    stall_E = 1'b0;
//    flush_D = 1'b0;
//    flush_E = 1'b0;
//    if (branch_stall) begin
//        stall_F = 1'b1;    // 暂停取指
//        stall_D = 1'b1;    // 保持分支指s令在ID
//        //stall_E = 1'b1;    // 等待比较结果
//    end else
//    // SW-LW冒险处理（最高优先级）
//    if (sw_lw_hazard) begin
//        stall_F = 1'b1;
//        stall_D = 1'b1;
//        //stall_E = 1'b1;
//    end
//    // Load-Use冒险处理
//    else if (lw_stall) begin
//        stall_F = 1'b1;    
//        stall_D = 1'b1;    
//        //flush_E = 1'b1;
//    end
//    // 分支冒险处理（只有在没有其他冒险时才处理）
//    else if (branch_D && pc_src_D || jump_D) begin
//        flush_D = 1'b1;    
//        flush_E = 1'b1;    
//    end
//end

endmodule