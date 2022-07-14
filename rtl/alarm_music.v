module alarm_music(
    input clk,
    input rst_n,
    input [15:0] adjust_clock_num,        //闹钟调整值,只有小时和分钟
    input [23:0] time_num,
    
    output beep
);
//------------------------------------- 闹钟使能逻辑 ---------------------------------------------------------------------------------------
    reg flag_en;
    reg [7:0] state;
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            flag_en <= 1'b0;
        else if({adjust_clock_num, 8'd0} == time_num)
            flag_en <= 1'b1;
        else if(state == 8'd63)  //一首音乐结束
            flag_en <= 1'b0;
        else
            flag_en <= flag_en;
    end 


//------------------------------------ 音乐 ---------------------------------------------------------------------------------
    reg beep_r;    
    reg [16:0] count, count_end;
    reg [23:0] count1;

    localparam  L_3 = 17'd75850,
                L_5 = 17'd63776,
                L_6 = 17'd56818,
                L_7 = 17'd50618,
                M_1 = 17'd47774,
                M_2 = 17'd42568,
                M_3 = 17'd37919,
                M_5 = 17'd31888,
                M_6 = 17'd28409,
                H_1 = 17'd23889;

    localparam TIME = 12000000;  //每个音的长短（250ms）     
    assign beep = beep_r;
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            count <= 17'h0;
            beep_r <= 1'b1;
        end 
        else if(flag_en) begin
            count <= count + 1'b1;
            if(count == count_end) begin
                count <= 17'h0;
                beep_r <= !beep_r;
            end 
        end
        else begin
            count <= 17'h0;
            beep_r <= 1'b1;            
        end 
    end 
    
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            count1 <= 24'd0;
            state <= 8'd0;
        end
        else if(flag_en) begin
            if(count1 < TIME) 
                count1 <= count1 + 1'b1;
            else begin
                count1 <= 24'd0;
                if(state == 8'd63)
                    state <= 8'd0;
                else
                    state <= state + 1'b1;        
            end         
        end 
        else begin
            count1 <= 24'd0;
            state <= 8'd0;
        end            
    end 
    
    always@(state) begin
        case(state)
            8'd0, 8'd1, 8'd2, 8'd3:      count_end  = L_3;
            8'd4, 8'd5, 8'd6:            count_end  = L_5;
            8'd7:                        count_end  = L_6;
            
            8'd8, 8'd9, 8'd10:           count_end  = M_1;
            8'd11:                       count_end  = M_2;
            8'd12:                       count_end  = L_6;
            8'd13:                       count_end  = M_1;
            8'd14, 8'd15:                count_end  = L_5;
            
            8'd16, 8'd17, 8'd18:         count_end  = M_5;
            8'd19:                       count_end  = H_1;
            8'd20:                       count_end  = M_6;
            8'd21:                       count_end  = M_5;
            8'd22:                       count_end  = M_3;
            8'd23:                       count_end  = M_5;
            
            8'd24, 8'd25, 8'd26, 8'd27, 
            8'd28, 8'd29, 8'd30, 8'd31:  count_end  = M_2;
            
            8'd32, 8'd33, 8'd34:         count_end  = M_2;
            8'd35:                       count_end  = M_3;
            8'd36, 8'd37:                count_end  = L_7;
            8'd38, 8'd39:                count_end  = L_6;
            
            8'd40, 8'd41, 8'd42:         count_end  = L_5;
            8'd43:                       count_end  = L_6;
            8'd44, 8'd45:                count_end  = M_1;
            8'd46, 8'd47:                count_end  = M_2;
            8'd48, 8'd49:                count_end  = L_3;
            
            8'd50, 8'd51:                count_end  = M_1;
            8'd52:                       count_end  = L_6;
            8'd53:                       count_end  = L_5;
            8'd54:                       count_end  = L_5;
            8'd55:                       count_end  = M_1;
            
            8'd56, 8'd57, 8'd58, 8'd59, 
            8'd60, 8'd61, 8'd62, 8'd63:  count_end  = L_5;  
            default:                     count_end  = 17'hxxxxx; 
        endcase     
    end 
    


    



endmodule 