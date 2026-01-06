`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/20 22:08:00
// Design Name: 
// Module Name: ad9781_lut_config
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


module ad9781_lut_config(
	input [7:0]			   delay_value,
	input[9:0]             lut_index,   //Look-up table address
	output reg[23:0]       lut_data     //reg address reg data
);

always@(*)
begin
	case(lut_index)			  
		10'd  0 : lut_data <= {16'h0200 , 8'h00};
		10'd  1 : lut_data <= {16'h0B00 , 8'h00}; //DAC1 FSC
		10'd  2 : lut_data <= {16'h0C00 , 8'h02}; //DAC1 FSC
		10'd  3 : lut_data <= {16'h0D00 , 8'h00}; //AUXDAC1
		10'd  4 : lut_data <= {16'h0E00 , 8'h00}; //AUXDAC1
		10'd  5 : lut_data <= {16'h0F00 , 8'h00}; //DAC2 FSC
        10'd  6 : lut_data <= {16'h1000 , 8'h02}; //DAC2 FSC
        10'd  7 : lut_data <= {16'h1100 , 8'h00}; //AUXDAC2
        10'd  8 : lut_data <= {16'h1200 , 8'h00}; //AUXDAC2
		10'd  9 : lut_data <= {16'h0500 , delay_value};		
		default:lut_data <= {16'hffff,8'hff};
	endcase
end


endmodule 
