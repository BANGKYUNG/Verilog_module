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
reg data_flag = 1;
reg CPOL;
reg CPHA;
reg [7:0] data_buffer;

integer i = 0;
integer count_1 = 0;
integer count_2 = 0;

always@(posedge clk) begin
    if(load) data_buffer = i_data;
    if(count_1 == 17 && data_flag == 1) begin
        slave_start = 0;
        count_1 = 0;
        count_2 = 0;
    end if(i==8) begin
        sampled = 0;
        slave_start = 0;
    end if(start && data_flag) begin
        data_flag = 0;
        count_1 = 0;
        count_2 = 0;
        CPOL = cpol;
        CPHA = cpha;
        i = 0;
    end if(!data_flag) begin
        if(count_1 ==0) begin
            SCLK = CPOL;
            count_1 = count_1 + 1;
            sampled = 0;
            if(!CPHA) begin
                MOSI = data_buffer[0];
                count_2 = count_2 + 1;
            end
        end else begin

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
        // data read, write
        if(sampled == 1) begin
            if(CPHA) begin // CPHA =1 write positive clk, read negative clk 
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
            if(!CPHA) begin //CPHA =0 write negative clk, read positive clk
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