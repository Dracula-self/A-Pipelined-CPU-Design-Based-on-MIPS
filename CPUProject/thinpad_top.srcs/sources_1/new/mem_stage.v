module mem_stage(
    input wire [31:0] alu_out_M,
    input wire [31:0] write_data_M,
    input wire mem_write_M,
    input wire [31:0] data_sram_rdata,    //���ڴ������
    input wire sw_to_lw_forward,
    input wire [31:0] sw_lw_forward_data,
    
    output wire [31:0] read_data_M
);

//����ѡ��SW-LWǰ�� �� �����ڴ��ȡ
assign read_data_M = sw_to_lw_forward ? sw_lw_forward_data : data_sram_rdata;

endmodule