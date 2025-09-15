module hazard_unit(
    //����ð�ռ������
    input wire [4:0] rs_D, rt_D,   //ID�׶ε�Դ�Ĵ���
    input wire [4:0] rs_E, rt_E,           //EX�׶ε�Դ�Ĵ���
    input wire [4:0] write_reg_E,   //EX�׶ε�Ŀ��Ĵ���
    input wire [4:0] write_reg_M,          //MEM�׶ε�Ŀ��Ĵ���
    input wire [4:0] write_reg_W,      //WB�׶ε�Ŀ��Ĵ���
    input wire reg_write_E,       //EX�׶εļĴ���дʹ��
    input wire reg_write_M,                //MEM�׶εļĴ���дʹ��
    input wire reg_write_W,      //WB�׶εļĴ���дʹ��
    input wire mem_to_reg_E,               //EX�׶ε�load�ź�
    input wire mem_to_reg_M,               //MEM�׶ε�load�ź�
    input wire branch_D,         //ID�׶εķ�֧�ź�
    input wire jump_D,                     //ID�׶ε���ת�ź�
    input wire pc_src_D,                   //��֧��ת�ź�
    // ���SW-LWǰ������ź�
    input wire mem_write_M, //MEM�׶ε��ڴ�дʹ��
    input wire mem_read_E,                 //EX�׶ε��ڴ��ʹ��
    input wire [31:0] alu_out_M,   //MEM�׶ε��ڴ��ַ
    input wire [31:0] alu_out_E,          //EX�׶ε��ڴ��ַ
    input wire [31:0] write_data_M,       //MEM�׶ε�д����
    output reg [1:0] forward_AE,   //ALU�˿�A��ǰ�ݿ���
    output reg [1:0] forward_BE,           //ALU�˿�B��ǰ�ݿ���
    output reg stall_F,     //IF�׶�ͣ��
    output reg stall_D,    //ID�׶�ͣ��
    output reg stall_E,
    output reg flush_D,      //ID�׶γ�ˢ
    output reg flush_E,      //EX�׶γ�ˢ
    output wire sw_to_lw_forward,   //SW-LWǰ��ʹ��
    output wire [31:0] forward_data   //SW-LWǰ������
);


// SW-LWð�ռ���ǰ��
wire sw_lw_hazard = mem_write_M && mem_read_E && 
                    (alu_out_M == alu_out_E) && 
                    (alu_out_M != 32'h0);

assign sw_to_lw_forward = sw_lw_hazard;
assign forward_data = write_data_M;

    // ǰ���߼�
    always @(*) begin
        // Ĭ��ֵ����ǰ��
        forward_AE = 2'b00;
        forward_BE = 2'b00;

        // ALU�˿�A��ǰ���߼�
        if (reg_write_M && (write_reg_M != 5'b0) && (write_reg_M == rs_E))
            forward_AE = 2'b10;    // ��MEM�׶�ǰ��
        else if (reg_write_W && (write_reg_W != 5'b0) && (write_reg_W == rs_E))
            forward_AE = 2'b01;    // ��WB�׶�ǰ��

        // ALU�˿�B��ǰ���߼�
        if (reg_write_M && (write_reg_M != 5'b0) && (write_reg_M == rt_E))
            forward_BE = 2'b10;    // ��MEM�׶�ǰ��
        else if (reg_write_W && (write_reg_W != 5'b0) && (write_reg_W == rt_E))
            forward_BE = 2'b01;    // ��WB�׶�ǰ��
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
                   mem_to_reg_E;  // ֻ��LWָ�����Ҫ������֧
always @(*) begin
    // Ĭ��ֵ
    stall_F = 1'b0;
    stall_D = 1'b0;
    stall_E = 1'b0;
    flush_D = 1'b0;
    flush_E = 1'b0;
    
    // SW-LWð�� - ������ȼ�
    if (sw_lw_hazard) begin
        stall_F = 1'b1;
        stall_D = 1'b1;
    end
    // ��ͨLoad-Useð�մ���
    else if (lw_stall) begin
        stall_F = 1'b1;    
        stall_D = 1'b1;    
    end
    // ��֧-LWð��
    else if (branch_stall) begin
        stall_F = 1'b1;    
        stall_D = 1'b1;    
    end
    // ��֧��ת���� - �ϵ����ȼ�
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
//        stall_F = 1'b1;    // ��ͣȡָ
//        stall_D = 1'b1;    // ���ַ�ָ֧s����ID
//        //stall_E = 1'b1;    // �ȴ��ȽϽ��
//    end else
//    // SW-LWð�մ���������ȼ���
//    if (sw_lw_hazard) begin
//        stall_F = 1'b1;
//        stall_D = 1'b1;
//        //stall_E = 1'b1;
//    end
//    // Load-Useð�մ���
//    else if (lw_stall) begin
//        stall_F = 1'b1;    
//        stall_D = 1'b1;    
//        //flush_E = 1'b1;
//    end
//    // ��֧ð�մ���ֻ����û������ð��ʱ�Ŵ���
//    else if (branch_D && pc_src_D || jump_D) begin
//        flush_D = 1'b1;    
//        flush_E = 1'b1;    
//    end
//end

endmodule