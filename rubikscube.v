module rubikscube(SW,KEY,CLOCK_50);
input [3:0]SW;
input CLOCK_50;
input [1:0]KEY;
wire [161:0] cubestate,modifiedcube;

registercube rc1(cubestate,modifiedcube,CLOCK_50,KEY[0]);
controller c1(cubestate,modifiedcube,KEY[1],SW[3:0]);

endmodule

module registercube(q,d,clock,reset);
	input [161:0]d;
	input clock,reset;
	output reg [161:0]q;
	always@(posedge clock)
		begin
		if(~reset)
			q<=d;
		else if(reset)
			begin
			q[26:0]<= 27'b110110110110110110110110110;
			q[53:27]<= 27'b100100100100100100100100100;
			q[80:54]<= 27'b001001001001001001001001001;
			q[107:81]<= 27'b101101101101101101101101101;
			q[134:108]<= 27'b111111111111111111111111111;
			q[161:135]<= 27'b010010010010010010010010010;
			end
		end
endmodule
	
module controller(cube,cubeout,domove,typeofmove);
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
	4'b0001:cubeout=topc;
	4'b0010:cubeout=topcc;
	4'b0011:cubeout=botc;
	4'b0100:cubeout=botcc;
	4'b0101:cubeout=leftc;
	4'b0110:cubeout=leftcc;
	4'b0111:cubeout=rightc;
	4'b1000:cubeout=rightcc;
	4'b1001:cubeout=backc;
	4'b1010:cubeout=backcc;
	4'b1011:cubeout=frontc;
	4'b1100:cubeout=frontcc;
	default:cubeout=cube;
	endcase
endmodule

//////////////////////////////////////////////////////////////////////
module movetopc(cube,topc);
input [161:0]cube;
output reg [161:0]topc;

always@(cube)
begin
	//top face
	topc[2:0]<=cube[20:18];
	topc[5:3]<=cube[11:9];
	topc[8:6]<=cube[2:0];
	topc[11:9]<=cube[23:21];
	topc[14:12]<=cube[14:12];
	topc[17:15]<=cube[5:3];
	topc[20:18]<=cube[26:24];
	topc[23:21]<=cube[17:15];
	topc[26:24]<=cube[8:6];

	//top row
	topc[35:27]<=cube[62:54];
	topc[62:54]<=cube[89:81];
	topc[89:81]<=cube[143:135];
	topc[143:135]<=cube[35:27];

	//rest of cube the same
	topc[53:36]<=cube[53:36];
	topc[80:63]<=cube[80:63];
	topc[107:90]<=cube[107:90];
	topc[134:108]<=cube[134:108];
	topc[161:144]<=cube[161:144];
end
endmodule

/////////////////////////////////////////////////////////////////////////////
module movetopcc(cube,topcc);
input [161:0]cube;
output reg [161:0]topcc;

always@(cube)
begin
	//top face
	topcc[2:0]<=cube[8:6];
	topcc[5:3]<=cube[17:15];
	topcc[8:6]<=cube[26:24];
	topcc[11:9]<=cube[5:3];
	topcc[14:12]<=cube[14:12];
	topcc[17:15]<=cube[23:21];
	topcc[20:18]<=cube[2:0];
	topcc[23:21]<=cube[11:9];
	topcc[26:24]<=cube[20:18];

	//top row
	topcc[35:27]<=cube[141:135];
	topcc[89:81]<=cube[62:54];
	topcc[62:54]<=cube[35:27];
	topcc[143:135]<=cube[89:81];

	//rest of cube the same
	topcc[53:36]<=cube[53:36];
	topcc[80:63]<=cube[80:63];
	topcc[107:90]<=cube[107:90];
	topcc[134:108]<=cube[134:108];
	topcc[161:144]<=cube[161:144];
end
endmodule

/////////////////////////////////////////////////////////////////////////////
module movebotc(cube,botc);
input [161:0]cube;
output reg [161:0]botc;

always@(cube)
begin
	//bottom face
	botc[110:108]<=cube[128:126];
	botc[113:111]<=cube[119:117];
	botc[116:114]<=cube[110:108];
	botc[119:117]<=cube[131:129];
	botc[122:120]<=cube[122:120];
	botc[125:123]<=cube[113:111];
	botc[128:126]<=cube[134:132];
	botc[131:129]<=cube[125:123];
	botc[134:132]<=cube[116:114];

	//bottom row
	botc[53:45]<=cube[161:153];
	botc[80:72]<=cube[53:45];
	botc[107:99]<=cube[80:72];
	botc[161:153]<=cube[107:99];

	//rest of cube the same
	botc[26:0]<=cube[26:0];
	botc[44:27]<=cube[44:27];
	botc[71:54]<=cube[71:54];
	botc[98:81]<=cube[98:81];
	botc[152:135]<=cube[152:135];
