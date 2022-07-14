module key_filter(
    input clk,
    input rst_n,
    input key_in,
	 
	 
    //output reg key_state,  //预留
    output reg			key_flag
);

    //parameter CNT_MAX = 1;   //20ms计数值 1_000_000

  //  reg [19:0] key_H, key_L;         //计数变量

	 
//reg define    
reg [31:0] delay_cnt;
reg        key_reg;

//*****************************************************
//**                    main code
//*****************************************************
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin 
        key_reg   <= 1'b1;
        delay_cnt <= 32'd0;
    end
    else begin
        key_reg <= key_in;
        if(key_reg != key_in)             //一旦检测到按键状态发生变化(有按键被按下或释放)
            delay_cnt <= 32'd10000_000;  //给延时计数器重新装载初始值（计数时间为20ms）
        else if(key_reg == key_in) begin  //在按键状态稳定时，计数器递减，开始20ms倒计时
                 if(delay_cnt > 32'd0)
                     delay_cnt <= delay_cnt - 1'b1;
                 else
                     delay_cnt <= delay_cnt;
             end           
    end   
end	 
	 
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin 
        key_flag  <= 1'b0;         
    end
    else begin
        if(delay_cnt == 32'd1) begin   //当计数器递减到1时，说明按键稳定状态维持了20ms
            key_flag  <= 1'b1;         //此时消抖过程结束，给出一个时钟周期的标志信号
        end
        else begin
            key_flag  <= 1'b0;
        end  
    end   
end
    
endmodule 	 

	 
	 
	 
	 






























	 
//------------------按键为低 计数-------------------------------------------------------------------------------------------------
/*    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            key_H <= 20'd0;
        else begin
            if(key_in)
                key_H <= key_H + 1;
            else
                key_H <= 20'd0;       
        end     
    end 

//-------------------按键为高 计数-----------------------------------------------------------------------------------------------------    
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            key_L <= 20'd0;
        else begin
            if(!key_in)
                key_L <= key_L + 1;
            else
                key_L <= 20'd0;       
        end     
    end 

//-------------------key_state输出判断-------------------------------------------------------------------------------------------------------   
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            key_state <= 1'b1;
        else begin
            if(key_H > CNT_MAX)
                key_state <= 1'b1;
            else if(key_L > CNT_MAX)
                key_state <= 1'b0;            
        end 
    end 
//---------------------按键按下 下降沿判断-------------------------------------------------------------  
    reg state1, state2;
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            state1 <= 1'b0;
            state2 <= 1'b0;
        end 
        else begin
            state1 <= key_state;
            state2 <= state1;
        end    
    end 
    
    assign key_flag = (!state1) | state2;   //按键按下，flag为高

endmodule 

*/
/*
module key_filter(
    input clk,
    input rst_n,
    input key_in,
	 
    output reg key_state,  //预留
    output key_flag
);

    parameter CNT_MAX = 1;   //20ms计数值 1_000_000

    reg [19:0] key_H, key_L;         //计数变量

//------------------按键为低 计数-------------------------------------------------------------------------------------------------
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            key_L <= 20'd0;
        else begin
            if(key_in == 1'b0)
                key_L <= key_L + 1'b1;
            else
                key_L <= 20'd0;       
        end     
    end 

//-------------------按键为高 计数-----------------------------------------------------------------------------------------------------   
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            key_H <= 20'd0;
        else begin
            if(key_in  == 1'b0)
                key_H <= key_H + 1'b1;
            else
                key_H <= 20'd0;       
        end     
    end 

//-------------------key_state输出判断-------------------------------------------------------------------------------------------------------   
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            key_state <= 1'b1;
        else begin
            if(key_L > CNT_MAX)
                key_state <= 1'b0;
            else if(key_H > CNT_MAX)
                key_state <= 1'b1;            
        end 
    end 
//---------------------按键按下 下降沿判断-------------------------------------------------------------  
    reg state1, state2;
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            state1 <= 1'b0;
            state2 <= 1'b0;
        end 
        else begin
            state1 <= key_state;
            state2 <= state1;
        end    
    end 
    
    assign key_flag = (!state1) & state2;  //按键按下，flag为高

endmodule

*/ 