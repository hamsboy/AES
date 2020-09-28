// Milos Trbic
// AES Capstone - Joseph Decuir
// Updated: 9/16/2020
// Lower level Subbyte Module. This function will conduct the byte substitution operation
// of AES encrypt on a single byte (8-bits) of data using purely logic rather than LUT
//
// UPDATES: added clock and reset to retrieve Fmax
// Made purely combinational, can still retreive Fmax from "subByteCombinationalOld" file
// COMPLETED
//
// NOTE: Developed based on "Practical Implementation of Rijndael S-Box Using Combinational Logic" paper
//	"Section" comments refers to respective section in paper used to develop respective function

module subByteCombinational
	(
	input [7:0] data_in,
	output reg [7:0] data_out
	);


	// Intermediete logic, based on Figure 3.1
	reg [7:0] init_iso;
	reg [3:0] q, w, q1, w1, x, mul2, mul3;
	
	always @(*) begin
		// Sbox Multiplicative Inversion, Figure 2.1
		init_iso = iso_map(data_in);
		q = init_iso[7:4];
		w = init_iso[3:0];
		
		q1 = mult_lambda(squarer(q));
		w1 = mult_gf2_4({(q ^ w), w});
		
		x = mult_inv_gf2_4(q1 ^ w1);
		
		mul2 = mult_gf2_4({q, x});
		mul3 = mult_gf2_4({(q ^ w), x});
		
		// Affine Transform
		data_out = aff_tf(inv_iso_map({mul2, mul3}));
	end
		
