// Vi Ho | Milos Trbic | Hamidou Diallo
// AES Capstone - Joseph Decuir
// Updated: 9/15/2020
// ShiftRow Module. This function will conduct the shift row function 
// of a single round of AES encrypt. It will take in the 128-bit state
// and produce a 128-bit output.
//
// UPDATES: Created shiftRowTest.tv file and wrote testbench (testbench debugged)
// Added valid bits, parameters

module shiftRow
	#(
	parameter DATA_WIDTH = 128								// Size of data, 128 bits constant
	)
	(
	input shiftRow_valid_in, 								// Valid bit. When high, data is valid and should be processed.
	input wire [DATA_WIDTH-1:0] shiftRow_data_in, 	// ShiftRow block data to be processed.
	output reg [DATA_WIDTH-1:0] shiftRow_data_out,  // Block data which has gone through shiftRow function
	output reg shiftRow_valid_out 						// Valid bit. When high, data is valid and can be used in another function.	
	);
	
	always @(*) begin
		if (shiftRow_valid_in) begin
			shiftRow_data_out[127:120] = shiftRow_data_in[127:120];  
			shiftRow_data_out[119:112] = shiftRow_data_in[87:80];
			shiftRow_data_out[111:104] = shiftRow_data_in[47:40];
			shiftRow_data_out[103:96]  = shiftRow_data_in[7:0];
				
			shiftRow_data_out[95:88]	= shiftRow_data_in[95:88];
			shiftRow_data_out[87:80] 	= shiftRow_data_in[55:48];
			shiftRow_data_out[79:72] 	= shiftRow_data_in[15:8];
			shiftRow_data_out[71:64] 	= shiftRow_data_in[103:96];
				
			shiftRow_data_out[63:56] 	= shiftRow_data_in[63:56];
			shiftRow_data_out[55:48] 	= shiftRow_data_in[23:16];
			shiftRow_data_out[47:40] 	= shiftRow_data_in[111:104];
			shiftRow_data_out[39:32] 	= shiftRow_data_in[71:64];
			
			shiftRow_data_out[31:24] 	= shiftRow_data_in[31:24];
			shiftRow_data_out[23:16] 	= shiftRow_data_in[119:112];
			shiftRow_data_out[15:8]  	= shiftRow_data_in[79:72];
			shiftRow_data_out[7:0]   	= shiftRow_data_in[39:32];
		end
			
		shiftRow_valid_out = shiftRow_valid_in;
			
	end
endmodule


//// shiftRow testbench
//module shiftRow_testbench();
//	
//	reg [127:0] s_in;
//	wire [127:0] s_out;
//	reg clk;
//	// 128-bit data, 11 rows in shifrRowTest.tv file
//	reg [127:0] testvectors [0:10];
//	integer i;
//	
//	// Set up the clock
//	parameter CLOCK_PERIOD = 100;	// simulating a toggling clock
//	initial clk = 1;
//
//	always begin
//		#(CLOCK_PERIOD/2) clk = ~clk;				// clock toggle
//	end
//	
//	// reference the device under test (shiftRow module)
//	shiftRow dut ( 
//						.shiftRow_valid_in(1'b1), // send a constant high valid bit
//						.shiftRow_data_in(s_in),
//						.shiftRow_data_out(s_out),
//						.shiftRow_valid_out()
//						);
//	
//	initial begin	// embed the test vector
//		$readmemh("shiftRowTest.tv", testvectors); // read in test vectors from .tv file
//		for (i = 0; i < 11; i=i+1)
//			begin
//				s_in = testvectors[i];
//				@(posedge clk);
//			end
//		$stop; 
//	end
//
//endmodule