end
endmodule

///////////////////////////////////////////////////////////////////////////

module movebotcc(cube,botcc);
input [161:0]cube;
output reg [161:0]botcc;

always@(cube)
begin
	//bottom face
	botcc[110:108]<=cube[116:114];
	botcc[113:111]<=cube[125:123];
	botcc[116:114]<=cube[134:132];
	botcc[119:117]<=cube[113:111];
	botcc[122:120]<=cube[122:120];
	botcc[125:123]<=cube[131:129];
	botcc[128:126]<=cube[110:108];
	botcc[131:129]<=cube[119:117];
	botcc[134:132]<=cube[128:126];

	//bottom row
	botcc[53:45]<=cube[80:72];
	botcc[80:72]<=cube[107:99];
	botcc[107:99]<=cube[161:153];
	botcc[161:153]<=cube[53:45];

	//rest of cube the same
	botcc[26:0]<=cube[26:0];
	botcc[44:27]<=cube[44:27];
	botcc[71:54]<=cube[71:54];
	botcc[98:81]<=cube[98:81];
	botcc[152:135]<=cube[152:135];
end
endmodule
///////////////////////////////////////////////////////////////////////////
module moveleftc(cube,leftc);
input [161:0]cube;
output reg [161:0]leftc;

always@(cube)
begin
	//left face
	leftc[29:27]<=cube[47:45];
	leftc[32:30]<=cube[38:36];
	leftc[35:33]<=cube[29:27];
	leftc[38:36]<=cube[50:48];
	leftc[41:39]<=cube[41:39];
	leftc[44:42]<=cube[32:30];
	leftc[47:45]<=cube[53:51];
	leftc[50:48]<=cube[44:42];
	leftc[53:51]<=cube[35:33];

	//left collumn
	leftc[2:0]<=cube[137:135];
	leftc[11:9]<=cube[146:144];
	leftc[20:18]<=cube[155:153];
	leftc[56:54]<=cube[2:0];
	leftc[65:63]<=cube[11:9];
	leftc[74:72]<=cube[20:18];
	leftc[110:108]<=cube[56:54];
	leftc[119:117]<=cube[65:63];
	leftc[128:126]<=cube[74:72];
	leftc[137:135]<=cube[110:108];
	leftc[146:144]<=cube[119:117];
	leftc[155:153]<=cube[128:126];

	//rest of cube the same
	leftc[8:3]<=cube[8:3];
	leftc[17:12]<=cube[17:12];
	leftc[26:21]<=cube[26:21];
	leftc[62:57]<=cube[62:57];
	leftc[71:66]<=cube[71:66];
	leftc[80:75]<=cube[80:75];
	leftc[116:111]<=cube[116:111];
	leftc[125:120]<=cube[125:120];
	leftc[134:129]<=cube[134:129];
	leftc[143:138]<=cube[143:138];
	leftc[152:147]<=cube[152:147];
	leftc[161:156]<=cube[161:156];
	leftc[107:81]<=cube[107:81];
end
endmodule

///////////////////////////////////////////////////////////////////////
module moveleftcc(cube,leftcc);
input [161:0]cube;
output reg [161:0]leftcc;

