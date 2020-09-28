// Milos Trbic
// AES Capstone - Joseph Decuir
// Updated: 9/16/2020
// Sbox Module, which is the lookup table to be used for SubByte
//
// UPDATES: Added clock, reset, and valid bit (Removed as of 9/16)
// Completely removed case statement and uses LUT entirely
// COMPLETED

module sbox
	#(
	parameter ROM_WIDTH = 20			// Width of memory element, i.e. M20k has 20 bit width
	)
	(
	input [7:0] sbox_data_in,			// 8-bit/1-byte input from state
	output reg [7:0] sbox_data_out	// 1-byte output, reg because it stores a value
	);
	
	// 20-bit data, 256 rows in data_ROM
	reg [ROM_WIDTH-1:0] data_ROM [0:255];
	// Temporary 20 bit value from ROM because we onyl need the first 8 bits (mul1)
	reg [ROM_WIDTH-1:0] data_temp;

	initial $readmemh("C:\\Users\\youma\\Documents\\AES\\rom_20.txt", data_ROM); 
	
	always @(*) begin
		data_temp = data_ROM[sbox_data_in];
		sbox_data_out = data_temp[ROM_WIDTH-1:ROM_WIDTH-8];
	end

endmodule


// Simple Testbench
//module sbox_testbench();
//   wire [7:0] data;
//	wire [7:0] out;
//	reg clk;
//
//	assign data = 128'hc2;
//	// Expected output = 25
//	
//	// Set up the clock
//	parameter CLOCK_PERIOD = 100;	// simulating a toggling clock
//	initial clk = 1;
//
//	always begin
//		#(CLOCK_PERIOD/2) clk = ~clk;				// clock toggle
//	end
//
//	sbox dut(.sbox_data_in(data), .sbox_data_out(out));
//
//endmodule

