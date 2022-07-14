module stop_watch(
    input clk,
    input rst_n,
    input [1:0] model,
    input pause,                  //秒表暂停/开始  0：暂停，1：开始
    input clear,                  //秒表清除
    
    output [23:0] stop_watch_num  //输出显示
);

//-------------------------------------- 10ms上升沿 --------------------------------------------------------------------------    
    wire clk_10ms;
    reg clk_10ms_reg1, clk_10ms_reg2;
    wire pos_10ms;
	 	 
    clk_div #(.CNT_MAX(5_000_000)) clk_div_10ms(   
    .clk_in  (clk),
    .rst_n   (rst_n),
    .clk_out (clk_10ms)
    ); 
                    
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            clk_10ms_reg1 <= 1'b0;
            clk_10ms_reg2 <= 1'b0;
        end 
        else begin
            clk_10ms_reg1 <= clk_10ms;
            clk_10ms_reg2 <= clk_10ms_reg1;
        end    
    end 
    
    assign pos_10ms = clk_10ms_reg1 & (~clk_10ms_reg2);
//-------------------------------------- 10ms_计数 --------------------------------------------------------------------------------    
    reg [3:0] cnt_ms0;
    reg [3:0] cnt_ms1;    
    reg [3:0] cnt_s0;
    reg [3:0] cnt_s1;
    reg [3:0] cnt_m0;
    reg [3:0] cnt_m1;
        
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin     //异步复位
            cnt_ms0 <= 4'd0;
            cnt_ms1 <= 4'd0;    
            cnt_s0  <= 4'd0;
            cnt_s1  <= 4'd0;
            cnt_m0  <= 4'd0;
            cnt_m1  <= 4'd0;
        end 
        else if(clear) begin  //同步清零
            cnt_ms0 <= 4'd0;
            cnt_ms1 <= 4'd0;    
            cnt_s0  <= 4'd0;
            cnt_s1  <= 4'd0;
            cnt_m0  <= 4'd0;
            cnt_m1  <= 4'd0;            
        end 
        else if(pos_10ms) begin  
            if(model == 2'b10) begin   //秒表模式
                if(pause) begin  //开始
                    cnt_ms0 <= cnt_ms0 + 1'b1;
                    if(cnt_ms0 == 4'd9) begin
                        cnt_ms0 <= 4'd0;
                        cnt_ms1 <= cnt_ms1 + 1'b1;
                        if(cnt_ms1 == 4'd9) begin  //99, 1s时间到
                            cnt_ms1 <= 4'd0;
                            cnt_s0 <= cnt_s0 + 1'b1;
                            if(cnt_s0 == 4'd9) begin
                                cnt_s0 <= 4'd0;
                                cnt_s1 <= cnt_s1 + 1'b1;
                                if(cnt_s1 == 4'd5) begin  //59s
                                    cnt_s1 <= 4'd0;
                                    cnt_m0 <= cnt_m0 + 1'b1;
                                    if(cnt_m0 == 4'd9) begin
                                        cnt_m0 <= 4'd0;
                                        cnt_m1 <= cnt_m1 + 1'b1;                                
                                    end 
                                end 
                            end 
                        end 
                    end             
                end 
            end            
        end   
        else begin
            cnt_ms0 <= cnt_ms0;
            cnt_ms1 <= cnt_ms1;    
            cnt_s0  <= cnt_s0;
            cnt_s1  <= cnt_s1;
            cnt_m0  <= cnt_m0;
            cnt_m1  <= cnt_m1;        
        end 
    end
//------------------------------------------------------ ���� --------------------------------------------------------------------
    assign stop_watch_num = {cnt_m1, cnt_m0, cnt_s1, cnt_s0, cnt_ms1, cnt_ms0};

endmodule 