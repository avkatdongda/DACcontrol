`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/17 15:31:23
// Design Name: 
// Module Name: top
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

module top
	(
    //sys
    input                     sys_clk_p,
    input                     sys_clk_n,
    
//    input                     trig_in,
	//spi interface
	output                    clk_spi_ce,
	output                    dac1_spi_ce,
	output                    dac2_spi_ce,
	output                    spi_sclk,
	inout                     spi_sdio,
	input                     spi_sdo,

	//dac input clock from ad9518
	input					   dac1_dco_p,
	input					   dac1_dco_n,
	input					   dac2_dco_p,
	input					   dac2_dco_n,
	//dac1 signals
	output                     dac1_dci_p,	//dac output clock p
	output                     dac1_dci_n,	//dac output clock n
	output[13:0]               dac1_data_p, //dac output data p
	output[13:0]               dac1_data_n, //dac output data n
	//dac2 signals
	output                     dac2_dci_p,	//dac output clock p
	output                     dac2_dci_n,  //dac output clock n
	output[13:0]               dac2_data_p, //dac output data p
	output[13:0]               dac2_data_n  //dac output data n
    );

wire                 rst_n ;
reg [11:0] 			rom1_addr;	
wire [13:0] 		rom1_data;
reg [13:0] 			rom1_data_r;  

reg [11:0] 			rom2_addr;	
wire [13:0] 		rom2_data;
reg [13:0] 			rom2_data_r;   
                             
wire 				clk_50m;
wire                clk_100m;
wire                clk_400m;
wire 				locked;

reg  [17:0]        cycle_num;
wire               config_done;

reg [7:0]           square_wave_counter;
reg [13:0]          square_wave;
reg [13:0]          square_wave_reg;

wire [13:0]		dac1_h ;  //dac data oddr posedge
wire [13:0]		dac1_l ;  //dac data oddr negedge
wire [13:0]		dac2_h ;  //dac data oddr posedge
wire [13:0]		dac2_l ;  //dac data oddr negedge

wire					   dac1_dco_buf ;
wire					   dac2_dco_buf ;

assign rst_n = locked ;
assign dac1_h = square_wave_reg ; //rom1_data_r 
assign dac1_l = square_wave_reg ;  //rom1_data_r 
assign dac2_h = rom2_data_r ;
assign dac2_l = rom2_data_r ;




dac_iobuf dac_iobuf_inst
	(
	 .clk_400m      (clk_400m),
	 .dac1_dco_p	(dac1_dco_p	),
	 .dac1_dco_n	(dac1_dco_n	),
	 .dac2_dco_p	(dac2_dco_p	),
	 .dac2_dco_n	(dac2_dco_n	),
	 .dac1_dci_p	(dac1_dci_p	),	
	 .dac1_dci_n	(dac1_dci_n	),	
	 .dac1_data_p	(dac1_data_p	), 
	 .dac1_data_n	(dac1_data_n	), 
	 .dac2_dci_p	(dac2_dci_p	),	
	 .dac2_dci_n	(dac2_dci_n	),  
	 .dac2_data_p	(dac2_data_p	), 
	 .dac2_data_n	(dac2_data_n	), 
	 .dac1_h 		(dac1_h 		),  
	 .dac1_l 		(dac1_l 		),  
	 .dac2_h 		(dac2_h 		),  
	 .dac2_l 		(dac2_l 		),  
	 .dac1_dco_buf 	(dac1_dco_buf 		),  
	 .dac2_dco_buf 	(dac2_dco_buf 		)  

    );


//DA output sin waveform
always @(negedge dac1_dco_buf or negedge rst_n)
begin
	if (!rst_n)
		rom1_addr <= 0 ;
	else if(config_done)   //config_done
		rom1_addr <= rom1_addr + 1 ;  
    else            
		rom1_addr <= rom1_addr;					
end 

//DA output sin waveform
always @(negedge dac2_dco_buf or negedge rst_n)
begin
	if (!rst_n)
		rom2_addr <= 0 ;
	else if(config_done)     //config_done
		rom2_addr <= rom2_addr + 1 ;             
	else
	    rom2_addr <= rom2_addr;				
end 

always @(negedge dac1_dco_buf or negedge rst_n)
begin
	if (!rst_n)
		cycle_num <= 0 ;
	else if(rom1_addr == 14'd511)
		cycle_num <= cycle_num + 1 ;              
	else
	    cycle_num <= cycle_num;						
end 

reg  square_wave_en;
//DA output sin waveform3
always @(negedge dac1_dco_buf or negedge rst_n)
begin
	if (!rst_n) begin
		square_wave_counter <= 0 ;
		square_wave_en <= 0;
    end
	//else if(config_done)   //config_done
	   else if(square_wave_counter == 8'd199) begin
	         square_wave_counter <= 8'd0;
	         square_wave_en <= 1;
		end else begin
		     square_wave_counter <= square_wave_counter + 1 ; 
		     square_wave_en <= 0; 
		end
//    else begin           
//		square_wave_counter <= square_wave_counter;	
//		square_wave <= square_wave;
//    end				
end


//always @(negedge dac1_dco_buf)
//begin
//    if (!rst_n)
//        square_wave_en <= 0;
//    else if(config_done)  
//        square_wave_en <= ~square_wave_en; 
//end

always @(negedge dac1_dco_buf)
begin
    if (!rst_n)
        square_wave_reg <= 0;
    else if(square_wave_en)  
        //square_wave_reg <= (square_wave_reg==14'h2000)? 14'h0000:14'h2000; 
        square_wave_reg <= 14'h1fff;
    else
        square_wave_reg <= square_wave_reg;
end


ROM ROM1_inst
(
.clka	(dac1_dco_buf), 
.addra	(rom1_addr),
.douta	(rom1_data) 
);

ROM ROM2_inst
(
.clka	(dac2_dco_buf), 
.addra	(rom2_addr), 
.douta	(rom2_data) 
);

always @(negedge dac1_dco_buf)
begin
    	rom1_data_r <= rom1_data ;					
end 

always @(negedge dac2_dco_buf)
begin
    	rom2_data_r <= rom2_data ;					
end 

sys_pll sys_pll_m0
(
	.clk_in1_p(sys_clk_p),
	.clk_in1_n(sys_clk_n),
	.clk_out1(clk_50m),
	.clk_out2(clk_100m),
	.clk_out3(clk_400m),
	.reset(1'b0),
	.locked(locked)
);


//clock and da spi config
dac_config#
(
	.DAC1_DELAY(5'd8), //0-31
	.DAC2_DELAY(5'd8)  //0-31
)	dac_config_inst(
    .clk_100m          (clk_100m),
	.rst			   (~locked		),
	.clk			   (clk_50m		),
	.clk_spi_ce		   (clk_spi_ce	),
	.dac1_spi_ce	   (dac1_spi_ce),
	.dac2_spi_ce	   (dac2_spi_ce),
	.spi_sclk		   (spi_sclk	),
	.spi_sdio		   (spi_sdio	),
	.spi_sdo           (spi_sdo    ),
	
	.config_done       (config_done)
    );


endmodule 
