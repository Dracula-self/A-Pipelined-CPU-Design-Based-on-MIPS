//module test_ext_ram;
//    reg clk, reset;
//    reg [31:0] data_sram_addr, data_sram_wdata;
//    reg data_sram_en;
//    reg [3:0] data_sram_wen;
    
//    wire ext_ram_ce_n, ext_ram_oe_n, ext_ram_we_n;
//    wire [3:0] ext_ram_be_n;
//    wire [31:0] ext_ram_data;
//    reg [31:0] expected_data;
    
//    // ˫���������߿���
//    reg [31:0] data_to_ram;
//    assign ext_ram_data = (data_sram_wen != 4'b0000) ? data_to_ram : 32'bz;
    
//    // ʵ������� RAM ����ģ��
//    your_ram_module ram_ctrl (
//        .clk(clk),
//        .reset(reset),
//        .data_sram_addr(data_sram_addr),
//        .data_sram_wdata(data_sram_wdata),
//        .data_sram_en(data_sram_en),
//        .data_sram_wen(data_sram_wen),
        
//        .ext_ram_ce_n(ext_ram_ce_n),
//        .ext_ram_oe_n(ext_ram_oe_n),
//        .ext_ram_we_n(ext_ram_we_n),
//        .ext_ram_be_n(ext_ram_be_n),
//        .ext_ram_data(ext_ram_data)
//    );
    
//    // ʱ������
//    initial begin
//        clk = 0;
//        forever #5 clk = ~clk;
//    end
    
//    // ��������
//    initial begin
//        // ��ʼ��
//        reset = 1;
//        data_sram_en = 0;
//        data_sram_wen = 4'b0000;
//        data_sram_addr = 32'h0;
//        data_sram_wdata = 32'h0;
//        data_to_ram = 32'h0;
//        expected_data = 32'h0;
        
//        // �ȴ�����ʱ�����ں��ͷŸ�λ
//        repeat(4) @(posedge clk);
//        reset = 0;
        
//        // 8x8 ѭ���ӷ�����
//        $display("��ʼ 8x8 ѭ���ӷ�����...");
        
//        reg [31:0] sum;
//        reg [7:0] i, j;
//        sum = 32'h0;
        
//        for (i = 0; i < 8; i = i + 1) begin
//            for (j = 0; j < 8; j = j + 1) begin
//                // �ȴ�ʱ��������
//                @(posedge clk);
                
//                // ����д����
//                sum = sum + (i + j);
//                data_sram_addr = 32'h8080_0000 + ((i * 8 + j) * 4);
//                data_sram_wdata = sum;
//                data_to_ram = sum;
//                data_sram_en = 1;
//                data_sram_wen = 4'b1111;
//                expected_data = sum;
                
//                // ����дʹ��һ��ʱ������
//                @(posedge clk);
                
//                // ����дʹ�ܣ��ȴ�д�����
//                data_sram_wen = 4'b0000;
//                @(posedge clk);
                
//                // ������֤
//                data_sram_en = 1;
//                @(posedge clk);
                
//                // ��֤��ȡ������
//                if (ext_ram_data !== expected_data) begin
//                    $display("���󣺵�ַ 0x%h �������ݲ�ƥ��", data_sram_addr);
//                    $display("����ֵ: 0x%h, ʵ��ֵ: 0x%h", expected_data, ext_ram_data);
//                end else begin
//                    $display("�ɹ�����ַ 0x%h ����������ȷ (0x%h)", 
//                            data_sram_addr, ext_ram_data);
//                end
//            end
//        end
        
//        // �������
//        repeat(4) @(posedge clk);
//        $display("�������");
//        $finish;
//    end
    
//    // ��Ӳ��μ�¼
//    initial begin
//        $dumpfile("test_ext_ram.vcd");
//        $dumpvars(0, test_ext_ram);
//    end
//endmodule