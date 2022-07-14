module digital_clock_top(
    input        clk,
    input        rst_n,
    input  [6:0] key_ino,
    
    output [5:0] sel_r,                   //������λѡ��ѡ����ǰҪ��ʾ�������ܣ�
	 output [7:0] seg,                   //�����ܶ�ѡ����ǰҪ��ʾ�����ݣ� 
    output       time_led,
    output       beep
);

    wire date_time_ch;                  //ʱ���������л���־λ��0Ϊʱ�䣬1Ϊ����
    wire [1:0] model;                   //ģʽ��00��ʱ�ӣ�01�����ӣ�10������11����ʱ
    wire [1:0] adjust_shif;             //����ʱ��ʱ������λ�ã�00������λ��01���ָ�λ��10��ʱ��λ
    wire key_up;                        //����ʱ��+
    wire key_down;                      //����ʱ��-
    wire pause;                         //������ͣ/��ʼ  0����ͣ��1����ʼ
    wire clear;                         //��������
      
	wire   [23:0]  adjust_time_num;     //ʱ������ֵ   
	wire   [23:0]  adjust_date_num;     //���ڵ���  
    wire   [23:0]  time_num;            //��ǰʱ��ֵ
    wire   [23:0]  data_num;            //��ǰ����ֵ    
    wire   [15:0]  adjust_clock_num;     
    wire   [23:0]  stop_watch_num;        //����������ʾ    
    
    key_module key(
            .clk                (clk),
            .rst_n              (rst_n),
            .key_ino             (key_ino),        
            .date_time_ch       (date_time_ch),      
            .model              (model),            
            .adjust_shif        (adjust_shif),       
            .key_up             (key_up),           
            .key_down           (key_down),        
            .pause              (pause),             
            .clear              (clear)              
    );
    
    time_counter time1(
            .clk                (clk),
            .rst_n              (rst_n),
            .model              (model),
            .date_time_ch       (date_time_ch),         
            .adjust_time_num    (adjust_time_num),          
            .adjust_date_num    (adjust_date_num),      
            .time_num           (time_num),
            .data_num           (data_num),
            .time_led           (time_led)
    );
    
    adjust_module adjust(
            .clk                (clk),
            .rst_n              (rst_n),    
            .model              (model),               
            .date_time_ch       (date_time_ch),
            .adjust_shif        (adjust_shif),
            .key_up             (key_up),                 
            .key_down           (key_down),                  
            .time_num           (time_num),
            .data_num           (data_num),
            .adjust_time_num    (adjust_time_num),
            .adjust_date_num    (adjust_date_num),
            .adjust_clock_num   (adjust_clock_num)    
    );
    
    stop_watch stop(
            .clk                (clk),
            .rst_n              (rst_n),
            .model              (model),
            .pause              (pause),  
            .clear              (clear),   
            .stop_watch_num     (stop_watch_num)
    );
    
    led_seg7_display len_seg7(  
            .clk                (clk),
            .rst_n              (rst_n),
            .model              (model),
            .date_time_ch       (date_time_ch),                
            .time_num           (time_num),        
            .data_num           (data_num),        
            .adjust_time_num    (adjust_time_num), 
            .adjust_date_num    (adjust_date_num),    
            .adjust_clock_num   (adjust_clock_num), 
            .stop_watch_num     (stop_watch_num),  
            .sel_r                (sel_r),  
            .seg                (seg)      
    );

    alarm_music alarm(
            .clk                (clk),
            .rst_n              (rst_n),
            .adjust_clock_num   (adjust_clock_num),        //���ӵ���ֵ,ֻ��Сʱ�ͷ���
            .time_num           (time_num),
            .beep               (beep)
    );


endmodule