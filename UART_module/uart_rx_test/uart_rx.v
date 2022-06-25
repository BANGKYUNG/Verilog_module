`timescale 1ns/1ps
//100Mhz /115200 baud rate
module RX_MODULE #(parameter BIT_CLK_PER = 868)
(
  input  i_reset_n,
  input  i_clk,
  input  i_rx_serial,
  output reg o_rx_valid,
  output reg [7:0] o_rx_byte,
  output reg [7:0] o_rx_byte_t
);

localparam standby_bit = 3'b000;
localparam rx_start_bit= 3'b001;
localparam rx_data_bit = 3'b010;
localparam rx_stop_bit = 3'b011;

reg [9:0] r_clk_cnt;
reg [2:0] r_index;
reg [2:0] r_c_status;

always@(posedge i_clk or negedge i_reset_n) begin
  if(!i_reset_n) begin
    r_c_status <= 3'b000;
    o_rx_valid <= 0;
  end else begin
    case(r_c_status)
      //대기상태 동작
      standby_bit : begin
        o_rx_valid <=0 ;
        r_clk_cnt <=0 ;
        r_index <=0 ;
        if(i_rx_serial == 1'b0) begin
          r_c_status <= rx_start_bit;
        end else
          r_c_status <= standby_bit;
      end
      //스타트비트 로직
      rx_start_bit : begin
        if(r_clk_cnt == (BIT_CLK_PER/2)-1) begin
          if(i_rx_serial == 1'b0) begin // 스타트비트 중간지점 and 시리얼 rx신호 0일경우
            r_clk_cnt <= 0; //cnt 초기화
            r_c_status <= rx_data_bit; // 데이터 수신 모드
          end 
          else begin
            r_c_status <= standby_bit;
          end
          
        end else begin
          r_clk_cnt <= r_clk_cnt + 1;
          r_c_status <= rx_start_bit; //유지
          end
      end
      //data 수신 case
      rx_data_bit: begin 
        if(r_clk_cnt < BIT_CLK_PER-1) begin
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