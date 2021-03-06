//작성자 : 방경민
//모듈 역할 : UART TX 모듈 input Byte 값을 읽어 저장하는 모듈
//설계 목표 : 비트단위를 clk를 활용하여 읽고 저장하여 모드를 변경

`timescale 1ns/1ps
//100Mhz /115200 baud rate , 입력 byte값을 읽어 저장하는 TX_module
module TX_MODULE #(parameter BIT_CLK_PER = 868)
(
  input  i_reset_n,
  input  i_clk,
  input  i_tx_valid,
  input [7:0] i_tx_byte,
  output reg o_tx_active,
  output reg o_tx_serial,
  output reg o_done
);

localparam standby_bit = 3'b000; //RX 모듈에서 사용할 FSM 선언 (외부 변경X)
localparam tx_start_bit= 3'b001;
localparam tx_data_bit = 3'b010;
localparam tx_stop_bit = 3'b011;


reg [9:0] r_clk_cnt;
reg [2:0] r_index; //DATA값 읽을때 사용할 인덱스
reg [2:0] r_c_status; //Start , data, stop 비트 상태 저장
reg [7:0] r_tx_data;  //데이터 순차 저장시 사용할 regi

always@(posedge i_clk or negedge i_reset_n) begin 
  if(!i_reset_n) begin //초기화
    r_c_status <= 3'b000;
    o_done <= 0;
  end else begin
    case(r_c_status)
      //스탠바이 비트 동작
      standby_bit : begin
        o_tx_serial <= 1'b1;
        r_clk_cnt <= 0;
        r_index <= 0;
        o_done <=1'b0;
        if(i_tx_valid == 1'b1) begin //TX 유효input - tx active 활성화
        o_tx_active <= 1;
        r_tx_data <= i_tx_byte;
        r_c_status <= tx_start_bit;
        end else begin // 노이즈 발생할 수 있으니 유지
          r_c_status <= standby_bit;
        end
      end

      tx_start_bit : begin
        o_tx_serial <= 1;
        if(r_clk_cnt < (BIT_CLK_PER/2)-1) begin //스타트 비트 중간 지점을 읽어 data 읽기모드 변경
          r_clk_cnt <= r_clk_cnt + 1;
          r_c_status <= tx_start_bit;
        end else begin
          r_c_status <= tx_data_bit;
          r_clk_cnt <= 0;
        end
      end

      tx_data_bit : begin
        
        o_tx_serial <= r_tx_data[r_index]; // 순차적으로 8비트값 저장

        if(r_clk_cnt < BIT_CLK_PER-1) begin
          r_clk_cnt <= r_clk_cnt + 1;
          r_c_status <= tx_data_bit;
        end else begin
          r_clk_cnt <= 0;
          if (r_index < 7) begin
            r_index <= r_index + 1;
            r_c_status <= tx_data_bit;
          end else begin
            r_index <= 0;
            r_c_status <= tx_stop_bit;
          end
        end
      end

      tx_stop_bit : begin
        o_tx_serial <= 1;
        if(r_clk_cnt < BIT_CLK_PER-1) begin
          r_clk_cnt <= r_clk_cnt + 1;
          r_c_status <= tx_stop_bit;
        end else begin
          r_c_status <= standby_bit;
          o_done <= 1;
          o_tx_active <= 0;
          r_clk_cnt <= 0;
        end
      end

      default: r_c_status <= standby_bit;
    endcase
  end
end
endmodule 