//---- key1 日期，时间切换
//---- key2 模式切换 （00：时钟，01：闹钟，10：秒表，11：调时）
//---- key3 调时和设置闹钟时，小时、分钟左右切捯
//---- key4 +1 
//---- key5 -1 
//---- key6 秒表暂停（开始）切换
//---- key7 秒表清除

module key_module(
    input clk,
    input rst_n,
    input [6:0] key_ino,
    
    output reg date_time_ch,      //时间和日期切换标志位，0为时间，1为日期
    output [1:0] model,            //模式：00：时钟，01：闹钟，10：秒表，11：调时
    output reg [1:0] adjust_shif,  //调整时间时，调整位置：00：秒个位，01：分个位，10：时个位
    output key_up,                 //调整时间+
    output key_down,               //调整时间-
    output reg pause,                  //秒表暂停/开始  0：暂停，1：开始
    output clear                  //秒表清除
);

//-------------------------------------- 例化key_filter,产生按键对应的高电平脉冲 ----------------------------------------------------------------
    wire [6:0] key_out;
    genvar i;
    generate
        for(i = 0; i < 7; i = i + 1) begin: specify7_key_filter  //块名
            key_filter fliter1(
                         .clk        (clk),
                         .rst_n      (rst_n),
                         .key_in     (key_ino[i]),
								 
                         //.key_state  (),
                         .key_flag   (key_out[i])
                    );
        
        end 
    endgenerate  
   
    assign key_up   = key_out[3];
    assign key_down = key_out[4];
    assign clear    = key_out[6];
//-------------------------------------------- 例化 model_change -------------------------------------------------------------------------------------------    
    model_change model1(
                    .clk    (clk),
                    .rst_n  (rst_n),
                    .key_in_model (key_out[1]),
						  
                    .model  (model)
                );
//-------------------------------------------- adjust_shif 调整时间位置 ------------------------------------------------------------------------------------
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            adjust_shif <= 2'b00;
        end 
        else begin
            if(key_out[2]) begin
                adjust_shif <= adjust_shif + 1'b1;  //非阻塞赋值，需要到过程块结束才赋新值，所以 adjust_shif == 2'b10，而不是11
                if(adjust_shif == 2'b10) 
                    adjust_shif <= 2'b00;
            end              
            if(key_out[1])                        // model模式改变时，回到初始位
                adjust_shif <= 2'b00;
        end 
    end
//--------------------------------------------- date_time_ch 时间和日期切换标志位---------------------------------------------------------------------------------------------------------------    
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            date_time_ch <= 1'b0;
        else if(key_out[0]) begin
            date_time_ch <= ~date_time_ch;   //按键摁下，标志位翻转       
        end 
        else
            date_time_ch <= date_time_ch;
    end
//------------------------------------------------ pause 秒表暂停/开始 --------------------------------------------------------------------------------------------------
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            pause <= 1'b0;
        else if(key_out[5])
            pause <= ~pause;
        else if(model != 2'b10)  //退出秒表模式暂停
            pause <= 1'b0; 
        else    
            pause <= pause;            
    end
    
endmodule 