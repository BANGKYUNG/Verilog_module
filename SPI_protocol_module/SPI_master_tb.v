//작성자 : 방경민
//모듈 역할 : SPI 통신 모듈 
//설계 목표 : SPI MASTER 모듈 TB용 input data를 slave에 보낸 가상 MISO 데이터 환경을 만들어 slave에서 보내온 MISO와 
//input data의 비교 역할을 수행하고 웨이브 폼상에서 확인

`timescale 1ns/1ps
module SPI_master_tb;
    reg load;
    reg start;
    reg clk;
    reg [7:0] i_data;
    reg cpol;
    reg cpha;
    reg MISO;
    wire SCLK;
    wire slave;
    wire MOSI;
    wire slave_start;
    wire [7:0] data_read;
    integer i;



reg [7:0] r_MOSI;
reg [7:0] r_MISO;

integer j;

always
    #2 clk = ~clk; //기본 클럭 생성
initial begin
    test(); //추후 CPOL,CPHA를 통해 4가지 모드를 테스트하기 위해 task 구문으로 생성및테스트
end

task test();
begin
    clk = 0;
    cpol = 0;
    cpha = 0;
    i_data = 'ha5; //master에 전송할 data 
    start = 1;
    r_MISO = 'hba; //slave에서 전송될 data
    @(posedge clk)
    load = 1;
$strobe("%d  \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t%b \t%b +ve clk, idel state",$time,clk,SCLK,slave,cpol,cpha,load,MOSI,i_data,data_read,MISO,slave_start);
    @(negedge clk)
    load = 0;
    start = 0;
    for(j=0; j <= 7; j = j + 1) begin //상승엣지 마다 index를 활용하여 slave에서 전송해오는 MISO데이터를 가상으로 생성( 검증하기 위함)
        @(posedge clk)
        MISO = r_MISO[j];
        if(j==0)
            r_MOSI[j] = MOSI;
            $display("found = %h",r_MOSI);
$strobe("%d  \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t%b \t%b +ve clk, idel state",$time,clk,SCLK,slave,cpol,cpha,load,MOSI,i_data,data_read,MISO,slave_start);
        @(negedge clk)
        @(posedge clk)
$strobe("%d  \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t%b \t%b +ve clk, idel state",$time,clk,SCLK,slave,cpol,cpha,load,MOSI,i_data,data_read,MISO,slave_start);
        @(negedge clk)
        if(j!=7)  
            r_MOSI[j+1]=MOSI;
            $display("found = %h",r_MOSI);
    end

    for(i=0; i <= 7; i=i+1) begin //데이터 비교 검증을 위한 테스트 구문
        if(data_read[i] != r_MISO[i]) begin
            $display(" [%d]data error, r_MISO = %b, data_read = %b",i,r_MISO[i],data_read[i]);
        end else begin
            $display(" [%d]data mach, r_MISO = %b, data_read = %b",i,r_MISO[i],data_read[i]);
        end
    end


end    
endtask

SPI_master u_SPI_master(
    .clk (clk),
    .start (start),
    .load (load),
    .i_data (i_data),
    .cpol (cpol),
    .cpha (cpha),
    .MISO (MISO),

    .SCLK (SCLK),
    .MOSI (MOSI),
    .data_read (data_read),
    .slave_start (slave_start)
);
endmodule