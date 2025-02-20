`timescale 1ns / 1ps

module main(
    input clk,
    input rst,
    input[23:0] sw,
    input[4:0] bt,
    input[3:0] row,
    output[3:0] col,
    output reg[7:0] seg_out,
    output reg[7:0] seg_en,
    output reg[23:0] led,
    output reg buzzer
    //output reg buzzer_clk
);
    wire[23:0] sw_link;
    wire[4:0] bt_link;
    wire[15:0] key_link;
    input_keyboard uk(clk, rst, row, col, key_link);
    input_sw us(clk, rst, sw, sw_link);
    input_bt ub(clk, rst, bt, bt_link);
   
    wire [8:0] count; //çâæ?
    //wire buzzer_clk;
    wire led_cnt;
    the_counter cnt (clk, rst, count, led_cnt);
    
    reg[2:0] view = 0;
    wire[3:0] o_view;
    assign o_view = view;
   
   //æ¿ å©è¾æ¿®?
    wire[2:0] total_a; //æ¶å©æªºé?3
    wire[2:0] total_b; //æ¶å©æªºé?3
    wire[2:0] left_a;
    wire[2:0] left_b;

    wire [2:0] open_a; //aéåç´éææºæµ??
    wire [2:0] open_b;

    wire[1:0] start_a;
    wire[1:0] start_b;
    wire[1:0] each_a;
    wire[1:0] each_b;
    wire[2:0] state_0;
    wire[7:0] bce_seg_out ,bce_seg_en;
    wire[2:0] choose_parking;

    // assign total_a = 3;
    // assign total_b = 3;
    // assign open_a = 3;
    // assign open_b = 3;
    // assign start_a = 5;
    // assign start_b = 10;
    // assign add_a = 2;
    // assign add_b = 1;

    wire bce_buzzer;
    music_player mp(clk,rst,sw[21],bce_buzzer);

    before_car_enter bce(
      clk, rst,bt_link,
      o_view, choose_parking, 
      state_0,
      key_link
      );

    before_car_enter_display bced(clk, rst, o_view, state_0,
     open_a, open_b, 
    left_a, left_b, 
    start_a, start_b, 
    each_a, each_b, 
    bce_seg_out ,bce_seg_en 
    //bce_buzzer//çä½¸æ¹?µ ï½çé²å±½å§?
    );
    
    wire [5:0] a_pos;
    wire [5:0] b_pos;

    wire [8:0] a_count [2:0];
    wire [8:0] b_count [2:0];

    wire[7:0] pc_seg_out, pc_seg_en;

    wire pcv_buzzer;
    wire [2:0] the_car;//é?îç²¯é´æ¬å§å?æ°³æ³²é¨å®æº? 

    wire a_clean;
    wire b_clean;

    park_car_view pcv(
        clk, rst,
        o_view,
        bt_link,
        open_a,
        open_b,
        count,
        the_car,
        left_a,
        left_b,
        a_pos,
        b_pos,
        a_count[0],
        a_count[1],
        a_count[2],
        b_count[0],
        b_count[1],
        b_count[2],
        pc_seg_out,
        pc_seg_en,
        //pcv_buzzer,
        a_clean,
        b_clean
    );

    //éåªçé®ä½¹îé??
    wire [2:0] num;
    wire num_correct;
    wire[7:0] pn_seg_out, pn_seg_en;

    park_num_check pnc(
      rst, clk,
      key_link,
      bt_link,
      o_view,
      a_pos,
      b_pos,
      num_correct,
      num,
      pn_seg_out,
      pn_seg_en
    );

    //æµ¼æ°¬æ?
    wire [21:0] one;
    wire [21:0] two;
    wire [21:0] three;
    wire [21:0] four;
    wire [21:0] five;
    wire [14:0] s;
    wire [3:0] account_mem;
    wire [15:0] psword_mm;//æµ¼æ°¬æ³é§è¯²ç¶ææ³åé¨å?é??
    wire [2:0] cnt_psword_mm;//æµ¼æ°¬æ³é§è¯²ç¶ææ³åé¨å?é?½ºæ®æµ£å¶æ
    wire [1:0] ps_error_time_mm; //æµ¼æ°¬æ³é§è¯²ç¶ææ³åé¨å?é?½ºæ®é¿æ¬î¤å¨âæéå²ç§´æ©å¦ç¬å¨Â¤ç¹é¥ç¶å?éç¯ç·?ã§æ«é??
    wire [15:0] becomeMemPsword;//é´æªè´æµ¼æ°?³çµåçé?
    wire [2:0] cnt_ch_psword;//é´æªè´æµ¼æ°?³çæ¿ç¶ææ³åçµåçæµ£å¶æé?? 
    wire [2:0] be_account;//éåå½é¨å?´°éæ¨ºå½¿é?
    wire [1:0] select_op;//æµ¼æ°¬æ³é«å¤å?é¨å¬æ·æµ£?
    wire isCancel, isChoosed;//éîæå¨ã©æ¢
    //éæ°­æéå²?æ®éå´æ¶éä½¸åé½è¾¨æ
    wire [5:0] be_money; //é?»æ?
    wire [1:0] cnt_be_money; //çâæé£?
    wire [2:0] be_money_ten; //éä½·ç¶é?    
    wire [3:0] be_money_one; //æ¶îç¶é?
    //æµ¼æ°¬æ³é²å¶æéå´æ¶é?
    wire [5:0] money; //é?»æ?
    wire [1:0] cnt_money; //çâæé£?
    wire [2:0] money_ten; //éä½·ç¶é?    
    wire [3:0] money_one; //æ¶îç¶é?
    wire [5:0] le_money; //é??æ©æ?æ®é½éæ¶
    wire [15:0] now_ps;
    wire [2:0] cnt_ps;
    wire [4:0] mm_state;//éå´å´é¨å?§¸é?½½æµç»ä¼ç´±
    wire[7:0] mm_seg_out ,mm_seg_en;
    wire isM_mm;//ææ´çææ³åé?¦å?
    //æ¶å¶å½²æµ ã¥æéæµæ¨éç­¼ne-fiveé¨å«??
    wire is_money_change_pay;
    wire [3:0] account_pay;
    wire [5:0] change_mems;

    member_model mm(clk,rst,bt_link,o_view,s,one,
    two,three,four,five,
    account_mem, psword_mm,cnt_psword_mm,ps_error_time_mm, 
    becomeMemPsword,
    cnt_ch_psword,be_account,select_op,
    isCancel, isChoosed,be_money,
    cnt_be_money,be_money_ten, be_money_one,
    money, cnt_money,
     money_ten, money_one,
     le_money,now_ps, cnt_ps, mm_state,
     key_link,isM_mm,
     is_money_change_pay,change_mems,
     account_pay);

    member_model_display mmd(clk,rst, o_view,mm_state,
    account_mem, psword_mm,
    cnt_psword_mm,ps_error_time_mm,
     becomeMemPsword,cnt_ch_psword,
    be_account,select_op,isCancel,
     isChoosed,be_money,cnt_be_money,
    be_money_ten, be_money_one,money, cnt_money, 
    money_ten,
     money_one,le_money,now_ps, cnt_ps,
     mm_seg_out ,mm_seg_en, 
     isM_mm, one,two,three,four,five);

    //é?îç²¯
    wire [3:0] discount;
    // assign discount = 4'd8;
    wire [15:0] psword_pay;
    wire [2:0] cnt_psword_pay;
    wire [1:0] ps_error_time_pay; 
    wire [7:0] seg_outs, seg_ens;
    wire [4:0] state_s;
    wire [8:0] fees,ch4nges, fee_mems, rests, change_m2ms, fee_rs;
    wire led_p;
    wire [8:0] count_temp;
    wire [8:0] profit;//é??çä½¸å§é?
    wire isM_pay;
    wire is_clean_profit;
    wire [8:0] time_avg;
    
    pay p(clk, rst, o_view, state_s, 
    sw, led_p, key_link, bt_link, 
    s, one, two, three, four, five, 
    account_pay, psword_pay, cnt_psword_pay, ps_error_time_pay, isM_pay, 
    num, the_car, count, 
    a_count[0], 
    a_count[1], 
    a_count[2], 
    b_count[0], 
    b_count[1], 
    b_count[2], 
    start_a, start_b, each_a, each_b, fees, ch4nges, fee_mems, discount, 
    rests, change_mems, change_m2ms, fee_rs, count_temp, is_money_change_pay, profit, is_clean_profit, time_avg);

    pay_display pd(clk, rst, o_view, state_s, seg_outs, seg_ens, 
    account_pay, psword_pay, cnt_psword_pay, isM_pay, count_temp, 
    fees, ch4nges, fee_mems, rests, 
    change_mems, change_m2ms, fee_rs);

    //ç» ï¼æé?
    wire [4:0] ad_state;
    wire [19:0] ps_write;
    wire [2:0]  ad_cnt_ps;
    wire [2:0] ad_ps_error_time;
    wire [3:0] select1;
    wire [3:0] select2;
    wire [2:0] select3;
    wire cnt_starta;
    wire [1:0]show_starta;
    wire cnt_startb;
    wire [1:0]show_startb;
    wire cnt_eacha;
    wire [1:0]show_eacha;
    wire cnt_eachb;
    wire [1:0]show_eachb;
    wire cnt_toa;
    wire [2:0]show_toa;  
    wire cnt_tob;
    wire [2:0]show_tob;
    wire cnt_dis;
    wire [3:0] show_dis;
    wire [7:0] ad_seg_out ,ad_seg_en;
    
    administrator_model adm(
        clk,
        rst,
        o_view,
        ad_state,
        discount,
        open_a,
        open_b,
        a_clean,
        b_clean,
        is_clean_profit,
        a_pos,
        b_pos,
        start_a,
        start_b,
        each_a,
        each_b,
        ps_write,
        ad_cnt_ps,
        ad_ps_error_time,
        select1,
        select2,
        select3,
        cnt_starta,
        show_starta,
        cnt_startb,
        show_startb,
        cnt_eacha,
        show_eacha, 
        cnt_eachb,
        show_eachb, 
        cnt_toa,
        show_toa,   
        cnt_tob,
        show_tob, 
        cnt_dis,
        show_dis,
        key_link,
        bt_link);
        
  administrator_model_display admd(
      clk,
      rst,
      o_view,
      ad_state,
        discount,
        open_a,
        open_b,
        left_a,
        left_b,
        profit,
        a_pos,
        b_pos,
        start_a,
        start_b,
        each_a,
        each_b,
        ps_write,
        ad_cnt_ps,
        ad_ps_error_time,
        select1,
        select2,
        select3,
      cnt_starta,
      show_starta,
      cnt_startb,
      show_startb,
      cnt_eacha,
      show_eacha, 
      cnt_eachb,
      show_eachb, 
      cnt_toa,
        show_toa,   
      cnt_tob,
        show_tob, 
      cnt_dis,
      show_dis,
      ad_seg_out ,
      ad_seg_en,
      time_avg
      );

    /*
    0 å©æ°¬å§? bce
    1 ç» ï¼æé?
    2 éæ»æº? pc
    3 éåªçé®? pnc
    4 é?îç²¯ pay
    5 æµ¼æ°¬æ? mem
    6
    */
    always @(posedge clk)begin

      led[0] = led_cnt; // count
       buzzer = bce_buzzer;

      case(view)
        0: begin
          seg_out = bce_seg_out;
          seg_en = bce_seg_en;
        end
        1: begin
          seg_out = ad_seg_out;
          seg_en =ad_seg_en; 
        end
        2: begin
          seg_out = pc_seg_out;
          seg_en = pc_seg_en;
          //buzzer = pcv_buzzer;
          //buzzer = buzzer_clk;
        end
        3: begin
          seg_out = pn_seg_out;
          seg_en = pn_seg_en;
        end
        4:begin
          seg_out = seg_outs;
          seg_en = seg_ens;
          led[1] = led_p;
        end
        5 :begin
          seg_out = mm_seg_out;
          seg_en = mm_seg_en;
        end

      endcase
     end
     
     always @(posedge clk)begin
       
       //éµæ³ç´å??éå® ç¹éã§î¸éåæ?
        if(view == 0 && sw[23]) begin
            view <= 1;
        end else if(view == 1 && ~sw[23])begin
            view <= 0;
        end

       //æµ¼æ°¬æ?
        else if (view == 0 && sw[22]) 
          view <= 5;
        else if (view == 5 && ~sw[22])
          view <= 0;

        else begin
          //éæ»æº?
          if (view == 0 && bt_link[2]) begin
            view <= 2;
          end
          
          else if (view == 2 && bt_link[2]) begin
            view <= 0;
          end

          //ç»è?ç´? æ©æ¶åéå?é?½ºå§¸é¬?
          else if (view == 0 && bt_link[3]) begin
            view <= 3;
          end

          else if (view == 3 && bt_link[2]) begin
            view <= 0;
          end

          //é?îç²¯
          else if (view == 3 && num_correct) begin
            view <= 4;
          end

          else if (view == 4) begin
            if (rst || state_s == 15)
              view <= 0;
          end

        end  
      end
endmodule