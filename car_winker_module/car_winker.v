`timescale 1ps/1ps

module car_winker(
	input clk, reset_n,
	input left_winker,
	input right_winker,
	input off,
	output o_standby,
	output o_left_winker,
	output o_right_winker,
	output reg o_finish_mode,
	output o_right_led,
	output o_left_led
	//output reg or_num_cnt
);
localparam i_standby = 2'b00; // 대기모드
localparam i_left_winker = 2'b01; // 왼쪽 지시등 명령
localparam i_right_winker = 2'b10; //오른쪽 지시등 명령
localparam i_finish = 2'b11; // 지시등 점멸 off 명령

wire finish_mode;
reg [1:0] current_mode;
reg [1:0] next_mode;


always@(posedge clk or negedge reset_n) begin // clk positive에서 명령 받기 위해,리셋
	if(!reset_n) begin
		current_mode <= i_standby;
	end else begin
		current_mode <= next_mode;
	end
end

always@(*) begin // 모드 전환
	next_mode = i_standby; // 이따 삭제해볼것 래치방치
	case(current_mode)
		i_standby: if(left_winker) // 대기모드일경우 왼쪽 지시등 명령
			next_mode = i_left_winker;
		i_standby: if(right_winker) // 대기모드일경우 오른쪽 지시등 명령
			next_mode = i_right_winker;	
		i_left_winker: 
			if(finish_mode)  // 종료 
			next_mode = i_finish;
			else if (right_winker)
			next_mode = i_right_winker;
			else
			next_mode = i_left_winker; //유지하도록 설정
		i_right_winker: 
			if(finish_mode) //종료
			next_mode = i_finish;
			else if (left_winker)
			next_mode = i_left_winker;
			else
			next_mode = i_right_winker;	 // 유지하도록 설정
		i_finish: next_mode = i_standby; //대기 모드 전환
		
	endcase	
end

always@(*) begin // 종료 모드를 waveform 상에서 확인하기 위해
	o_finish_mode = 0; //없애보기 래치방지
	case(current_mode)
		i_finish: o_finish_mode = 1;
	endcase
end

assign o_standby = (current_mode == i_standby); // 출력확인
assign o_left_winker = (current_mode == i_left_winker); // 출력확인
assign o_right_winker = (current_mode == i_right_winker); // 출력확인


assign o_right_led = clk & o_right_winker;
assign o_left_led = clk & o_left_winker;

reg [7:0] num_cnt;

always @(
	posedge 
	o_right_winker or 
	o_left_winker or
	o_finish_mode or
	negedge reset_n) begin
    if(!reset_n) begin
        num_cnt <= 0;  
    end else if (finish_mode) begin
        num_cnt <= 0; 
    end else if (o_left_winker | o_right_winker) begin
        num_cnt <= num_cnt + 1;
	end
end

reg [2:0] off_in;
always@(posedge off) begin
	if (o_left_winker | o_right_winker) begin 
		off_in = 1;
	end
end
assign finish_mode = off_in;

endmodule