always@(cube)
begin
	//left face
	leftcc[29:27]<=cube[35:33];
	leftcc[32:30]<=cube[44:42];
	leftcc[35:33]<=cube[53:51];
	leftcc[38:36]<=cube[32:30];
	leftcc[41:39]<=cube[41:39];
	leftcc[44:42]<=cube[50:48];
	leftcc[47:45]<=cube[29:27];
	leftcc[50:48]<=cube[38:36];
	leftcc[53:51]<=cube[47:45];

	//left collumn
	leftcc[2:0]<=cube[56:54];
	leftcc[11:9]<=cube[65:63];
	leftcc[20:18]<=cube[74:72];
	leftcc[56:54]<=cube[110:108];
	leftcc[65:63]<=cube[119:117];
	leftcc[74:72]<=cube[128:126];
	leftcc[110:108]<=cube[137:135];
	leftcc[119:117]<=cube[146:144];
	leftcc[128:126]<=cube[155:153];
	leftcc[137:135]<=cube[2:0];
	leftcc[146:144]<=cube[11:9];
	leftcc[155:153]<=cube[20:18];

	//rest of cube the same
	leftcc[8:3]<=cube[8:3];
	leftcc[17:12]<=cube[17:12];
	leftcc[26:21]<=cube[26:21];
	leftcc[62:57]<=cube[62:57];
	leftcc[71:66]<=cube[71:66];
	leftcc[80:75]<=cube[80:75];
	leftcc[116:111]<=cube[116:111];
	leftcc[125:120]<=cube[125:120];
	leftcc[134:129]<=cube[134:129];
	leftcc[143:138]<=cube[143:138];
	leftcc[152:147]<=cube[152:147];
	leftcc[161:156]<=cube[161:156];
	leftcc[107:81]<=cube[107:81];
end
endmodule

//RAYAN 

//RIGHT COUNTER CLOCKWISE
module moverightcc(cube, outcube);
	input [161:0] cube;
	output reg [161:0] outcube;
	always@(cube)
	begin
		//STUFF THAT STAYS THE SAME
		//Top
		outcube [5:0] <= cube[5:0];
		outcube [14:9] <= cube[14:9];
		outcube [23:18] <= cube[23:18];
		//Front
		outcube [59:54] <= cube[59:54];
		outcube [68:63] <= cube[68:63];
		outcube [77:72] <= cube[77:72] ;
		//Bot
		outcube [113:108] <= cube[113:108];
		outcube [122:117] <= cube[122:117];
		outcube [131:126] <= cube[131:126];
		//back
		outcube [140:135] <= cube[140:135];
		outcube [149:144] <= cube[149:144];
		outcube [158:153] <= cube[158:153];
		//Left
		outcube [53:27] <= cube[53:27];
		//MIDDLE BIT OF RIGHTFACE
		outcube [95:93] <= cube[95:93];
		
		//Stuff that Changes
		//EDGE
		//top -> front
		outcube[62:60] <= cube[8:6];
		outcube[71:69] <= cube[17:15];
		outcube[80:78] <= cube[26:24];
		//front -> bot
		outcube[116:114] <= cube[62:60];
		outcube[125:123] <= cube[71:69];
		outcube[134:132] <= cube[80:78];
		//bot -> back
		outcube[143:141] <= cube[116:114];
		outcube[152:150] <= cube[125:123];
		outcube[161:159] <= cube[134:132];
		//back -> top
		outcube[8:6] <= cube[143:141];
		outcube[17:15] <= cube[152:150];
		outcube[26:24] <= cube[161:159];
		
		//FACE:RIGHT
		//107 - 81
		outcube[107:105] <= cube[101:99];
		outcube[104:102] <= cube[92:90];
		outcube[101:99] <= cube[83:81];
		outcube[98:96] <= cube[104:102];
		outcube[92:90] <= cube[86:84];
		outcube[89:87] <= cube[107:105];
		outcube[86:84] <= cube[98:96];
		outcube[83:81] <= cube[89:87];
	end

endmodule

//RIGHT  CLOCK WISE
module moverightc(cube, outcube);
	input [161:0] cube;
	output reg [161:0] outcube;
	//STUFF THAT STAYS THE SAME
	always @(cube)
	begin
		//Top
		outcube [5:0] <= cube[5:0];
		outcube [14:9] <= cube[14:9];
		outcube [23:18] <= cube[23:18];
		//Front
		outcube [59:54] <= cube[59:54];
		outcube [68:63] <= cube[68:63];
		outcube [77:72] <= cube[77:72] ;
		//Bot
		outcube [113:108] <= cube[113:108];
		outcube [122:117] <= cube[122:117];
		outcube [131:126] <= cube[131:126];
		//back
		outcube [140:135] <= cube[140:135];
		outcube [149:144] <= cube[149:144];
		outcube [158:153] <= cube[158:153];
		//Left
		outcube [53:27] <= cube[53:27];
		//MIDDLE BIT OF RIGHTFACE
		outcube [95:93] <= cube[95:93];

		//STUFF THAT CHANGES
		//EDGE
		//TOP -> BACK
		outcube[143:141] <= cube[8:6];
		outcube[152:150] <= cube[17:15];
		outcube[161:159] <= cube[26:24];
		//BACK -> BOT
		outcube[116:114] <= cube[143:141];
		outcube[125:123] <= cube[152:150];
		outcube[134:132] <= cube[161:159];
		//BOT -> FRONT
		outcube[62:60] <= cube[116:114];
		outcube[71:69] <= cube[125:123];
		outcube[80:78] <= cube[134:132];
		//FRONT -> TOP
		outcube[8:6] <= cube[62:60];
		outcube[17:15] <= cube[71:69];
		outcube[26:24] <= cube[80:78];
		//FACE:RIGHT 107 - 81
		outcube[107:105] <= cube[89:87];
		outcube[104:102] <= cube[98:96];
		outcube[101:99] <= cube[107:105];
		outcube[98:96] <= cube[86:84];
		outcube[92:90] <= cube[104:102];
		outcube[89:87] <= cube[83:81];
		outcube[86:84] <= cube[92:90];
		outcube[83:81] <= cube[101:99];
	end
