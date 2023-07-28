`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/27 14:25:12
// Design Name: 
// Module Name: FC_84to10
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


module FC_84to10(clk, rst, start,dout);
input clk, rst, start;
output[31:0] dout;
reg [6:0] addr_in;
reg [9:0] addr_w;
reg [3:0] addr_b, addr_result;
reg [9:0] addr_mul;
wire signed [15:0] out_in, out_w, out_b;
reg [6:0] cnt_in;
reg [9:0] cnt_w;
reg wea_w, wea_b;
reg [31:0] din_mul, din_result;
wire [31:0] data_out, dout_mulreg;
in_84 u0(.clka(clk), .addra(addr_in), .douta(out_in));
weights_840 u1(.clka(clk), .addra(addr_w), .douta(out_w));
bias_10 u2(.clka(clk), .addra(addr_b), .douta(out_b));
mult_gen_0 u3(.CLK(clk), .A(out_in), .B(out_w), .P(data_out));
mul_reg10 u4(.clka(clk), .wea(wea_w), .addra(addr_mul), .dina(din_mul), .douta(dout_mulreg));
result u5(.clka(clk), .wea(wea_b), .addra(addr_result), .dina(din_result), .douta(dout));

reg [31:0] dout_mul;
reg [2:0] state;
localparam IDLE = 3'd0, FC_1 = 3'd1, FC_2 = 3'd2, BIAS = 3'd3, DONE = 3'd4;


//state
always@(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        case(state)
             IDLE : if(start) state <= FC_1; else state <= IDLE;
             FC_1 :if(addr_w == 839) state <= BIAS; else state <= FC_1;
             BIAS : if(addr_b == 9) state <= DONE; else state <= BIAS;
             DONE : state <= IDLE;
             default : state <= IDLE;
             endcase
end
// input 
always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_in <= 7'd0;
    else
        case(state)
            FC_1 :if(addr_in == 83) addr_in <= 0; else addr_in <= addr_in + 1'd1;
            default : addr_in <= 0;
            endcase
end
// weights
always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_w <= 7'd0;
    else
        case(state)
            FC_1 :if(addr_w == 839) addr_w <= 0; else addr_w <= addr_w + 1'd1;
            default : addr_w <= 0;
            endcase
end

// Multiplier sum
always@(posedge clk or posedge rst)
begin
    if(rst)
        dout_mul <= 32'd0;
    else
        case(state)
            FC_1 :if(addr_in == 83) dout_mul <= 32'd0; else dout_mul <= dout_mul + data_out;
            default : dout_mul <= 32'd0;
            endcase
end

// 10 dout_mul reg
always@(posedge clk or posedge rst)
begin
    if(rst)
        din_mul <= 32'd0;
    else
        case(state)
            FC_1 :if(addr_in == 83) din_mul <= dout_mul; else din_mul <= din_mul;
            default : din_mul <= 32'd0;
            endcase
end

// 10 dout_mul addr
always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_mul <= 10'd0;
    else
        case(state)
            FC_1 :if(addr_in == 83 && addr_w != 10'd839 ) addr_mul <= addr_mul + 1'd1;else if (addr_w == 10'd839 ) addr_mul <= 10'd0; else addr_mul <= addr_mul; 
            BIAS : if(addr_b == 9) addr_mul <= 10'd0;  else addr_mul <= addr_mul + 1'd1;
            default : addr_mul <= 10'd0;
            endcase
end

// wea_w
always@(posedge clk or posedge rst)
begin
    if(rst)
        wea_w <= 0;
    else
        case(state)
            FC_1 : if(addr_w == 839) wea_w <= 0; else wea_w <= 1;
            default : wea_w <= 0;
            endcase
end
//wea_b
always@(posedge clk or posedge rst)
begin
    if(rst)
        wea_b <= 0;
    else
        case(state)
            BIAS : if(addr_b == 9) wea_b <= 0; else wea_b <= 1;
            default : wea_b <= 0;
            endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_b <= 4'd0;
    else
        case(state)
            BIAS :if(addr_b == 9) addr_b <= addr_b; else addr_b <= addr_b + 1'd1;
            default : addr_b <= 0;
            endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_result <= 4'd0;
    else
        case(state)
            BIAS :if(addr_result == 9) addr_result <= addr_result; else addr_result <= addr_result + 1'd1;
            default : addr_result <= 0;
            endcase
end


always@(posedge clk or posedge rst)
begin
    if(rst)
        din_result <= 32'd0;
    else
        case(state)
            BIAS :if(addr_b == 9) din_result <= din_result; else din_result <= dout_mulreg + out_b;
            default : din_result <= 32'd0;
            endcase
end


endmodule
