//작성자 : 방경민
//모듈 역할 : SPI 통신 모듈 
//설계 목표 : CPOL,CPHA를 이용하여 4가지 모드를 사용하여 슬레이브에 데이터 전송방식을 결정
//            테스트는 CPOL=0, CPHA=0의 값으로 기본 클럭 상태 0 & 상승엣지마다 데이터를 읽을 수 있도록 설계
//             input된 데이터 값을 클럭마다 1비트씩 슬레이브에 MOSI데이터로 전송하고 전달된 MISO데이터를 읽는 역할

`timescale 1ns/1ps
module SPI_master(
    input clk,
    input start,
    input load,
    input [7:0] i_data,
    input cpol,
    input cpha,
    input MISO,

    output reg SCLK,
    output reg MOSI,
    output reg [7:0] data_read,
    output reg slave_start);

reg sampled = 1;
reg data_flag = 1; //0으로 변경시 데이터 READ WRITE 신호
reg CPOL; //클럭의 기본 극성을 결정 REG
reg CPHA; //어느 엣지에서 데이터를 전송할지 결정할 REG
reg [7:0] data_buffer; // 데이터 저장 REG

integer i = 0;
integer count_1 = 0;
integer count_2 = 0;

always@(posedge clk) begin
    if(load) data_buffer = i_data; //load 신호를 받아서 버퍼 레지에 입력 데이터를 입력
    if(count_1 == 17 && data_flag == 1) begin
        slave_start = 0;
        count_1 = 0;
        count_2 = 0;
    end if(i==8) begin //데이터 읽고 스기 완료시 초기화
        sampled = 0;
        slave_start = 0;
    end if(start && data_flag) begin //start, flag신호가 있을시 기본 설정 set
        data_flag = 0;
        count_1 = 0;
        count_2 = 0;
        CPOL = cpol;
        CPHA = cpha;
        i = 0;
    end if(!data_flag) begin //MAIN) flag 신호 0 (read&write on) 상태에서 SCLK을 생성 CPHA=0 데이터버퍼 0 배열값을 MOSI에 입력
        if(count_1 ==0) begin
            SCLK = CPOL;
            count_1 = count_1 + 1;
            sampled = 0;
            if(!CPHA) begin
                MOSI = data_buffer[0];
                count_2 = count_2 + 1;
            end
        end else begin //CPOL값을 확인하여 SCLK 기본상태와 slave 시작점을 결정

            SCLK = ~SCLK;

            if(count_1==1) begin
                if(CPOL==1) begin 
                    sampled = 0;
                end else begin
                    slave_start = 1;
                    sampled = 1;
                end
            count_1 = count_1 + 1;
            end else begin
                if(sampled==0) begin
                    sampled = 1;
                    slave_start = 1;
                end else begin
                    count_1 = count_1 + 1;
                end
            end
        end
        // data read, write 구문
        if(sampled == 1) begin
            if(CPHA) begin // CPHA =1 write 상승 clk, read 하강 clk 
                if(count_2 == 2) begin
                    i = i + 1;
                    count_2 = 0;
                end

                if(SCLK == 1) begin
                    MOSI = data_buffer[i];
                    count_2 = count_2 + 1;                    
                end 
                if(SCLK == 0) begin
                    data_read[i] = MISO;
                    data_buffer[i] = MISO;
                    count_2 = count_2 + 1;    
                end
            end 
            if(!CPHA) begin //CPHA =0 write 하강 clk, read 상승 clk
                if(count_2 == 2) begin
                    i = i + 1;
                    count_2 = 0;
                end

                if(SCLK==1) begin
                    data_read[i] = MISO;
                    data_buffer[i] = MISO;
                    count_2 = count_2 + 1;
                end
                if(SCLK==0) begin
                    MOSI = data_buffer[i];
                    count_2 = count_2 + 1;
                end
            end
        end if(count_1 == 17) begin
            data_flag <= 1;
        end
    


    end
end
endmodule