endmodule

//BACK COUNTER CLOCKWISE
module movebackcc(cube, outcube);
input [161:0] cube;
	output reg [161:0] outcube;
	//STUFF THAT STAYS THE SAME
	always @(cube)
	begin

		//WHAT STAY SAME
		//FRONT
		outcube [80:54] <= cube [80:54];
		//LEFT
		outcube [35:30] <= cube [35:30];
		outcube [44:39] <= cube [44:39];
		outcube [53:48] <= cube [53:48];
		//RIGHT
		outcube [86:81] <= cube [86:81];
		outcube [95:90] <= cube [95:90];
		outcube [104:99] <= cube [104:99];
		//TOP
		outcube [26:9] <= cube [26:9];
		//BOT
		outcube [125:108] <= cube [125:108];
		//MID BACK
		outcube [149:147] <= cube [149:147];

		//WHAT CHANGES 
		// top -> Right
		outcube [89:87] <= cube [2:0];
		outcube [98:96] <= cube [5:3];
		outcube [107:105] <= cube [8:6];
		//left -> top
		outcube [2:0] <= cube [47:45];
		outcube [5:3] <= cube [38:36];
		outcube [8:6] <= cube [29:27];
		//bot -> left
		outcube [47:45] <= cube [135:132];
		outcube [38:36] <= cube [131:129];
		outcube [29:27] <= cube [128:126];
		//right -> bot 
		outcube [134:132] <= cube [89:87];
		outcube [131:129] <= cube [98:96];
		outcube [128:126] <= cube [107:105];
		
		//BACK FACE 161 -135 X 149 - 147 X
		outcube [161:159] <= cube [155:153];
		outcube [158:156] <= cube [146:144];
		outcube [155:153] <= cube [137:135];
		outcube [152:150] <= cube [158:156];
		outcube [146:144] <= cube [140:138];
		outcube [143:141] <= cube [161:159];
		outcube [140:138] <= cube [152:150];
		outcube [137:135] <= cube [143:141];
	end

endmodule

//BACK  CLOCK WISE
module movebackc(cube, outcube);
	input [161:0] cube;
	output reg [161:0] outcube;
	//STUFF THAT STAYS THE SAME
	always @(cube)
	begin

		//WHAT STAY SAME
		//FRONT
		outcube [80:54] <= cube [80:54];
		//LEFT
		outcube [35:30] <= cube [35:30];
		outcube [44:39] <= cube [44:39];
		outcube [53:48] <= cube [53:48];
		//RIGHT
		outcube [86:81] <= cube [86:81];
		outcube [95:90] <= cube [95:90];
		outcube [104:99] <= cube [104:99];
		//TOP
		outcube [26:9] <= cube [26:9];
		//BOT
		outcube [125:108] <= cube [125:108];
		//MID BACK
		outcube [149:147] <= cube [149:147];
		
		//WHAT CHANGES
		//Right -> top
		outcube [2:0] <= cube [89:87];
		outcube [5:3] <= cube [98:96];
		outcube [8:6] <= cube [107:105];
		//top -> left
		outcube [47:45] <= cube [2:0];
		outcube [38:36] <= cube [5:3];
		outcube [29:27] <= cube [8:6];
		//left -> bot
		outcube [134:132] <= cube [47:45];
		outcube [131:129] <= cube [38:36];
		outcube [128:126] <= cube [29:27];
		//bot -> right
		outcube [89:87] <= cube [134:132];
		outcube [98:96] <= cube [131:129];
		outcube [107:105] <= cube [128:126];
		
		//BACKFACE 
		outcube [143:141] <= cube [137:135];
		outcube [140:138] <= cube [146:144];
		outcube [137:135] <= cube [155:153];
		outcube [152:150] <= cube [140:138];
		outcube [146:144] <= cube [158:156];
		outcube [161:159] <= cube [143:141];
		outcube [158:156] <= cube [152:150];
		outcube [155:153] <= cube [161:159];

	end
