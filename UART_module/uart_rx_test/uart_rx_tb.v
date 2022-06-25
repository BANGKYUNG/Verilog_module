`timescale 1ns/1ps
//100Mhz /115200 baud rate
module uart_rx_tb;
  parameter C_BIT_CLK_PER = 868;
  parameter C_PERIOD_NS = 10;
  localparam bit_time =8680;

  reg r_reset_n;
  reg r_clk;
  reg r_rx_serial;
  wire o_rx_valid;
  wire [7:0] o_rx_byte;
  wire [7:0] o_rx_byte_t;

  RX_MODULE #(.BIT_CLK_PER(C_BIT_CLK_PER)) U_RX_MODULE(
    .i_reset_n(r_reset_n),
    .i_clk(r_clk),
    .i_rx_serial(r_rx_serial),
    .o_rx_valid(o_rx_valid),
    .o_rx_byte(o_rx_byte),
    .o_rx_byte_t(o_rx_byte_t)
  );
  //assign w_uart = w_tx_active ? w_tx_serial : 1'b1;
    
  always
    #(C_PERIOD_NS/2) r_clk <= ~r_clk;
  
  // Main Testing:
  initial
    begin
      // Tell UART to send a command (exercise TX)
     
    r_reset_n = 1;
    r_clk =0;
    $display ("check idle [%d]",$time);
    # 10
    	r_reset_n = 0;
    # 10
    	r_reset_n = 1;
    # 10
    
    #50; // 001001100
		r_rx_serial = 1'b0;
		#bit_time;      
		r_rx_serial = 1'b0;
		#bit_time;      
		r_rx_serial = 1'b1;
		#bit_time;      
		r_rx_serial = 1'b0;
		#bit_time;      
		r_rx_serial = 1'b0;
		#bit_time;      
		r_rx_serial = 1'b1;
		#bit_time;      
		r_rx_serial = 1'b1;
		#bit_time;      
		r_rx_serial = 1'b0;
		#bit_time;      
		r_rx_serial = 1'b0;
		#5000;
    
    // Check that the correct command was received
    @(negedge o_rx_valid);
    if(o_rx_byte==8'b00110010) begin
      $display("correct");  
      $display(o_rx_byte);
    end else begin
      $display("wrong");
      end
    #100
    r_rx_serial = 1'b0;
		#bit_time;      
		r_rx_serial = 1'b1;
		#bit_time;      
		r_rx_serial = 1'b1;
		#bit_time;      
		r_rx_serial = 1'b0;
		#bit_time;      
		r_rx_serial = 1'b0;
		#bit_time;      
		r_rx_serial = 1'b1;
		#bit_time;      
		r_rx_serial = 1'b1;
		#bit_time;      
		r_rx_serial = 1'b1;
		#bit_time;      
		r_rx_serial = 1'b0;

    @(negedge o_rx_valid);
    if(o_rx_byte_t==8'b11001110) begin
      $display("correct");  
      $display(o_rx_byte_t);
    end else begin
      $display("wrong");
      end
  $finish();
    end
  
endmodule
