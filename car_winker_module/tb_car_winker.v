`timescale 1ps/1ps
module tb_car_winker;
	reg clk, reset_n;
	reg left_winker;
	reg right_winker;
	reg off;
	wire o_standby;
	wire o_left_winker;
 	wire o_right_winker;
   	wire o_finish_mode;
	wire o_right_led;
	wire o_left_led;
	//wire reg or_num_cnt;


always
	#5 clk = ~clk;

initial begin
	reset_n = 1;
	clk = 0;
	left_winker = 0;
	right_winker = 0;
$display ("check idle [%d]",$time);
# 100
	reset_n = 0;
# 10
	reset_n = 1;
# 10

@(posedge clk);
$display ("check standy [%d]",$time);
wait(o_standby);
$display ("left on![%d]",$time);
		left_winker= 1;
@(posedge clk);
		left_winker = 0;
#100

@(posedge clk);
$display ("right on![%d]",$time);
		right_winker= 1;
@(posedge clk);
		right_winker = 0;

#50

$display(o_finish_mode,left_winker,right_winker);

@(posedge clk);
$display ("left on![%d]",$time);
		left_winker= 1;
@(posedge clk);
		left_winker = 0;

#100
@(posedge clk);
		off = 1;
wait(o_finish_mode);
# 100
$display("off! [%d]", $time);
$finish;

end

car_winker u_car_winker(
	.clk (clk),
	.reset_n (reset_n),
	.left_winker(left_winker),
	.right_winker(right_winker),
	.o_standby(o_standby),
	.o_left_winker(o_left_winker),
	.o_right_winker(o_right_winker),
	.o_finish_mode(o_finish_mode),
	.o_right_led(o_right_led),
	.o_left_led(o_left_led),
	.off(off)
);



endmodule