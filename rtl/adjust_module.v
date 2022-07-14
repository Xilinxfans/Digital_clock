module adjust_module(
    input clk,
    input rst_n,    
  
    input [1:0] model,            //模式Ｐ：时钟，01：闹钟，10：秒表，11：调无   
	input date_time_ch,
    input [1:0] adjust_shif,  //调整时间时，调整位置Ｐ：秒个位Ｑ：分个位Ｐ：时个位
    input key_up,                 //调整时间+
    input key_down,               //调整时间-    
    input [23:0] time_num,
    input [23:0] data_num,

    output [23:0] adjust_time_num,
    output [23:0] adjust_date_num,
    output [15:0] adjust_clock_num    
);
//---------------------------- 闹钟变量 -------------------------------------------------------------------------------------------     
    reg [3:0] clock_min0;
    reg [3:0] clock_min1;
    
    reg [3:0] clock_hour0;
    reg [3:0] clock_hour1;
//----------------------------- 闹钟设置 ------------------------------------------------------------------------------------------------
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            clock_min0  <= 4'd0;
            clock_min1  <= 4'd0;            
            clock_hour0 <= 4'd0;
            clock_hour1 <= 4'd0;
        end
        else if(model == 2'b01) begin  //闹钟模式,只有小时、分钟           
		  if(adjust_shif == 2'b00) begin  //调分钟个位                
		      if(key_up) begin
                    clock_min0 <= clock_min0 + 1'b1;
                    if(clock_min0 == 4'd9)
                        clock_min0 <= 4'd0;
                end 
                else if(key_down) begin
                    clock_min0 <= clock_min0 - 1'b1;
                    if(clock_min0 == 4'd0)
                        clock_min0 <= 4'd9;
                end 
            end 
            else if(adjust_shif == 2'b01) begin  //调分钟十位               
				    if(key_up) begin
                    clock_min1 <= clock_min1 + 1'b1;
                    if(clock_min1 == 4'd5)
                        clock_min1 <= 4'd0;
                end 
                else if(key_down) begin
                    clock_min1 <= clock_min1 - 1'b1;
                    if(clock_min1 == 4'd0)
                        clock_min1 <= 4'd5;
                end             
            end 
            else begin  //小时个位
                if(key_up) begin
                    clock_hour0 <= clock_hour0 + 1'b1;
                    if(clock_hour0 == 4'd9) begin                    
                        clock_hour0 <= 4'd0;
                        clock_hour1 <= clock_hour1 + 1'b1;
                    end
                    if(clock_hour1 ==4'd2 && clock_hour0 == 4'd3) begin   
                        clock_hour1 <= 4'd0;
                        clock_hour0 <= 4'd0;                
                    end
                end 
                else if(key_down) begin
                    clock_hour0 <= clock_hour0 - 1'b1;
                    if(clock_hour0 == 4'd0) begin
                        clock_hour0 <= 4'd9;
                        clock_hour1 <= clock_hour1 - 1'b1;
                    end 
                    if(clock_hour1 ==4'd0 && clock_hour0 == 4'd0) begin   
                        clock_hour1 <= 4'd2;
                        clock_hour0 <= 4'd3;                
                    end
                end
            end
        end
    end 

    
//-------------------------- 校准时间变量 ------------------------------------------------------------------------------------------------   
    reg [3:0] adj_sec0;
    reg [3:0] adj_sec1;
    
    reg [3:0] adj_min0;
    reg [3:0] adj_min1;
    
    reg [3:0] adj_hour0;
    reg [3:0] adj_hour1;
 /*------------------------*/   
    reg [3:0] adj_day0;
    reg [3:0] adj_day1;
    
    reg [3:0] adj_month0;
    reg [3:0] adj_month1;
    
    reg [3:0] adj_year0;
    reg [3:0] adj_year1;

//----------------------------- 校准时间和日期--------------------------------------------------------------------------------------------------------
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            adj_sec0   <= 4'd9;
            adj_sec1   <= 4'd4;    
            adj_min0   <= 4'd6;
            adj_min1   <= 4'd5;            
            adj_hour0  <= 4'd3;
            adj_hour1  <= 4'd2;  
            adj_day0   <= 4'd8;
            adj_day1   <= 4'd0;    
            adj_month0 <= 4'd6;
            adj_month1 <= 4'd0;            
            adj_year0  <= 4'd0;
            adj_year1  <= 4'd2; 
        end         
        else if((model == 2'b11) && !date_time_ch)begin
            case(adjust_shif)  //调时 位置
                2'b00: begin //秒个位                   
					 if(key_up) begin
                        adj_sec0 <= adj_sec0 + 1'b1;
                        if(adj_sec0 == 4'd9) begin
                            adj_sec0 <= 4'd0;
                            adj_sec1 <= adj_sec1 + 1'b1;
                            if(adj_sec1 == 4'd5) begin
                                adj_sec1 <= 4'd0;
                            end 
                        end 
                    end 
                    else if(key_down) begin
                        adj_sec0 <= adj_sec0 - 1'b1;
                        if(adj_sec0 == 4'd0) begin
                            adj_sec0 <= 4'd9;
                            adj_sec1 <= adj_sec1- 1'b1;
                            if(adj_sec1 == 4'd0) begin
                                adj_sec1 <= 4'd5;
                            end 
                        end
                    end 
                end
                2'b01: begin //分个位                    
					 if(key_up) begin
                        adj_min0 <= adj_min0 + 1'b1;
                        if(adj_min0 == 4'd9) begin
                            adj_min0 <= 4'd0;
                            adj_min1 <= adj_min1 + 1'b1;
                            if(adj_min1 == 4'd5) begin
                                adj_min1 <= 4'd0;
                            end 
                        end 
                    end
                    else if(key_down) begin
                        adj_min0 <= adj_min0 - 1'b1;
                        if(adj_min0 == 4'd0) begin
                            adj_min0 <= 4'd9;
                            adj_min1 <= adj_min1- 1'b1;
                            if(adj_min1 == 4'd0) begin
                                adj_min1 <= 4'd5;
                            end 
                        end
                    end
				end
                2'b10: begin //时个位                    
                    if(key_up) begin
                        adj_hour0 <= adj_hour0 + 1'b1;
                        if(adj_hour0 == 4'd9) begin
                            adj_hour0 <= 4'd0;
                            adj_hour1 <= adj_hour1 + 1'b1;
                        end 
                        if(adj_hour1 ==4'd2 && adj_hour0 == 4'd3) begin   
                            adj_hour1 <= 4'd0;
                            adj_hour0 <= 4'd0;                
                        end
                    end
                    if(key_down) begin
                        adj_hour0 <= adj_hour0 - 1'b1;
                        if(adj_hour0 == 4'd0) begin
                            adj_hour0 <= 4'd9;
                            adj_hour1 <= adj_hour1 - 1'b1;
                        end 
                        if(adj_hour1 ==4'd0 && adj_hour0 == 4'd0) begin   
                            adj_hour1 <= 4'd2;
                            adj_hour0 <= 4'd3;                
                        end
                    end
				end
                default: begin
                    adj_sec0   <= 4'dx;
                    adj_sec1   <= 4'dx;    
                    adj_min0   <= 4'dx;
                    adj_min1   <= 4'dx;            
                    adj_hour0  <= 4'dx;
                    adj_hour1  <= 4'dx;   
                end                                 
            endcase 
        end 
        else if((model == 2'b11) && date_time_ch) begin
            case(adjust_shif)  //调时 位置
                2'b00:  begin//日个位                    
                    if(key_up) begin
                        adj_day0 <= adj_day0 + 1'b1;
                        if(adj_day0 == 4'd9) begin
                            adj_day0 <= 4'd0;
                            adj_day1 <= adj_day1 + 1'b1;                        
                        end 
                        if(adj_day1 == 4'd3 && adj_day0 == 4'd1) begin  //为了简化逻辑，调整天数，在0-31号之间
                            adj_day1 <= 4'd0; 
                            adj_day0 <= 4'd1;
                        end 
                    end 
                    if(key_down) begin
                        adj_day0 <= adj_day0 - 1'b1;
                        if(adj_day0 == 4'd0) begin
                            adj_day0 <= 4'd9;                           
                            adj_day1 <= adj_day1 - 1'b1;
                        end 
                        if(adj_day1 == 4'd0 && adj_day0 == 4'd1) begin   //1号再减一，31号
                            adj_day1 <= 4'd3;
                            adj_day0 <= 4'd1;
                        end
                    end
				end
                2'b01: begin //月个位                   
					     if(key_up) begin
                        adj_month0 <= adj_month0 + 1'b1;
                        if(adj_month0 == 4'd9) begin
                            adj_month0 <= 4'd0;
                            adj_month1 <= adj_month1 + 1'b1;                            
                        end 
                        if(adj_month1 == 4'd1 && adj_month0 == 4'd2) begin     //十二月加一，到十二月
                            adj_month1 <= 4'd0;
                            adj_month0 <= 4'd1;
                        end 
                    end
                    if(key_down) begin
                        adj_month0 <= adj_month0 - 1'b1;
                        if(adj_month0 == 4'd0) begin
                            adj_month0 <= 4'd9;
                            adj_month1 <= adj_month1 - 1'b1;
                        end 
                        if(adj_month1 == 4'd0 && adj_month0 == 4'd1) begin    //一月再减一，到十二月
                            adj_month1 <= 4'd1;
                            adj_month0 <= 4'd2;
                        end
                    end
					 end
                2'b10: begin  //年个位                    
					     if(key_up) begin
                        adj_year0 <= adj_year0 + 1'b1;
                        if(adj_year0 == 4'd9) begin
                            adj_year0 <= 4'd0;
                            adj_year1 <= adj_year1 + 1'b1; 
                            if(adj_year1 == 4'd9) begin
                                adj_year1 <= 4'd0;
                            end                            
                        end                         
                    end
                    if(key_down) begin
                        adj_year0 <= adj_year0 - 1'b1;
                        if(adj_year0 == 4'd0) begin
                            adj_year0 <= 4'd9;
                            if(adj_year1 > 4'd0)
                                adj_year1 <= adj_year1 - 1'b1;
                        end 
                    end
					 end
                default: begin
                    adj_day0   <= 4'hx;  //方便仿真时能看到错误
                    adj_day1   <= 4'hx;    
                    adj_month0 <= 4'dx;
                    adj_month1 <= 4'dx;            
                    adj_year0  <= 4'dx;
                    adj_year1  <= 4'dx;  
                end                                 
            endcase 
        end 
        else begin
            {adj_hour1, adj_hour0, adj_min1, adj_min0, adj_sec1, adj_sec0}     <= time_num;    //将当前时间赋给调节变量
            {adj_year1, adj_year0, adj_month1, adj_month0, adj_day1, adj_day0} <= data_num;   //即：在当前时间的基础上调节
        end
    end 

//------------------------------------------- 输出 ---------------------------------------------------------------------------------
    assign adjust_time_num  = {adj_hour1, adj_hour0, adj_min1, adj_min0, adj_sec1, adj_sec0};
    assign adjust_date_num  = {adj_year1, adj_year0, adj_month1, adj_month0, adj_day1, adj_day0};
    assign adjust_clock_num = {clock_hour1, clock_hour0, clock_min1, clock_min0};

endmodule 