endmodule
//FRONT CLOCKWISE

module movefrontc(cube, outcube);
	
	input [161:0] cube;
	output reg [161:0] outcube;
	//STUFF THAT STAYS THE SAME
	always @(cube)
	begin
	//STUFF  THAT STAYS THE SAME
	//BACK FACE
	outcube[161:135] <= cube[161:135];
	//LEFT
	outcube[32:27] <= cube[32:27];
	outcube[41:36] <= cube[41:36];
	outcube[50:45] <= cube[50:45];
	//RIGHT
	outcube[89:84] <= cube[89:84];
	outcube[98:93] <= cube[98:93];
	outcube[107:102] <= cube[107:102];
	//TOP
	outcube[17:0] <= cube[17:0];
	//BOT
	outcube[134:117] <= cube[134:117];
	//MIDDLE FRONT
	outcube[68:66] <= cube [68:66];

	//WHAT CHANGES
	//FRONT FACE
	outcube[56:54] <= cube [74:72];
	outcube[59:57] <= cube [65:63];
	outcube[62:60] <= cube [56:54];
	outcube[71:69] <= cube [59:57];
	outcube[65:63] <= cube [77:75];
	outcube[80:78] <= cube [62:60];
	outcube[77:75] <= cube [71:69];
	outcube[74:72] <= cube [80:78];

	//EDGE
	//NEW TOP
	outcube[20:18] <= cube[53:51];
	outcube[23:21] <= cube[44:42];
	outcube[26:24] <= cube[35:33];
	//NEW RIGHT
	outcube[83:81] <= cube[20:18];
	outcube[92:90] <= cube[23:21];
	outcube[101:99] <= cube[26:24];
	//NEW BOT
	outcube[116:114] <= cube[83:81];
	outcube[113:111] <= cube[92:90];
	outcube[110:108] <= cube[101:99];
	//NEW LEFT
	outcube[35:33] <= cube[110:108];
	outcube[44:42] <= cube[113:111];
	outcube[53:51] <= cube[116:114];



	end

endmodule



//FRONT COUNTER CLOCK WISE
module movefrontcc(cube, outcube);
	
	input [161:0] cube;
	output reg [161:0] outcube;
	//STUFF THAT STAYS THE SAME
	always @(cube)
	begin
	//STUFF  THAT STAYS THE SAME
	//BACK FACE
	outcube[161:135] <= cube[161:135];
	//LEFT
	outcube[32:27] <= cube[32:27];
	outcube[41:36] <= cube[41:36];
	outcube[50:45] <= cube[50:45];
	//RIGHT
	outcube[89:84] <= cube[89:84];
	outcube[98:93] <= cube[98:93];
	outcube[107:102] <= cube[107:102];
	//TOP
	outcube[17:0] <= cube[17:0];
	//BOT
	outcube[134:117] <= cube[134:117];
	//MIDDLE FRONT
	outcube[68:66] <= cube [68:66];

	//WHAT CHANGES
	//FRONT FACE
	outcube[56:54] <= cube [62:60];
	outcube[59:57] <= cube [71:69];
	outcube[62:60] <= cube [80:78];
	outcube[71:69] <= cube [77:75];
	outcube[65:63] <= cube [59:57];
	outcube[80:78] <= cube [74:72];
	outcube[77:75] <= cube [65:63];
	outcube[74:72] <= cube [56:54];

	//EDGES
	//NEW TOP
	outcube[20:18] <= cube[83:81];
	outcube[23:21] <= cube[92:90];
	outcube[26:24] <= cube[101:99];
	//NEW RIGHT
	outcube[83:81] <= cube[116:114];
	outcube[92:90] <= cube[113:111];
	outcube[101:99] <= cube[110:108];
	//NEW BOT
	outcube[116:114] <= cube[53:51];
	outcube[113:111] <= cube[44:42];
	outcube[110:108] <= cube[35:33];
	//NEW LEFT
	outcube[35:33] <= cube[26:24];
	outcube[44:42] <= cube[23:21];
	outcube[53:51] <= cube[20:18];


	end

endmodule