module registercube(q,d,clock,reset,enable);
	input [161:0]d;
	input clock,reset,enable;
	output reg [161:0]q;
	always@(posedge clock)
		begin
		if(~reset && enable)
			q<=d;
		else if(reset)
			begin
			q[26:0]<= 27'b110110110110110110110110110;
			q[53:27]<= 27'b100100100100100100100100100;
			q[80:54]<= 27'b001001001001001001001001001;
			q[107:81]<= 27'b101101101101101101101101101;
			q[134:108]<= 27b'111111111111111111111111111;
			q[161:135]<= 27b'010010010010010010010010010;
			end
		end
endmodule
	
module controller(cube,coubeout,domove,typeofmove);
	input [161:0]cube;
	output reg [161:0]cubeout;
	input domove;
	input [3:0]typeofmove;
	wire [161:0]topc,topcc,botc,botcc,leftc,leftcc,rightc,rightcc,backc,backcc,frontc,frontcc;
	
	//CHRIS
	movetopc m0(cube,topc);
	movetopcc m1(cube,topcc);
	movebotc m2(cube,botc);
	movebotcc m3(cube,botcc);
	moveleftc m4(cube,leftc);
	moveleftcc m5(cube,leftcc);
	//RAYAN
	moverightc m6(cube,rightc);
	moverightcc m7(cube,rightcc);
	movebackc m8(cube,backc);
	movebackcc m9(cube,backcc);
	movefrontc m10(cube,frontc);
	movefrontcc m11(cube,frontcc);
	
	always@(*)
	case(typeofmove)
	4b'0001:cubeout=topc;
	4b'0010:cubeout=topcc;
	4b'0011:cubeout=botc;
	4b'0100:cubeout=botcc;
	4b'0101:cubeout=leftc;
	4b'0110:cubeout=leftcc;
	4b'0111:cubeout=rightc;
	4b'1000:cubeout=rightcc;
	4b'1001:cubeout=backc;
	4b'1010:cubeout=backcc;
	4b'1011:cubeout=frontc;
	4b'1100:cubeout=frontcc;
	default:cubeout=cube;
	endcase
endmodule