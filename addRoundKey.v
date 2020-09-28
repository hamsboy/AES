// Milos Trbic | Hamidou Diallo
// AES Capstone - Joseph Decuir
// Updated: 9/15/2020
// addRoundKey Module. This function will conduct the add round key function 
// of a single round of AES encrypt. It will take in the 128-bit data, XOR it
// with the encryption key, and produce the 128-bit state.
//
// UPDATES: Fixed errors with testbench, removed assigning state to 0 when there is no valid

module addRoundKey
	#(
	parameter KEY_WIDTH = 128,		// Can be either 128 or 256 bit
	parameter DATA_WIDTH = 128		// Size of data, 128 bit = 0x80 in hex
	)
	(
	input addRoundKey_valid_in, 								// Valid bit. When high, data is valid and should be processed.
	input wire [DATA_WIDTH-1:0] addRoundKey_data_in, 	// Plaintext or state block data to be processed
	input wire [KEY_WIDTH-1:0] addRoundKey_key_in,		// Encryption key
	output reg [DATA_WIDTH-1:0] addRoundKey_data_out,  // Block data which has gone through addRoundKey function
	output reg addRoundKey_valid_out 						// Valid bit. When high, data is valid and can be used in another function.	
	);																	// end signals

	always @(*) begin
		if (addRoundKey_valid_in) begin
			addRoundKey_data_out = addRoundKey_data_in ^ addRoundKey_key_in;
		end
		addRoundKey_valid_out = addRoundKey_valid_in;
	end
endmodule


//
//module addRoundKey_testbench();
//   wire [127:0] data;
//	wire [127:0] key;
//	wire [127:0] out;
//
//	assign data = 128'h54776f204f6e65204e696e652054776f; // First slide from testing doc
//	assign key = 128'h5468617473206d79204b756e67204675;
//
//
//	addRoundKey dut ( .addRoundKey_valid_in(1'b1),
//							.addRoundKey_data_in(data),
//							.addRoundKey_key_in(key),
//							.addRoundKey_data_out(out),
//							.addRoundKey_valid_out()
//							);				
//
//endmodule
