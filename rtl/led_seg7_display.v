//----------------------------数码管显示-------------------------------------------------------------
module led_seg7_display(  
    input clk,
    input rst_n,
    input [1:0] model,
    input date_time_ch,           // 时钟/日期    
    input [23:0] time_num,        // 时钟数据
    input [23:0] data_num,        // 日期数据
    input [23:0] adjust_time_num, // 调整时钟数据
    input [23:0] adjust_date_num, // 调整日期数据    
    input [15:0] adjust_clock_num,// 调整闹钟数据
    input [23:0] stop_watch_num,  // 秒表

    output reg	[5:0] sel_r,             // 数码管位选（选择当前要显示的数码管）
	 output reg [7:0] seg          // 数码管段选（当前要显示的内容） 
);

//--------------------------------------------- 显示数据选择 -------------------------------------------------------------------------------   
    reg [23:0] show_num;
    
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            show_num <= 24'h0;
        else begin
            if(model == 2'b00) begin      //常规显示
                if(!date_time_ch)          //显示时间
                    show_num <= time_num;
                else                      //日期显示
                    show_num <= data_num;
            end 
            else if(model == 2'b01)       //闹钟显示
                show_num <= {adjust_clock_num, 8'b00000000};  //闹钟只有小时和分钟，这里默认秒位
            else if(model == 2'b10)       //秒表显示
                show_num <= stop_watch_num;
            else begin                    //调整时间
                if(!date_time_ch)         //调整时间显示
                    show_num <= adjust_time_num;
                else                      //调整日期显示
                    show_num <= adjust_date_num;
            end
        end 
    end
//--------------------------------------------- 数码管显示逻辑 ----------------------------------------------------------------------------------                
  reg clk_1ms;  //数码管扫描周期1ms
  reg    [ 3:0]             clk_cnt  ;        // 时钟分频计数器 
  localparam  CLK_DIVIDE = 4'd10     ;        // 时钟分频系数
    
//对系统时钟10分频，得到的频率为5MHz的数码管驱动时钟clk_1ms   50/10=5Mhz
always @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
       clk_cnt <= 4'd0;
       clk_1ms <= 1'b1;
   end
   else if(clk_cnt == CLK_DIVIDE/2 - 1'd1) begin
       clk_cnt <= 4'd0;
       clk_1ms <= ~clk_1ms;
   end
   else begin
       clk_cnt <= clk_cnt + 1'b1;
       clk_1ms <= clk_1ms;
   end
end

    reg [3:0] data_tmp; //数据缓存

	 reg    [12:0]             cnt0     ;        // 数码管驱动时钟计数器
	 reg                       flag     ;        // 标志信号（标志着cnt0计数达1ms）
	 reg    [2:0]              cnt_sel  ;        // 数码管位选计数器
	 
	 localparam  MAX_NUM    = 13'd5000  ;        // 对数码管驱动时钟(5MHz)计数1ms所需的计数值
	 
//每当计数器对数码管驱动时钟计数时间达1ms，输出一个时钟周期的脉冲信号
always @ (posedge clk_1ms or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        cnt0 <= 13'b0;
        flag <= 1'b0;
     end
    else if (cnt0 < MAX_NUM - 1'b1) begin
        cnt0 <= cnt0 + 1'b1;
        flag <= 1'b0;
     end
    else begin
        cnt0 <= 13'b0;
        flag <= 1'b1;
     end
end

//cnt_sel从0计数到5，用于选择当前处于显示状态的数码管
always @ (posedge clk_1ms or negedge rst_n) begin
    if (rst_n == 1'b0)
        cnt_sel <= 3'b0;
    else if(flag) begin
        if(cnt_sel < 3'd5)
            cnt_sel <= cnt_sel + 1'b1;
        else
            cnt_sel <= 3'b0;
    end
    else
        cnt_sel <= cnt_sel;
end


always @ (posedge clk_1ms or negedge rst_n) begin
    if(!rst_n) begin
        sel_r  <= 6'b111111;              //位选信号低电平有效
       // show_num <= 4'b0;           
    end
		else begin	 
			 case (cnt_sel)
                3'd0 :begin
                    sel_r  <= 6'b111110;  //显示数码管最低位
                    data_tmp <= show_num[3:0] ;  //显示的数据
                    
                end
                3'd1 :begin
                    sel_r  <= 6'b111101;  //显示数码管第1位
                    data_tmp <= show_num[7:4] ;
                    
                end
                3'd2 :begin
                    sel_r  <= 6'b111011;  //显示数码管第2位
                    data_tmp <= show_num[11:8];
                    
                end
                3'd3 :begin
                    sel_r  <= 6'b110111;  //显示数码管第3位
                    data_tmp <= show_num[15:12];
                    
                end
                3'd4 :begin
                    sel_r  <= 6'b101111;  //显示数码管第4位
                    data_tmp <= show_num[19:16];
                    
                end
                3'd5 :begin
                    sel_r  <= 6'b011111;  //显示数码管最高位
                    data_tmp <= show_num[23:20];
                    
                end
                default :begin
                    sel_r  <= 6'b111111;
                    data_tmp <= 4'b0;
                    
                end
            endcase
        end
end

//控制数码管段选信号，显示字符
always @ (posedge clk_1ms or negedge rst_n) begin
			if (!rst_n)
		
				seg <= 8'hc0;
		
			else begin
					case (data_tmp)
							4'd0 : seg <= 7'b1000000; //显示数字 0
							4'd1 : seg <= 7'b1111001; //显示数字 1
							4'd2 : seg <= 7'b0100100; //显示数字 2
							4'd3 : seg <= 7'b0110000; //显示数字 3
							4'd4 : seg <= 7'b0011001; //显示数字 4
							4'd5 : seg <= 7'b0010010; //显示数字 5
							4'd6 : seg <= 7'b0000010; //显示数字 6
							4'd7 : seg <= 7'b1111000; //显示数字 7
							4'd8 : seg <= 7'b0000000; //显示数字 8
							4'd9 : seg <= 7'b0010000; //显示数字 9
							4'd10: seg <= 8'b11111111;           //不显示任何字符
							4'd11: seg <= 8'b10111111;           //显示负号(-)
							default: 
                   seg <= 7'b1000000;
					endcase
				end

end
endmodule 