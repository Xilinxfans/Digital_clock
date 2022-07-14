module model_change(
    input clk,
    input rst_n,
    input key_in_model,
	 
    output [1:0] model
);

//------------------------------------------- 模式：00：时钟，01：闹钟，10：秒表，11：调时 --------------------------------------------------------------------------
 
reg   [1:0]     model_reg;

always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin 
        model_reg  <= 2'd0;  
    end
    else begin
        if(key_in_model) begin   //当计数器递减到1时，说明按键稳定状态维持了20ms
            model_reg  <= model_reg + 1'b1;         //此时消抖过程结束，给出一个时钟周期的标志信号
        end
        else begin
            model_reg  <= model_reg;
        end  
    end   
end
    
	 assign model = model_reg;
endmodule 