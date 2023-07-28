`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/27 16:29:30
// Design Name: 
// Module Name: FC_84to10_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FC_84to10_tb();

reg clk, rst, start;
wire [31:0] dout;
FC_84to10 DUT(clk, rst, start,dout);
always #3 clk = ~clk;

initial begin
clk = 0; rst = 0; start = 0;
#99; 
#15 rst = 1;
#15 rst = 0;
#6 start = 1;
#6 start = 0;
#300;
end

endmodule
