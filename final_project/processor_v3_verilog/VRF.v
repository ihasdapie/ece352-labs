module VRF(
	clock, vreg1, vreg2, vregw,
	vdataw, VRFWrite, vdata1, vdata2,
	r0, r1, r2, r3, reset);

// ------------------------ PORT declaration ------------------------ //
input [1:0] vreg1, vreg2, vregw;
output [31:0] vdata1, vdata2;
input [31:0] vdataw;
input VRFWrite;
input reset;
input clock;

output [31:0] r0, r1, r2, r3;

// ------------------------- Registers/Wires ------------------------ //
reg [31:0] k0, k1, k2, k3;

reg [31:0] data1_tmp, data2_tmp;

// Asynchronously read data from two registers
always @(*)
begin
	case (vreg1)
		0: data1_tmp = k0;
		1: data1_tmp = k1;
		2: data1_tmp = k2;
		3: data1_tmp = k3;
	endcase
	case (vreg2)
		0: data2_tmp = k0;
		1: data2_tmp = k1;
		2: data2_tmp = k2;
		3: data2_tmp = k3;
	endcase
end

// Synchronously write data to the register file;
// also supports an asynchronous reset, which clears all registers
always @(posedge clock or posedge reset)
begin
	if (reset) begin
		k0 = 0;
		k1 = 0;
		k2 = 0;
		k3 = 0;
	end	else begin
		if (VRFWrite) begin
			case (vregw)
				0: k0 = vdataw;
				1: k1 = vdataw;
				2: k2 = vdataw;
				3: k3 = vdataw;
			endcase
		end
	end
end

// Assign temporary values to the outputs
assign data1 = data1_tmp;
assign data2 = data2_tmp;

assign r0 = k0;
assign r1 = k1;
assign r2 = k2;
assign r3 = k3;

endmodule
