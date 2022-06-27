//작성자 : 방경민
//모듈 역할 : UART RX 모듈 input serial 값을 비트 단위로 읽어 output하는 모듈
//설계 목표 : 비트단위를 clk를 활용하여 읽고 저장하여 out하고 모드를 변경

`timescale 1ns/1ps
//100Mhz /115200 baud rate, 입력 serial값을 읽어 저장하여 output하는 rx_module 
module RX_MODULE #(parameter BIT_CLK_PER = 868)
(
  input  i_reset_n,
  input  i_clk,
  input  i_rx_serial,
  output reg o_rx_valid,
  output reg [7:0] o_rx_byte,
  output reg [7:0] o_rx_byte_t
);

localparam standby_bit = 3'b000;  //RX 모듈에서 사용할 FSM 선언 (외부 변경X)
localparam rx_start_bit= 3'b001;
localparam rx_data_bit = 3'b010;
localparam rx_stop_bit = 3'b011;

reg [9:0] r_clk_cnt; //클럭 카운트
reg [2:0] r_index; //DATA값 읽을때 사용할 인덱스
reg [2:0] r_c_status; //Start , data, stop 비트 상태 저장

always@(posedge i_clk or negedge i_reset_n) begin
  if(!i_reset_n) begin  //리셋 설정
    r_c_status <= 3'b000;
    o_rx_valid <= 0;
  end else begin
    case(r_c_status) 
      //대기상태 동작
      standby_bit : begin
        o_rx_valid <=0 ; //변수값 초기화
        r_clk_cnt <=0 ;
        r_index <=0 ;
        if(i_rx_serial == 1'b0) begin // standby에서 rx_serial 비트 0 입력시 start 비트 상태로 변경
          r_c_status <= rx_start_bit;
        end else
          r_c_status <= standby_bit; // 유지 
      end
      //스타트비트 case
      rx_start_bit : begin
        if(r_clk_cnt == (BIT_CLK_PER/2)-1) begin
          if(i_rx_serial == 1'b0) begin // 스타트비트 중간지점 and 시리얼 rx신호 0일경우
            r_clk_cnt <= 0; //cnt 초기화
            r_c_status <= rx_data_bit; // 데이터 수신 모드 변경
          end 
          else begin
            r_c_status <= standby_bit;
          end
          
        end else begin
          r_clk_cnt <= r_clk_cnt + 1;  // 1/2클럭까지 clk 카운트
          r_c_status <= rx_start_bit; //유지
          end
      end
      //data 수신 case
      rx_data_bit: begin 
        if(r_clk_cnt < BIT_CLK_PER-1) begin //지정 clk값까지 카운트
          r_clk_cnt <= r_clk_cnt + 1;
          r_c_status <= rx_data_bit;
        end else begin
          r_clk_cnt <= 0;
          o_rx_byte_t <= {o_rx_byte_t[7:0], i_rx_serial}; //쉬프트 기능으로 저장한 값
          o_rx_byte[r_index] <= i_rx_serial;  // 인덱스 기능으로 순차 저장한 값
          if( r_index < 7) begin 
            r_index <= r_index + 1;
            r_c_status <= rx_data_bit;
          end else begin
            r_index <=0;
            r_c_status <= rx_stop_bit;
          end
        end 
      end
      rx_stop_bit: begin  
        if(r_clk_cnt < BIT_CLK_PER-1) begin
          r_clk_cnt <= r_clk_cnt + 1;
          r_c_status <= rx_stop_bit;
        end else begin
          o_rx_valid <= 1;
          r_clk_cnt <= 0;
          r_c_status <= standby_bit;
        end
      end
     
      default: r_c_status <= standby_bit;

    endcase
  end
end

endmodule