module time_counter(
    input            clk,
   //input            clk_1s,
    input            rst_n,
    input    [1:0]   model,
    input            date_time_ch,        //ʱ���������л���־λ��?oʱ�䣬1Ϊ�ՖP   
	 input    [23:0]  adjust_time_num,          //ʱ��������   
	 input    [23:0]  adjust_date_num,           //���ڵ�����   
    
    output   [23:0]  time_num,
    output   [23:0]  data_num,
    output           time_led
);

//---------------------------- 秒表显示变量 --------------------------------  
    reg [3:0] toc_10ms;
    reg [3:0] toc_100ms;
    
    reg [3:0] toc_1s;
    reg [3:0] toc_10s;
    
    reg [3:0] toc_1m;
    reg [3:0] toc_10m;
//------------------------- 1s时钟上升沿检测----------------------------------------
     wire clk_1s;
	 	 
    clk_div #(.CNT_MAX(50_000_000)) clk_div_1s(
    .clk_in  (clk),
    .rst_n   (rst_n),
    .clk_out (clk_1s)
    );  
    reg clk_reg1, clk_reg2;
    wire pos_1s;
    
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            clk_reg1 <= 1'b0;
            clk_reg2 <= 1'b0;
        end 
        else begin
            clk_reg1 <= clk_1s;
            clk_reg2 <= clk_reg1;
        end    
    end 
    
    assign pos_1s = clk_reg1 & (!clk_reg2);
//---------------------����ʱ��������ʱ���֡�����-----------------------------
    reg [3:0] sec0;
    reg [3:0] sec1;
    
    reg [3:0] min0;
    reg [3:0] min1;
    
    reg [3:0] hour0;
    reg [3:0] hour1;        
    
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            sec0   <=  4'd9;  //Ĭ��ʱ��23:56:49
            sec1   <=  4'd4;
            min0   <=  4'd8;
            min1   <=  4'd5;
            hour0  <=  4'd3;
            hour1  <=  4'd2;           
        end
        else begin
            if(pos_1s) begin
                sec0 <= sec0 + 1'b1;
                if(sec0 == 4'd9) begin
                    sec0 <= 4'd0;
                    sec1 <= sec1 + 1'b1;
                    if(sec1 == 4'd5) begin
                        sec1 <= 4'd0;
                        min0 <= min0 + 1'b1;
                        if(min0 == 4'd9) begin
                            min0 <= 4'd0;
                            min1 <= min1 + 1'b1; 
                            if(min1 == 4'd5) begin
                                min1 <= 4'd0;
                                hour0 <= hour0 + 1'b1; 
                                if(hour0 == 4'd9) begin
                                    hour0 <= 4'd0;
                                    hour1 <= hour1 + 1'b1;                                    
                                end 
                            end 
                        end 
                    end 
                end                               
            end   
            if(hour1 ==4'd2 && hour0 == 4'd4) begin   
                hour1 <= 4'd0;
                hour0 <= 4'd0;                
            end 
            if((model == 2'b11) && !date_time_ch) begin     //ʱ��У׼ģʽ
                {hour1, hour0, min1, min0, sec1, sec0} <= adjust_time_num[23:0];
            end 
        end 
    end 
//--------------------- 日期时间（年、月、日）------------------------------    
    reg [3:0] day0;             
    reg [3:0] day1;    
    reg [3:0] month0;        //年、月、日计数变量
    reg [3:0] month1;    
    reg [3:0] year0;
    reg [3:0] year1;
    
    localparam  mon1  = 8'h31,   //每个月天数              
	             mon2  = 8'h28,
                mon3  = 8'h31,
                mon4  = 8'h30,
                mon5  = 8'h31,
                mon6  = 8'h30,
                mon7  = 8'h31,
                mon8  = 8'h31, 
                mon9  = 8'h30,
                mon10 = 8'h31,
                mon11 = 8'h30,
                mon12 = 8'h31;
                                   
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            day0   <=  4'd8;    //为了方便仿真看到变化，默认日期为2020-12-28
            day1   <=  4'd2;
            month0 <=  4'd2;
            month1 <=  4'd1;
            year0  <=  4'd0;
            year1  <=  4'd2;
        end 
        else begin
            if(hour1 ==4'd2 && hour0 == 4'd4) begin   //24Сʱɾ               
					 day0 <= day0 + 1'b1;
                if(day0 == 4'd9) begin
                    day0 <= 4'd0;
                    day1 <= day1 + 1'b1;                    
                end   
                case({month1, month0})   //根据月份，来改变
                    8'h01:  
                        if({day1, day0} == mon1) begin
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= month0 + 1'b1;
                        end 
                    8'h02:
                        if({day1, day0} == mon2) begin
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= month0 + 1'b1;
                        end 
                    8'h03:
                        if({day1, day0} == mon3) begin
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= month0 + 1'b1;
                        end 
                    8'h04:
                        if({day1, day0} == mon4) begin
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= month0 + 1'b1;
                        end 
                    8'h05:
                        if({day1, day0} == mon5) begin
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= month0 + 1'b1;
                        end 
                    8'h06:
                        if({day1, day0} == mon6) begin
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= month0 + 1'b1;
                        end 
                    8'h07:
                        if({day1, day0} == mon7) begin
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= month0 + 1'b1;
                        end 
                    8'h08:
                        if({day1, day0} == mon8) begin
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= month0 + 1'b1;
                        end 
                    8'h09:
                        if({day1, day0} == mon9) begin
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= 4'd0;
                            month1 <= 4'd1;   //�·ݸ�λҲ��
                        end 
                    8'h10:
                        if({day1, day0} == mon10) begin
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= month0 + 1'b1;
                        end 
                    8'h11:
                        if({day1, day0} == mon11) begin
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= month0 + 1'b1;
                        end 
                    8'h12: 
                        if({day1, day0} == mon12) begin  //12月最后一月                         
                            day0 <= 4'd1;
                            day1 <= 4'd0;
                            month0 <= 4'd1;
                            month1 <= 4'd0;
                            year0 <= year0 + 1'b1;     //下一年                              
                            if(year0 == 4'd9) begin
                                year0 <= 4'd0;
                                year1 <= year1 + 1'b1;
                            end 
                        end 
                    default: begin
                        day0   <=  4'hx;   //Ϊ�˷�������,��Ϊx
                        day1   <=  4'hx;
                        month0 <=  4'hx;
                        month1 <=  4'hx;
                        year0  <=  4'hx;
                        year1  <=  4'hx;                                        
                    end 
                endcase
            end  
            if((model == 2'b11) && date_time_ch)  //时间校准模式，并且处于日期显示下
				{year1, year0, month1, month0, day1, day0} <= adjust_date_num[23:0];
        end 
    end 
//------------------------------------------------------------ 整点报时 -----------------------------------------------------------------------    
    reg len_flag;
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            len_flag <= 1'b0;
        else if(time_num[15:0] == 16'b0) 
            len_flag <= 1'b1;
        else if(min0 == 4'd1)  //1����
            len_flag <= 1'b0;
        else
            len_flag <= len_flag;
    end
       
    assign time_led = len_flag ? clk_1s : 1'b0;      //1s��˸
//---------------------------------------------------------- ������ֵ-----------------------------------------------------------------------    
    assign time_num = {hour1, hour0, min1, min0, sec1, sec0};
    assign data_num = {year1, year0, month1, month0, day1, day0};   

endmodule 