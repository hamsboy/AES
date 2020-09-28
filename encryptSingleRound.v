// Milos Trbic
// AES Capstone - Joseph Decuir
// Updated: 9/16/2020
// Single Round Module. This function will execute a single round of AES encrypt,
// combining the lower level modules shiftRow, SubByte_MixColumn, and AddRoundKey.
//
// UPDATES: 



module encryptSingleRound  
	#(
	parameter KEY_WIDTH = 128,					// size of key, either 128 or 256 bit
	parameter DATA_WIDTH = 128,				// size of data, always 128 bit
	parameter ROM_WIDTH = 20					// Width of memory element, i.e. M20k has 20 bit width
	)
	(
	input keyLen,
	input clk,
	input rst,										// Active low
	input round_valid_in, 						// Valid bit in. When high, data is valid and should be processed
	input wire [DATA_WIDTH-1:0] state_in, 	// Plaintext block data to be ecrypted
	input wire [KEY_WIDTH-1:0] prev_key, 
	input wire [KEY_WIDTH-1:0] key_in,		// Key used to encrypt plaintext data
	output wire [DATA_WIDTH-1:0] state_out,// Block data which has gone through a single round of encryption
	output wire round_valid_out 				// Valid bit out. When high, data is valid and can be used in another function.	
	);	

	// end signals
	// intermediete variables
	// NOTE: subByte and mixColumn layers are combined for optimization
	wire [DATA_WIDTH-1:0] state1; 	// connect the data from first layer to second  
	wire [DATA_WIDTH-1:0] state2;		// connect data from second layer to third
	reg [DATA_WIDTH-1:0] temp_key;
	always @(*) begin
	  if(keyLen) begin
	    temp_key=prev_key;
	  end else begin
	      temp_key=key_in;
	  end
	
	end

	wire round_valid1;	// connect valid bit from first layer to second
	wire round_valid2;	// connect valid bit from second layer to third
	
	// Call lower level modules
	
	// shiftRow
	shiftRow #(DATA_WIDTH) sr	(
										.shiftRow_valid_in(round_valid_in),
										.shiftRow_data_in(state_in),
										.shiftRow_data_out(state1),
										.shiftRow_valid_out(round_valid1)
										);
	
	// subByte_mixColumn optimized module
	subByte_mixColumn #(DATA_WIDTH, ROM_WIDTH) sb_mc	(	
																		.clk(clk),
																		.rst(rst),
																		.sb_mc_valid_in(round_valid1),
																		.state_in(state1),
																		.stateOut(state2),
																		.sb_mc_valid_out(round_valid2)
																		);
	
	
													
	

	// addRoundKey
	addRoundKey #(KEY_WIDTH, DATA_WIDTH) ark	(	
															.addRoundKey_valid_in(round_valid1),
															.addRoundKey_data_in(state2),
															.addRoundKey_key_in(temp_key),
															.addRoundKey_data_out(state_out), 
															.addRoundKey_valid_out(round_valid_out)
															);

	
endmodule


// Simple testbench
//module encryptSingleRound_testbench();
//   reg clk;
//	reg rst;
//	wire v_in;
//	wire [127:0] data;
//	wire [127:0] key;
//	wire [127:0] out;
//
//	assign data = 128'h00102030405060708090a0b0c0d0e0f0; // First slide from testing doc
//	assign key = 128'hd6aa74fdd2af72fadaa678f1d6ab76fe;
//	
//	// Set up the clock
//	parameter CLOCK_PERIOD = 100;	// simulating a toggling clock
//	initial clk = 1;
//
//	always begin
//		#(CLOCK_PERIOD/2) clk = ~clk;	// clock toggle
//	end
//	
//	// add reset
//	initial begin 
//		rst = 0;
//		#100
//		rst = 1;
//	end
//
//
//	encryptSingleRound dut(		.clk(clk),
//										.rst(rst),
//										.round_valid_in(1'b1),
//										.state_in(data),
//										.key_in(key),
//										.state_out(out),
//										.round_valid_out()
//										);				
//
//endmodule


	