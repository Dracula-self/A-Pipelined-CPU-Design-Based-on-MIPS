//module test_ext_ram;
//    reg clk, reset;
//    reg [31:0] data_sram_addr, data_sram_wdata;
//    reg data_sram_en;
//    reg [3:0] data_sram_wen;
    
//    wire ext_ram_ce_n, ext_ram_oe_n, ext_ram_we_n;
//    wire [3:0] ext_ram_be_n;
//    wire [31:0] ext_ram_data;
//    reg [31:0] expected_data;
    
//    // 双向数据总线控制
//    reg [31:0] data_to_ram;
//    assign ext_ram_data = (data_sram_wen != 4'b0000) ? data_to_ram : 32'bz;
    
//    // 实例化你的 RAM 控制模块
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
    
//    // 时钟生成
//    initial begin
//        clk = 0;
//        forever #5 clk = ~clk;
//    end
    
//    // 测试序列
//    initial begin
//        // 初始化
//        reset = 1;
//        data_sram_en = 0;
//        data_sram_wen = 4'b0000;
//        data_sram_addr = 32'h0;
//        data_sram_wdata = 32'h0;
//        data_to_ram = 32'h0;
//        expected_data = 32'h0;
        
//        // 等待几个时钟周期后释放复位
//        repeat(4) @(posedge clk);
//        reset = 0;
        
//        // 8x8 循环加法测试
//        $display("开始 8x8 循环加法测试...");
        
//        reg [31:0] sum;
//        reg [7:0] i, j;
//        sum = 32'h0;
        
//        for (i = 0; i < 8; i = i + 1) begin
//            for (j = 0; j < 8; j = j + 1) begin
//                // 等待时钟上升沿
//                @(posedge clk);
                
//                // 设置写操作
//                sum = sum + (i + j);
//                data_sram_addr = 32'h8080_0000 + ((i * 8 + j) * 4);
//                data_sram_wdata = sum;
//                data_to_ram = sum;
//                data_sram_en = 1;
//                data_sram_wen = 4'b1111;
//                expected_data = sum;
                
//                // 保持写使能一个时钟周期
//                @(posedge clk);
                
//                // 禁用写使能，等待写入完成
//                data_sram_wen = 4'b0000;
//                @(posedge clk);
                
//                // 读回验证
//                data_sram_en = 1;
//                @(posedge clk);
                
//                // 验证读取的数据
//                if (ext_ram_data !== expected_data) begin
//                    $display("错误：地址 0x%h 处的数据不匹配", data_sram_addr);
//                    $display("期望值: 0x%h, 实际值: 0x%h", expected_data, ext_ram_data);
//                end else begin
//                    $display("成功：地址 0x%h 处的数据正确 (0x%h)", 
//                            data_sram_addr, ext_ram_data);
//                end
//            end
//        end
        
//        // 测试完成
//        repeat(4) @(posedge clk);
//        $display("测试完成");
//        $finish;
//    end
    
//    // 添加波形记录
//    initial begin
//        $dumpfile("test_ext_ram.vcd");
//        $dumpvars(0, test_ext_ram);
//    end
//endmodule