module clk_div( 
    input clk_in,
    input rst_n,
    output reg clk_out				//clk_out的周期，可在上层模块例化时修改 
);
    
//--------------------------------------------------------------------------------       
    parameter CNT_MAX = 1;  
    
    //reg clk_reg;
    reg [27:0] cnt;

//-------------------------------------------------------------------------------------     
    //assign clk_out = clk_reg;
   
    always@(posedge clk_in, negedge rst_n) begin
        if(!rst_n) begin
            clk_out <= 1'b0;
            cnt <= 28'd0;
        end 
        else begin
            if(cnt == CNT_MAX - 1) begin
                cnt <= 28'd0;
                clk_out <= ~clk_out;           
            end 
            else begin            
                cnt <= cnt + 1'b1;
                clk_out <= clk_out;
            end
        end 
    end
            
endmodule 