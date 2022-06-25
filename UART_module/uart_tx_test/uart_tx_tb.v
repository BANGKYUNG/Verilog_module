`timescale 1ns/1ps
//100Mhz /115200 baud rate
module uart_tx_tb;
  parameter C_BIT_CLK_PER = 868;
  parameter C_PERIOD_NS = 10;
  localparam bit_time =8680;

  reg r_reset_n;
  reg r_clk = 0;
  reg r_tx_vaild = 0;
  wire w_tx_active;
  wire w_tx_serial;
  reg [7:0] r_tx_byte;
  wire w_done;


  TX_MODULE #(.BIT_CLK_PER(C_BIT_CLK_PER)) U_TX_MODULE(
    .i_reset_n(r_reset_n),
    .i_clk(r_clk),
    .i_tx_valid(r_tx_vaild),
    .i_tx_byte(r_tx_byte),
    .o_tx_active(w_tx_active),
    .o_tx_serial(w_tx_serial),
    .o_done(w_done)
  );
    
  always
    #(C_PERIOD_NS/2) r_clk <= ~r_clk;
  
  // Main Testing:
  initial begin
    // Tell UART to send a command (exercise TX)
    r_reset_n = 1;
    r_clk = 0;
    # 10
	  r_reset_n = 0;
    # 10
	  r_reset_n = 1;
    # 10
    
    @(posedge r_clk);
   
    r_tx_vaild   <= 1'b1;
    r_tx_byte <= 8'b01101110;
    #50
    r_tx_vaild <= 1'b0;
    wait(w_done)

    @(posedge r_clk);
    r_tx_vaild   <= 1'b1;
    r_tx_byte <= 8'b01111111;
    #50
    r_tx_vaild <= 1'b0;
    wait(w_done)

    $finish();
    end
  
 
  
endmodule