//=========================================================================

	// Functions to be used for SubByte logic implementation

	// Affine Transform, developed from matrix manipulation in Section 1.2
	function [7:0] aff_tf;
		input [7:0] in;
		
		begin
			aff_tf[7] = in[7] ^ in[6] ^ in[5] ^ in[4] ^ in[3];
			aff_tf[6] = in[6] ^ in[5] ^ in[4] ^ in[3] ^ in[2];
			aff_tf[5] = in[5] ^ in[4] ^ in[3] ^ in[2] ^ in[1];
			aff_tf[4] = in[4] ^ in[3] ^ in[2] ^ in[1] ^ in[0];
			aff_tf[3] = in[7] ^ in[3] ^ in[2] ^ in[1] ^ in[0];
			aff_tf[2] = in[7] ^ in[6] ^ in[2] ^ in[1] ^ in[0];
			aff_tf[1] = in[7] ^ in[6] ^ in[5] ^ in[1] ^ in[0];
			aff_tf[0] = in[7] ^ in[6] ^ in[5] ^ in[4] ^ in[0];
			
			aff_tf = aff_tf ^ 8'h63;
		end
	endfunction
	
	// Isomorphic mapping in GF(2^8)
	// Section 2.1
	function [7:0] iso_map;
		input [7:0] q;
		
		begin
			iso_map[7] = q[7] ^ q[5];
			iso_map[6] = q[7] ^ q[6] ^ q[4] ^ q[3] ^ q[2] ^ q[1];
			iso_map[5] = q[7] ^ q[5] ^ q[3] ^ q[2];
			iso_map[4] = q[7] ^ q[5] ^ q[3] ^ q[2] ^ q[1];
			iso_map[3] = q[7] ^ q[6] ^ q[2] ^ q[1];
			iso_map[2] = q[7] ^ q[4] ^ q[3] ^ q[2] ^ q[1];
			iso_map[1] = q[6] ^ q[4] ^ q[1];
			iso_map[0] = q[6] ^ q[1] ^ q[0];
		end
	endfunction
	
	// Inverse isomorphic mapping in GF(2^8)
	// Section 2.1
	function [7:0] inv_iso_map;
		input [7:0] q;
		
		begin
			inv_iso_map[7] = q[7] ^ q[6] ^ q[5] ^ q[1];
			inv_iso_map[6] = q[6] ^ q[2];
			inv_iso_map[5] = q[6] ^ q[5] ^ q[1];
			inv_iso_map[4] = q[6] ^ q[5] ^ q[4] ^ q[2] ^ q[1];
			inv_iso_map[3] = q[5] ^ q[4] ^ q[3] ^ q[2] ^ q[1];
			inv_iso_map[2] = q[7] ^ q[4] ^ q[3] ^ q[2] ^ q[1];
			inv_iso_map[1] = q[5] ^ q[4];
			inv_iso_map[0] = q[6] ^ q[5] ^ q[4] ^ q[2] ^ q[0];
		end
	endfunction
	
	// Squarer in GF(2^4)
	// Section 2.2.2
	function [3:0] squarer;
		input [3:0] data;
		
		begin
			squarer[3] = data[3];
			squarer[2] = data[3] ^ data[2];
			squarer[1] = data[2] ^ data[1];
			squarer[0] = data[3] ^ data[1] ^ data[0];
		end
	endfunction
		
	// Multiplication with constant, lambda, in GF(2^4)
	function [3:0] mult_lambda;
		input [3:0] data;
		
		begin
			mult_lambda[3] = data[2] ^ data[0];
			mult_lambda[2] = data[3] ^ data[2] ^ data[1] ^ data[0];
			mult_lambda[1] = data[3];
			mult_lambda[0] = data[2];
		end
	endfunction

	// Multiplication in GF(2^4)
	// Section 2.2.4, Figure 5
	// Utilizes mult_gf2 and mult_phi functions
	function [3:0] mult_gf2_4;
		input [7:0] data_in;
		
		// intermediete values
		reg [3:0] q, w; 		// splitting 8-bit input into two 4-bit pieces
		reg [1:0] mul1, mul2, mul3,  	// output of three GF(2) multiplications, mult with constant phi
					  phi_out;				// output of multiplication with constant phi
		
		begin		
			q = data_in[7:4]; // q = [q3, q2, q1, q0]
			w = data_in[3:0]; // w = [w3, w2, w1, w0]
			
			mul1 = mult_gf2({q[3:2], w[3:2]}); // top multiplication box
			mul2 = mult_gf2({(q[3:2] ^ q[1:0]), (w[3:2] ^ w[1:0])}); // middle multiplication box
			mul3 = mult_gf2({q[1:0], w[1:0]}); // bottom multiplication box

			phi_out = mult_phi(mul1);
			
			mult_gf2_4 = {(mul2 ^ mul3), (phi_out ^ mul3)};
		end
	endfunction

	// Functions to make up Multiplication in GF(2^4)

	// Multiplication in GF(2)
	// Section 2.2.5
	function [1:0] mult_gf2;
		input [3:0] data;
		
		begin
			mult_gf2[1] = (data[3] & data[1]) ^ (data[2] & data[1]) ^ (data[3] & data[0]);
			mult_gf2[0] = (data[3] & data[1]) ^ (data[2] & data[0]);
		end
	endfunction

	// Multiplication with constant, phi
	// Section 2.2.6
	function [1:0] mult_phi;
		input [1:0] data;
		
		begin
			mult_phi[1] = data[1] ^ data[0];
			mult_phi[0] = data[1];
		end
	endfunction

	// End of functions to make up Multiplication in GF(2^4)

	// Multiplicative inversion in GF(2^4)
	// Section 2.2.7
	// inv(q) = [inv(q3), inv(q2), inv(q1), inv(q0)]
	function [3:0] mult_inv_gf2_4;
		input [3:0] data;
		
		begin
			mult_inv_gf2_4[3] = data[3] ^ (data[3] & data[2] & data[1]) ^ (data[3] & data[0]) ^ data[2];
			mult_inv_gf2_4[2] = (data[3] & data[2] & data[1]) ^ (data[3] & data[2] & data[0]) ^
										(data[3] & data[0]) ^ data[2] ^ (data[2] & data[1]);
			// space for readability
			mult_inv_gf2_4[1] = data[3] ^ (data[3] & data[2] & data[1]) ^ (data[3] & data[1] & data[0]) ^
										data[2] ^ (data[2] & data[0]) ^ data[1];
			// space for readability
			mult_inv_gf2_4[0] = (data[3] & data[2] & data[1]) ^ (data[3] & data[2] & data[0]) ^
										(data[3] & data[1]) ^ (data[3] & data[1] & data[0]) ^ (data[3] & data[0])
										^ data[2] ^ (data[2] & data[1]) ^ (data[2] & data[1] & data[0]) ^ 
										data[1] ^ data[0]; 
		end
	endfunction

endmodule


// Simple testbench using example from paper
// Section 3 - Worked example
//module subByteCombinational_testbench();
//   wire [7:0] data;
//	wire [7:0] out;
//	reg clk;
//
//	assign data = 128'b00000100;
//	
//	// Set up the clock
//	parameter CLOCK_PERIOD = 100;	// simulating a toggling clock
//	initial clk = 1;
//
//	always begin
//		#(CLOCK_PERIOD/2) clk = ~clk;	// clock toggle
//	end
//
//	subByteCombinational dut(.data_in(data),.data_out(out));
//
//endmodule
