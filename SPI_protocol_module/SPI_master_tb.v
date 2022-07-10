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
    #2 clk = ~clk;
initial begin
    test();
end

task test();
begin
    clk = 0;
    cpol = 0;
    cpha = 0;
    i_data = 'ha5;
    start = 1;
    r_MISO = 'hba;
    @(posedge clk)
    load = 1;
$strobe("%d  \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t%b \t%b +ve clk, idel state",$time,clk,SCLK,slave,cpol,cpha,load,MOSI,i_data,data_read,MISO,slave_start);
    @(negedge clk)
    load = 0;
    start = 0;
    for(j=0; j <= 7; j = j + 1) begin
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

    for(i=0; i <= 7; i=i+1) begin
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