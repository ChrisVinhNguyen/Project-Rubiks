
module ProjectRubiks
		(CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	wire [161:0] cubestate;
	wire[161:0] modifiedcube;
	
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	wire [6:0]xstart;
	wire [3:0]NextState;
	wire [3:0]PresentState;
	wire enable;
	

	//RUBRICKS DECLARATIONS
	wire [161:0] testCUBE ;
	assign testCUBE = 162'b100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001100001;
	wire [8:0] presDrawState, nxtDrawState;
	//replaces SW[6:0]
	wire [6:0] autoPosition;
	//replaces KEY[1]
	wire drawX;
	//replaces KEY[3]
	wire changeY;
	// lagg freq
	wire [27:0] freq;
	assign  freq = 28'd3125;
	//laggedClock
	wire laggedClock;

	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	//assign colour=SW[9:7];
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
		
		
	registercube rc1(cubestate,modifiedcube,CLOCK_50,~KEY[1],~KEY[3]);
   controller c1(cubestate,modifiedcube,~KEY[1],SW[3:0]);
	//cubescramble randomcube(cubestate,modifiedcube,~resetn,~KEY[2]);
	
		
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
   	register x0(~resetn,xstart,(autoPosition[6:0]-7'b0011110),~changeY,CLOCK_50);
    // Instanciate datapath
	datapath d0(xstart,(autoPosition[6:0]+7'b0010010),enable, ~drawX,resetn,count,CLOCK_50,x,y);
    // Instanciate FSM control
	statetable s0(PresentState,NextState,count,~drawX);
	controlpath c0(PresentState,NextState,CLOCK_50,~drawX,enable,writeEn);
	 

	 //NEW RUBRICKS SHIT
	 //module drawCubeControl ( colour, nxtDrawState, position, changeY ,drawX,clock,drawState, inCube, GO )
	 drawCubeControl dcc(colour, nxtDrawState, autoPosition[6:0], changeY, drawX, laggedClock,presDrawState,cubestate, ~KEY[1] );
	 //module drawCubeStateTable (presDrawState, nxtDrawState, GO, clock)
	 drawCubeStateTable dcst(presDrawState, nxtDrawState,~KEY[1], laggedClock);

	 //also remember to include a draw lagger
	 //module counterEnable (innerClk, Freq,Enable)
	 counterEnable ce(CLOCK_50, freq, laggedClock);

endmodule



module counter(clear,clock,enable,q);
	input clear,clock,enable;
	output reg [3:0] q; // declare q
	always @(posedge clock) // triggered every time clock rises
		begin
			if (clear == 1'b0) // when Clear b is 0
				q <= 0; // q is set to 0
			else if (q == 4'b1111) // when q is the maximum value for the counter
				q <= 0; // q reset to 0
			else if (enable == 1'b1) // increment q only when Enable is 1
				q <= q + 1; // increment q
		end
endmodule


module datapath(xstart,ystart,enable,start,reset,count,clock,x,y);
input[6:0] xstart,ystart;
input start;
input clock;
input reset;
input enable;
output [3:0]count;
output reg[6:0] x,y;
	
counter c1(reset,clock,enable,count);

always@(posedge clock)
begin
if(start)
begin 
	x <= xstart+count[1:0];
	y <= ystart+count[3:2];
end
end
endmodule

module statetable(PresentState,NextState,counter,enable);
input [3:0]PresentState;
input [3:0]counter;
input enable;
output reg [3:0]NextState;
parameter RESET_S = 4'b0000, S1 = 4'b0001, S2 = 4'b0010;
    
	always @(*)
	begin 
     case (PresentState)
	  RESET_S:begin
				if(!enable) NextState=RESET_S;
				else NextState = S1;
				end
     S1: begin 
				if(counter<4'b1111|counter==4'b1111) NextState = S1;
				else NextState = S2;
			end
	  S2:
            NextState = RESET_S;
		
		default:    
 		NextState = RESET_S;
        endcase
    end


endmodule

module controlpath(PresentState,NextState,clock,start,enable,plot);

output reg enable,plot;
input [3:0]NextState;
input clock,start;
output reg[3:0]PresentState;
parameter RESET_S = 4'b0000, S1 = 4'b0001, S2 = 4'b0010;

always @(posedge clock)
begin
	if(!start)
		PresentState<=RESET_S;
	else
		PresentState<=NextState;
end

always @(*)
begin
	case(PresentState)
	RESET_S:begin
		enable=0;
		plot=0;
		end
	S1:begin
		enable=1;
		plot=1;
		end
	S2:begin
		enable=0;
		plot=1;
		end
	default:begin
		enable=0;
		plot=0;
		end
	endcase
end
endmodule	

module register(ResetB,q,d,enable,clock);
	input clock;
	input [6:0]d;
	input ResetB;
	output reg [6:0]q;
	input enable;

	always @(posedge clock) // triggered every time clock rises
		begin
		if (ResetB == 1) // when Reset b is 1 (note this is tested on every rising clock edge)
			q <= 0; // q is set to 0. Note that the assignment uses <=
		else if(enable ==1)// when Reset b is not 0
			q <= d; // value of d passes through to output q
		
		end
endmodule





module drawCubeControl ( colour, nxtDrawState, position, changeX ,drawY,clock,drawState, inCube, GO );

	input  clock, GO;
	input [8:0] nxtDrawState;
	output reg [8:0] drawState;
	output reg [2:0] colour;
	output reg [6:0] position;
	input[161:0] inCube;
	output reg changeX, drawY;

	always @ (posedge clock)
	begin
		drawState = nxtDrawState;
	end

	always @ (posedge clock)
	begin
		//Defining Jobs and Piece state relationship
		//drawState[8:6] is the job code
		//drawState[5:0] is the piece code 
		//JOB CODES: 001= set Xposition 
		//'' ''  ''  010= set X(equivlent to pushing KEY[3])
		//'' ''  ''  011= set Yposition  
		//'' ''  ''	 100= set Colour  
		//'' ''  ''  101= setX/drawY(equivelant to pushing KEY[1])
		//drawY =1 means dont draw drawY=0 means draw
		//changeX =1 means dont changeX changeX=0 means change Y
		case(drawState)
			//ZERO/DONE/IDLE STATE 
			9'b000000000:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = 3'b000;
				position[6:0] = 7'b0000000;
				
			end
			//

			//FACE TOP FACE TOP FACE TOP FACE TOP FACE TOP FACE TOP FACE TOP

			// PIECE #00 BIN000000
			9'b001000000:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[2:0];
				position[6:0] = 7'b0110100 ;
				
			end

			9'b010000000:
			begin
				colour[2:0] = inCube[2:0];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011000000:
			begin
				colour[2:0] = inCube[2:0];
				position[6:0] = 7'b0001000;
				drawY = 1;
				changeX = 1;
			end

			9'b100000000:
			begin
				colour[2:0] = inCube[2:0];
				position[6:0] = 7'b0001000;
				drawY = 1;
				changeX = 1;
			end

			9'b101000000:
			begin
				colour[2:0] = inCube[2:0];
				position[6:0] = 7'b0001000;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #01 BIN000001
			9'b001000001:
			begin
				drawY=1;
				changeX=1;
				colour[2:0] = inCube[2:0];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010000001:
			begin
				colour[2:0] = inCube[5:3];
				position[6:0] = 7'b0111000+2'b01;
				drawY=1;
				changeX=0;
			end


			9'b011000001:
			begin
				colour[2:0] = inCube[5:3];
				position[6:0] = 7'b0001000 ;
				drawY=1;
				changeX=1;
			end

			9'b100000001:
			begin
				colour[2:0] = inCube[5:3];
				position[6:0] = 7'b0001000;
				drawY=1;
				changeX=1;
			end

			9'b101000001:
			begin
				colour[2:0] = inCube[5:3];
				position[6:0] = 7'b0001000 ;
				drawY=0;
				changeX=1;
			end



			// PIECE #02 BIN000010
			9'b001000010:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[5:3];
				position[6:0] = 7'b0111100+2'b10;
				
			end

			9'b010000010:
			begin
				colour[2:0] = inCube[8:6];
				position[6:0] = 7'b0111100+2'b10;
				drawY = 1;
				changeX = 0;
			end


			9'b011000010:
			begin
				colour[2:0] = inCube[8:6];
				position[6:0] = 7'b0001000;
				drawY = 1;
				changeX = 1;
			end

			9'b100000010:
			begin
				colour[2:0] = inCube[8:6];
				position[6:0] = 7'b0001000;
				drawY = 1;
				changeX = 1;
			end

			9'b101000010:
			begin
				colour[2:0] = inCube[8:6];
				position[6:0] = 7'b0001000;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #03 BIN000011
			9'b001000011:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[8:6];
				position[6:0] = 7'b0110100;
				
			end

			9'b010000011:
			begin
				colour[2:0] = inCube[11:9];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011000011:
			begin
				colour[2:0] = inCube[11:9];
				position[6:0] = 7'b0001100+2'b01 ;
				drawY = 1;
				changeX = 1;
			end

			9'b100000011:
			begin
				colour[2:0] = inCube[11:9];
				position[6:0] = 7'b0001100+2'b01 ;
				drawY = 1;
				changeX = 1;
			end

			9'b101000011:
			begin
				colour[2:0] = inCube[11:9];
				position[6:0] = 7'b0001100+2'b01 ;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #04 BIN000100
			9'b001000100:
			begin
				drawY =1;
				changeX = 1;
				colour[2:0] = inCube[11:9];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010000100:
			begin
				colour[2:0] = inCube[14:12];
				position[6:0] = 7'b0111000+2'b01;
				drawY =1;
				changeX = 0;
			end


			9'b011000100:
			begin
				colour[2:0] = inCube[14:12];
				position[6:0] = 7'b0001100+2'b01;
				drawY =1;
				changeX = 1;
			end

			9'b100000100:
			begin
				colour[2:0] = inCube[14:12];
				position[6:0] = 7'b0001100+2'b01;
				drawY =1;
				changeX = 1;
			end

			9'b101000100:
			begin
				colour[2:0] = inCube[14:12];
				position[6:0] = 7'b0001100+2'b01;
				drawY =0;
				changeX = 1;
			end



			// PIECE #05 BIN000101
			9'b001000101:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[14:12];
				position[6:0] = 7'b0111100+2'b10;
				
			end

			9'b010000101:
			begin
				colour[2:0] = inCube[17:15];
				position[6:0] = 7'b0111100+2'b10;
				drawY = 1;
				changeX = 0;
			end


			9'b011000101:
			begin
				colour[2:0] = inCube[17:15];
				position[6:0] = 7'b0001100+2'b01;
				drawY = 1;
				changeX = 1;
			end

			9'b100000101:
			begin
				colour[2:0] = inCube[17:15];
				position[6:0] = 7'b0001100+2'b01;
				drawY = 1;
				changeX = 1;
			end

			9'b101000101:
			begin
				colour[2:0] = inCube[17:15];
				position[6:0] = 7'b0001100+2'b01;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #06 BIN000110
			9'b001000110:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[17:15];
				position[6:0] = 7'b0110100;
				
			end

			9'b010000110:
			begin
				colour[2:0] = inCube[20:18];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011000110:
			begin
				colour[2:0] = inCube[20:18];
				position[6:0] = 7'b0010000+2'b10;
				drawY = 1;
				changeX = 1;
			end

			9'b100000110:
			begin
				colour[2:0] = inCube[20:18];
				position[6:0] = 7'b0010000+2'b10;
				drawY = 1;
				changeX = 1;
			end

			9'b101000110:
			begin
				colour[2:0] = inCube[20:18];
				position[6:0] = 7'b0010000+2'b10;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #07 BIN000111
			9'b001000111:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[20:18];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010000111:
			begin
				colour[2:0] = inCube[23:21];
				position[6:0] = 7'b0111000+2'b01;
				drawY = 1;
				changeX = 0;
			end


			9'b011000111:
			begin
				colour[2:0] = inCube[23:21];
				position[6:0] = 7'b0010000+2'b10;
				drawY = 1;
				changeX = 1;
			end

			9'b100000111:
			begin
				colour[2:0] = inCube[23:21];
				position[6:0] = 7'b0010000+2'b10;
				drawY = 1;
				changeX = 1;
			end

			9'b101000111:
			begin
				colour[2:0] = inCube[23:21];
				position[6:0] = 7'b0010000+2'b10;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #08 BIN001000
			9'b001001000:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[23:21];
				position[6:0] = 7'b0111100+2'b10;
				
			end

			9'b010001000:
			begin
				colour[2:0] = inCube[26:24];
				position[6:0] = 7'b0111100+2'b10;
				drawY = 1;
				changeX = 0;
			end


			9'b011001000:
			begin
				colour[2:0] = inCube[26:24];
				position[6:0] = 7'b0010000+2'b10;
				drawY = 1;
				changeX = 1;
			end

			9'b100001000:
			begin
				colour[2:0] = inCube[26:24];
				position[6:0] = 7'b0010000+2'b10;
				drawY = 1;
				changeX = 1;
			end

			9'b101001000:
			begin
				drawY = 0;
				changeX = 1;
				colour[2:0] = inCube[26:24];
				position[6:0] = 7'b0010000+2'b10;
				
			end
			
			9'b111111111:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[161:159];
				position[6:0] = 7'b1111111;
				
			end

			default:
			begin
				colour[2:0] = 3'b000;
				position[6:0] = 7'b000000;
				drawY = 1;
				changeX =1;
			end

			//FACE LEFT FACE LEFT FACE LEFT FACE LEFT FACE LEFT FACE LEFT FACE LEFT

//FACE LEFT FACE LEFT FACE LEFT FACE LEFT FACE LEFT FACE LEFT FACE LEFT

			// PIECE #09 BIN001001
			9'b001001001:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[26:24];
				position[6:0] = 7'b0101000-2'b11 ;
				
			end

			9'b010001001:
			begin
				colour[2:0] = inCube[29:27];
				position[6:0] = 7'b0101000-2'b11;
				drawY = 1;
				changeX = 0;
			end


			9'b011001001:
			begin
				colour[2:0] = inCube[29:27];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b100001001:
			begin
				colour[2:0] = inCube[29:27];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b101001001:
			begin
				colour[2:0] = inCube[29:27];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #10 BIN001010
			9'b001001010:
			begin
				drawY=1;
				changeX=1;
				colour[2:0] = inCube[29:27];
				position[6:0] = 7'b0101100-2'b10;
				
			end

			9'b010001010:
			begin
				colour[2:0] = inCube[32:30];
				position[6:0] = 7'b0101100-2'b10;
				drawY=1;
				changeX=0;
			end


			9'b011001010:
			begin
				colour[2:0] = inCube[32:30];
				position[6:0] = 7'b0010100+2'b11 ;
				drawY=1;
				changeX=1;
			end

			9'b100001010:
			begin
				colour[2:0] = inCube[32:30];
				position[6:0] = 7'b0010100+2'b11 ;
				drawY=1;
				changeX=1;
			end

			9'b101001010:
			begin
				colour[2:0] = inCube[32:30];
				position[6:0] = 7'b0010100+2'b11 ;
				drawY=0;
				changeX=1;
			end



			// PIECE #11 BIN001011
			9'b001001011:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[32:30];
				position[6:0] = 7'b0110000-2'b01;
				
			end

			9'b010001011:
			begin
				colour[2:0] = inCube[35:33];
				position[6:0] = 7'b0110000-2'b01;
				drawY = 1;
				changeX = 0;
			end


			9'b011001011:
			begin
				colour[2:0] = inCube[35:33];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b100001011:
			begin
				colour[2:0] = inCube[35:33];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b101001011:
			begin
				colour[2:0] = inCube[35:33];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #12 BIN001100
			9'b001001100:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[35:33];
				position[6:0] = 7'b0101000-2'b11;
				
			end

			9'b010001100:
			begin
				colour[2:0] = inCube[38:36];
				position[6:0] = 7'b0101000-2'b11;
				drawY = 1;
				changeX = 0;
			end


			9'b011001100:
			begin
				colour[2:0] = inCube[38:36];
				position[6:0] = 7'b0011000+3'b100 ;
				drawY = 1;
				changeX = 1;
			end

			9'b100001100:
			begin
				colour[2:0] = inCube[38:36];
				position[6:0] = 7'b0011000+3'b100 ;
				drawY = 1;
				changeX = 1;
			end

			9'b101001100:
			begin
				colour[2:0] = inCube[38:36];
				position[6:0] = 7'b0011000+3'b100 ;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #13 BIN001101
			9'b001001101:
			begin
				drawY =1;
				changeX = 1;
				colour[2:0] = inCube[38:36];
				position[6:0] = 7'b0101100-2'b10;
				
			end

			9'b010001101:
			begin
				colour[2:0] = inCube[41:39];
				position[6:0] = 7'b0101100-2'b10;
				drawY =1;
				changeX = 0;
			end


			9'b011001101:
			begin
				colour[2:0] = inCube[41:39];
				position[6:0] = 7'b0011000+3'b100;
				drawY =1;
				changeX = 1;
			end

			9'b100001101:
			begin
				colour[2:0] = inCube[41:39];
				position[6:0] = 7'b0011000+3'b100;
				drawY =1;
				changeX = 1;
			end

			9'b101001101:
			begin
				colour[2:0] = inCube[41:39];
				position[6:0] = 7'b0011000+3'b100;
				drawY =0;
				changeX = 1;
			end



			// PIECE #14 BIN001110
			9'b001001110:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[41:39];
				position[6:0] = 7'b0110000-2'b01;
				
			end

			9'b010001110:
			begin
				colour[2:0] = inCube[44:42];
				position[6:0] = 7'b0110000-2'b01;
				drawY = 1;
				changeX = 0;
			end


			9'b011001110:
			begin
				colour[2:0] = inCube[44:42];
				position[6:0] = 7'b0011000+3'b100;
				drawY = 1;
				changeX = 1;
			end

			9'b100001110:
			begin
				colour[2:0] = inCube[44:42];
				position[6:0] = 7'b0011000+3'b100;
				drawY = 1;
				changeX = 1;
			end

			9'b101001110:
			begin
				colour[2:0] = inCube[44:42];
				position[6:0] = 7'b0011000+3'b100;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #15 BIN001111
			9'b001001111:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[44:42];
				position[6:0] = 7'b0101000-2'b11;
				
			end

			9'b010001111:
			begin
				colour[2:0] = inCube[47:45];
				position[6:0] = 7'b0101000-2'b11;
				drawY = 1;
				changeX = 0;
			end


			9'b011001111:
			begin
				colour[2:0] = inCube[47:45];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b100001111:
			begin
				colour[2:0] = inCube[47:45];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b101001111:
			begin
				colour[2:0] = inCube[47:45];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #16 BIN010000
			9'b001010000:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[47:45];
				position[6:0] = 7'b0101100-2'b10;
				
			end

			9'b010010000:
			begin
				colour[2:0] = inCube[50:48];
				position[6:0] = 7'b0101100-2'b10;
				drawY = 1;
				changeX = 0;
			end


			9'b011010000:
			begin
				colour[2:0] = inCube[50:48];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b100010000:
			begin
				colour[2:0] = inCube[50:48];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b101010000:
			begin
				colour[2:0] = inCube[50:48];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #17 BIN010001
			9'b001010001:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[50:48];
				position[6:0] = 7'b0110000-2'b01;
				
			end

			9'b010010001:
			begin
				colour[2:0] = inCube[53:51];
				position[6:0] = 7'b0110000-2'b01;
				drawY = 1;
				changeX = 0;
			end


			9'b011010001:
			begin
				colour[2:0] = inCube[53:51];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b100010001:
			begin
				colour[2:0] = inCube[53:51];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b101010001:
			begin
				drawY = 0;
				changeX = 1;
				colour[2:0] = inCube[53:51];
				position[6:0] = 7'b0011100+3'b101;
				
			end
			
			


		
			//FACE FRONT FACE FRONT FACE FRONT FACE FRONT FACE FRONT FACE FRONT


			// PIECE #18 BIN 010010
			9'b001010010:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[53:51];
				position[6:0] = 7'b0110100 ;
				
			end

			9'b010010010:
			begin
				colour[2:0] = inCube[56:54];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011010010:
			begin
				colour[2:0] = inCube[56:54];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b100010010:
			begin
				colour[2:0] = inCube[56:54];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b101010010:
			begin
				colour[2:0] = inCube[56:54];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #19 BIN 010011
			9'b001010011:
			begin
				drawY=1;
				changeX=1;
				colour[2:0] = inCube[56:54];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010010011:
			begin
				colour[2:0] = inCube[59:57];
				position[6:0] = 7'b0111000+2'b01;
				drawY=1;
				changeX=0;
			end


			9'b011010011:
			begin
				colour[2:0] = inCube[59:57];
				position[6:0] = 7'b0010100+2'b11 ;
				drawY=1;
				changeX=1;
			end

			9'b100010011:
			begin
				colour[2:0] = inCube[59:57];
				position[6:0] = 7'b0010100+2'b11 ;
				drawY=1;
				changeX=1;
			end

			9'b101010011:
			begin
				colour[2:0] = inCube[59:57];
				position[6:0] = 7'b0010100+2'b11 ;
				drawY=0;
				changeX=1;
			end



			// PIECE #20 BIN 010100
			9'b001010100:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[59:57];
				position[6:0] = 7'b0111100+2'b10;
				
			end

			9'b010010100:
			begin
				colour[2:0] = inCube[62:60];
				position[6:0] = 7'b0111100+2'b10;
				drawY = 1;
				changeX = 0;
			end


			9'b011010100:
			begin
				colour[2:0] = inCube[62:60];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b100010100:
			begin
				colour[2:0] = inCube[62:60];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b101010100:
			begin
				colour[2:0] = inCube[62:60];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #21 BIN 010101
			9'b001010101:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[62:60];
				position[6:0] = 7'b0110100;
				
			end

			9'b010010101:
			begin
				colour[2:0] = inCube[65:63];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011010101:
			begin
				colour[2:0] = inCube[65:63];
				position[6:0] = 7'b0011000+3'b100 ;
				drawY = 1;
				changeX = 1;
			end

			9'b100010101:
			begin
				colour[2:0] = inCube[65:63];
				position[6:0] = 7'b0011000+3'b100 ;
				drawY = 1;
				changeX = 1;
			end

			9'b101010101:
			begin
				colour[2:0] = inCube[65:63];
				position[6:0] = 7'b0011000+3'b100 ;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #22 BIN 010110
			9'b001010110:
			begin
				drawY =1;
				changeX = 1;
				colour[2:0] = inCube[65:63];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010010110:
			begin
				colour[2:0] = inCube[68:66];
				position[6:0] = 7'b0111000+2'b01;
				drawY =1;
				changeX = 0;
			end


			9'b011010110:
			begin
				colour[2:0] = inCube[68:66];
				position[6:0] = 7'b0011000+3'b100;
				drawY =1;
				changeX = 1;
			end

			9'b100010110:
			begin
				colour[2:0] = inCube[68:66];
				position[6:0] = 7'b0011000+3'b100;
				drawY =1;
				changeX = 1;
			end

			9'b101010110:
			begin
				colour[2:0] = inCube[68:66];
				position[6:0] = 7'b0011000+3'b100;
				drawY =0;
				changeX = 1;
			end



			// PIECE #23 BIN 010111
			9'b001010111:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[68:66];
				position[6:0] = 7'b0111100+2'b10;
				
			end

			9'b010010111:
			begin
				colour[2:0] = inCube[71:69];
				position[6:0] = 7'b0111100+2'b10;
				drawY = 1;
				changeX = 0;
			end


			9'b011010111:
			begin
				colour[2:0] = inCube[71:69];
				position[6:0] = 7'b0011000+3'b100;
				drawY = 1;
				changeX = 1;
			end

			9'b100010111:
			begin
				colour[2:0] = inCube[71:69];
				position[6:0] = 7'b0011000+3'b100;
				drawY = 1;
				changeX = 1;
			end

			9'b101010111:
			begin
				colour[2:0] = inCube[71:69];
				position[6:0] = 7'b0011000+3'b100;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #24 BIN 011000
			9'b001011000:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[71:69];
				position[6:0] = 7'b0110100;
				
			end

			9'b010011000:
			begin
				colour[2:0] = inCube[74:72];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011011000:
			begin
				colour[2:0] = inCube[74:72];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b100011000:
			begin
				colour[2:0] = inCube[74:72];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b101011000:
			begin
				colour[2:0] = inCube[74:72];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #25 BIN 011001
			9'b001011001:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[74:72];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010011001:
			begin
				colour[2:0] = inCube[77:75];
				position[6:0] = 7'b0111000+2'b01;
				drawY = 1;
				changeX = 0;
			end


			9'b011011001:
			begin
				colour[2:0] = inCube[77:75];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b100011001:
			begin
				colour[2:0] = inCube[77:75];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b101011001:
			begin
				colour[2:0] = inCube[77:75];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #26 BIN 011010
			9'b001011010:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[77:75];
				position[6:0] = 7'b0111100+2'b10;
				
			end

			9'b010011010:
			begin
				colour[2:0] = inCube[80:78];
				position[6:0] = 7'b0111100+2'b10;
				drawY = 1;
				changeX = 0;
			end


			9'b011011010:
			begin
				colour[2:0] = inCube[80:78];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b100011010:
			begin
				colour[2:0] = inCube[80:78];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b101011010:
			begin
				drawY = 0;
				changeX = 1;
				colour[2:0] = inCube[80:78];
				position[6:0] = 7'b0011100+3'b101;
				
			end
			
			

			//FACE RIGHT FACE RIGHT FACE RIGHT FACE RIGHT FACE RIGHT FACE RIGHT 


			// PIECE #27 BIN 011011
			9'b001011011:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[80:78];
				position[6:0] = 7'b0110100+2'b11 +7'b0001100;
				
			end

			9'b010011011:
			begin
				colour[2:0] = inCube[83:81];
				position[6:0] = 7'b0110100+2'b11 +7'b0001100;
				drawY = 1;
				changeX = 0;
			end


			9'b011011011:
			begin
				colour[2:0] = inCube[83:81];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b100011011:
			begin
				colour[2:0] = inCube[83:81];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b101011011:
			begin
				colour[2:0] = inCube[83:81];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #28 BIN 011100
			9'b001011100:
			begin
				drawY=1;
				changeX=1;
				colour[2:0] = inCube[83:81];
				position[6:0] = 7'b0111000+3'b100 +7'b0001100;
				
			end

			9'b010011100:
			begin
				colour[2:0] = inCube[86:84];
				position[6:0] = 7'b0111000+3'b100 +7'b0001100;
				drawY=1;
				changeX=0;
			end


			9'b011011100:
			begin
				colour[2:0] = inCube[86:84];
				position[6:0] = 7'b0010100+2'b11 ;
				drawY=1;
				changeX=1;
			end

			9'b100011100:
			begin
				colour[2:0] = inCube[86:84];
				position[6:0] = 7'b0010100+2'b11 ;
				drawY=1;
				changeX=1;
			end

			9'b101011100:
			begin
				colour[2:0] = inCube[86:84];
				position[6:0] = 7'b0010100+2'b11 ;
				drawY=0;
				changeX=1;
			end



			// PIECE #29 BIN 011101
			9'b001011101:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[86:84];
				position[6:0] = 7'b0111100+3'b101 +7'b0001100;
				
			end

			9'b010011101:
			begin
				colour[2:0] = inCube[89:87];
				position[6:0] = 7'b0111100+3'b101 +7'b0001100;
				drawY = 1;
				changeX = 0;
			end


			9'b011011101:
			begin
				colour[2:0] = inCube[89:87];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b100011101:
			begin
				colour[2:0] = inCube[89:87];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 1;
				changeX = 1;
			end

			9'b101011101:
			begin
				colour[2:0] = inCube[89:87];
				position[6:0] = 7'b0010100+2'b11;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #30 BIN 011110
			9'b001011110:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[89:87];
				position[6:0] = 7'b0110100+2'b11 +7'b0001100;
				
			end

			9'b010011110:
			begin
				colour[2:0] = inCube[92:90];
				position[6:0] = 7'b0110100+2'b11 +7'b0001100;
				drawY = 1;
				changeX = 0;
			end


			9'b011011110:
			begin
				colour[2:0] = inCube[92:90];
				position[6:0] = 7'b0011000+3'b100 ;
				drawY = 1;
				changeX = 1;
			end

			9'b100011110:
			begin
				colour[2:0] = inCube[92:90];
				position[6:0] = 7'b0011000+3'b100 ;
				drawY = 1;
				changeX = 1;
			end

			9'b101011110:
			begin
				colour[2:0] = inCube[92:90];
				position[6:0] = 7'b0011000+3'b100 ;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #31 BIN 011111
			9'b001011111:
			begin
				drawY =1;
				changeX = 1;
				colour[2:0] = inCube[92:90];
				position[6:0] = 7'b0111000+3'b100 +7'b0001100;
				
			end

			9'b010011111:
			begin
				colour[2:0] = inCube[95:93];
				position[6:0] = 7'b0111000+3'b100 +7'b0001100;
				drawY =1;
				changeX = 0;
			end


			9'b011011111:
			begin
				colour[2:0] = inCube[95:93];
				position[6:0] = 7'b0011000+3'b100;
				drawY =1;
				changeX = 1;
			end

			9'b100011111:
			begin
				colour[2:0] = inCube[95:93];
				position[6:0] = 7'b0011000+3'b100;
				drawY =1;
				changeX = 1;
			end

			9'b101011111:
			begin
				colour[2:0] = inCube[95:93];
				position[6:0] = 7'b0011000+3'b100;
				drawY =0;
				changeX = 1;
			end



			// PIECE #32 BIN 100000
			9'b001100000:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[95:93];
				position[6:0] = 7'b0111100+3'b101 +7'b0001100;
				
			end

			9'b010100000:
			begin
				colour[2:0] = inCube[98:96];
				position[6:0] = 7'b0111100+3'b101 +7'b0001100;
				drawY = 1;
				changeX = 0;
			end


			9'b011100000:
			begin
				colour[2:0] = inCube[98:96];
				position[6:0] = 7'b0011000+3'b100;
				drawY = 1;
				changeX = 1;
			end

			9'b100100000:
			begin
				colour[2:0] = inCube[98:96];
				position[6:0] = 7'b0011000+3'b100;
				drawY = 1;
				changeX = 1;
			end

			9'b101100000:
			begin
				colour[2:0] = inCube[98:96];
				position[6:0] = 7'b0011000+3'b100;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #33 BIN 100001
			9'b001100001:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[98:96];
				position[6:0] = 7'b0110100+2'b11 +7'b0001100;
				
			end

			9'b010100001:
			begin
				colour[2:0] = inCube[101:99];
				position[6:0] = 7'b0110100+2'b11 +7'b0001100;
				drawY = 1;
				changeX = 0;
			end


			9'b011100001:
			begin
				colour[2:0] = inCube[101:99];
				position[6:0] = 7'b0110100+2'b11 +7'b0001100;
				drawY = 1;
				changeX = 0;
			end

			9'b100100001:
			begin
				colour[2:0] = inCube[101:99];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b101100001:
			begin
				colour[2:0] = inCube[101:99];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #34 BIN 100010
			9'b001100010:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[101:99];
				position[6:0] = 7'b0111000+3'b100 +7'b0001100;
				
			end

			9'b010100010:
			begin
				colour[2:0] = inCube[104:102];
				position[6:0] = 7'b0111000+3'b100 +7'b0001100;
				drawY = 1;
				changeX = 0;
			end


			9'b011100010:
			begin
				colour[2:0] = inCube[104:102];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b100100010:
			begin
				colour[2:0] = inCube[104:102];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b101100010:
			begin
				colour[2:0] = inCube[104:102];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #35 BIN 100011
			9'b001100011:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[104:102];
				position[6:0] = 7'b0111100+3'b101 +7'b0001100;
				
			end

			9'b010100011:
			begin
				colour[2:0] = inCube[107:105];
				position[6:0] = 7'b0111100+3'b101 +7'b0001100;
				drawY = 1;
				changeX = 0;
			end


			9'b011100011:
			begin
				colour[2:0] = inCube[107:105];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b100100011:
			begin
				colour[2:0] = inCube[107:105];
				position[6:0] = 7'b0011100+3'b101;
				drawY = 1;
				changeX = 1;
			end

			9'b101100011:
			begin
				drawY = 0;
				changeX = 1;
				colour[2:0] = inCube[107:105];
				position[6:0] = 7'b0011100+3'b101;
				
			end



			//FACE BOTTOM FACE BOTTOM FACE BOTTOM FACE BOTTOM FACE BOTTOM FACE BOTTOM



			// PIECE #36 BIN 100100
			9'b001100100:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[107:105];
				position[6:0] = 7'b0110100 ;
				
			end

			9'b010100100:
			begin
				colour[2:0] = inCube[110:108];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011100100:
			begin
				colour[2:0] = inCube[110:108];
				position[6:0] = 7'b0010100+3'b110 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b100100100:
			begin
				colour[2:0] = inCube[110:108];
				position[6:0] = 7'b0010100+3'b110 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b101100100:
			begin
				colour[2:0] = inCube[110:108];
				position[6:0] = 7'b0010100+3'b110 +7'b0001100;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #37 BIN 100101
			9'b001100101:
			begin
				drawY=1;
				changeX=1;
				colour[2:0] = inCube[110:108];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010100101:
			begin
				colour[2:0] = inCube[113:111];
				position[6:0] = 7'b0111000+2'b01;
				drawY=1;
				changeX=0;
			end


			9'b011100101:
			begin
				colour[2:0] = inCube[113:111];
				position[6:0] = 7'b0010100+3'b110  +7'b0001100;
				drawY=1;
				changeX=1;
			end

			9'b100100101:
			begin
				colour[2:0] = inCube[113:111];
				position[6:0] = 7'b0010100+3'b110  +7'b0001100;
				drawY=1;
				changeX=1;
			end

			9'b101100101:
			begin
				colour[2:0] = inCube[113:111];
				position[6:0] = 7'b0010100+3'b110  +7'b0001100;
				drawY=0;
				changeX=1;
			end



			// PIECE #38 BIN 100110
			9'b001100110:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[113:111];
				position[6:0] = 7'b0111000+2'b10+3'b100;
				
			end

			9'b010100110:
			begin
				colour[2:0] = inCube[116:114];
				position[6:0] = 7'b0111000+2'b10+3'b100;
				drawY = 1;
				changeX = 0;
			end


			9'b011100110:
			begin
				colour[2:0] = inCube[116:114];
				position[6:0] = 7'b0010100+3'b110 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b100100110:
			begin
				colour[2:0] = inCube[116:114];
				position[6:0] = 7'b0010100+3'b110 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b101100110:
			begin
				colour[2:0] = inCube[116:114];
				position[6:0] = 7'b0010100+3'b110 +7'b0001100;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #39 BIN 100111
			9'b001100111:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[116:114];
				position[6:0] = 7'b0110100;
				
			end

			9'b010100111:
			begin
				colour[2:0] = inCube[119:117];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011100111:
			begin
				colour[2:0] = inCube[119:117];
				position[6:0] = 7'b0011000+3'b111  +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b100100111:
			begin
				colour[2:0] = inCube[119:117];
				position[6:0] = 7'b0011000+3'b111  +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b101100111:
			begin
				colour[2:0] = inCube[119:117];
				position[6:0] = 7'b0011000+3'b111  +7'b0001100;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #40 BIN 101000
			9'b001101000:
			begin
				drawY =1;
				changeX = 1;
				colour[2:0] = inCube[119:117];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010101000:
			begin
				colour[2:0] = inCube[122:120];
				position[6:0] = 7'b0111000+2'b01;
				drawY =1;
				changeX = 0;
			end


			9'b011101000:
			begin
				colour[2:0] = inCube[122:120];
				position[6:0] = 7'b0011000+3'b111 +7'b0001100;
				drawY =1;
				changeX = 1;
			end

			9'b100101000:
			begin
				colour[2:0] = inCube[122:120];
				position[6:0] = 7'b0011000+3'b111 +7'b0001100;
				drawY =1;
				changeX = 1;
			end

			9'b101101000:
			begin
				colour[2:0] = inCube[122:120];
				position[6:0] = 7'b0011000+3'b111 +7'b0001100;
				drawY =0;
				changeX = 1;
			end



			// PIECE #41 BIN 101001
			9'b001101001:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[122:120];
				position[6:0] = 7'b0111000+2'b10+3'b100;
				
			end

			9'b010101001:
			begin
				colour[2:0] = inCube[125:123];
				position[6:0] = 7'b0111000+2'b10+3'b100;
				drawY = 1;
				changeX = 0;
			end


			9'b011101001:
			begin
				colour[2:0] = inCube[125:123];
				position[6:0] = 7'b0011000+3'b111 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b100101001:
			begin
				colour[2:0] = inCube[125:123];
				position[6:0] = 7'b0011000+3'b111 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b101101001:
			begin
				colour[2:0] = inCube[125:123];
				position[6:0] = 7'b0011000+3'b111 +7'b0001100;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #42 BIN 101010
			9'b001101010:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[125:123];
				position[6:0] = 7'b0110100;
				
			end

			9'b010101010:
			begin
				colour[2:0] = inCube[128:126];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011101010:
			begin
				colour[2:0] = inCube[128:126];
				position[6:0] = 7'b0011100+4'b1000 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b100101010:
			begin
				colour[2:0] = inCube[128:126];
				position[6:0] = 7'b0011100+4'b1000 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b101101010:
			begin
				colour[2:0] = inCube[128:126];
				position[6:0] = 7'b0011100+4'b1000 +7'b0001100;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #43 BIN 101011
			9'b001101011:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[128:126];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010101011:
			begin
				colour[2:0] = inCube[131:129];
				position[6:0] = 7'b0111000+2'b01;
				drawY = 1;
				changeX = 0;
			end


			9'b011101011:
			begin
				colour[2:0] = inCube[131:129];
				position[6:0] = 7'b0011100+4'b1000 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b100101011:
			begin
				colour[2:0] = inCube[131:129];
				position[6:0] = 7'b0011100+4'b1000 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b101101011:
			begin
				colour[2:0] = inCube[131:129];
				position[6:0] = 7'b0011100+4'b1000 +7'b0001100;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #44 BIN 101100
			9'b001101100:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[131:129];
				position[6:0] = 7'b0111000+2'b10+3'b100;
				
			end

			9'b010101100:
			begin
				colour[2:0] = inCube[134:132];
				position[6:0] = 7'b0111000+2'b10+3'b100;
				drawY = 1;
				changeX = 0;
			end


			9'b011101100:
			begin
				colour[2:0] = inCube[134:132];
				position[6:0] = 7'b0011100+4'b1000 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b100101100:
			begin
				colour[2:0] = inCube[134:132];
				position[6:0] = 7'b0011100+4'b1000 +7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b101101100:
			begin
				drawY = 0;
				changeX = 1;
				colour[2:0] = inCube[134:132];
				position[6:0] = 7'b0011100+4'b1000 +7'b0001100;
				
			end
			

		//FACE BACK FACE BACK FACE BACK FACE BACK FACE BACK FACE BACK FACE BACK 


			// PIECE #45 BIN 101101  
			9'b001101101:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[134:132];
				position[6:0] = 7'b0110100 ;
				
			end

			9'b010101101:
			begin
				colour[2:0] = inCube[137:135];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011101101:
			begin
				colour[2:0] = inCube[137:135];
				position[6:0] = 7'b0010100+4'b1001 + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b100101101:
			begin
				colour[2:0] = inCube[137:135];
				position[6:0] = 7'b0010100+4'b1001  + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b101101101:
			begin
				colour[2:0] = inCube[137:135];
				position[6:0] = 7'b0010100+4'b1001  + 7'b0011000;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #46 BIN 101110 
			9'b001101110:
			begin
				drawY=1;
				changeX=1;
				colour[2:0] = inCube[137:135];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010101110:
			begin
				colour[2:0] = inCube[140:138];
				position[6:0] = 7'b0111000+2'b01;
				drawY=1;
				changeX=0;
			end


			9'b011101110:
			begin
				colour[2:0] = inCube[140:138];
				position[6:0] = 7'b0010100+4'b1001  + 7'b0011000;
				drawY=1;
				changeX=1;
			end

			9'b100101110:
			begin
				colour[2:0] = inCube[140:138];
				position[6:0] = 7'b0010100+4'b1001  + 7'b0011000;
				drawY=1;
				changeX=1;
			end

			9'b101101110:
			begin
				colour[2:0] = inCube[140:138];
				position[6:0] = 7'b0010100+4'b1001  + 7'b0011000;
				drawY=0;
				changeX=1;
			end



			// PIECE #47 BIN 101111
			9'b001101111:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[140:138];
				position[6:0] = 7'b0111100+2'b10;
				
			end

			9'b010101111:
			begin
				colour[2:0] = inCube[143:141];
				position[6:0] = 7'b0111100+2'b10;
				drawY = 1;
				changeX = 0;
			end


			9'b011101111:
			begin
				colour[2:0] = inCube[143:141];
				position[6:0] = 7'b0010100+4'b1001 + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b100101111:
			begin
				colour[2:0] = inCube[143:141];
				position[6:0] = 7'b0010100+4'b1001 + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b101101111:
			begin
				colour[2:0] = inCube[143:141];
				position[6:0] = 7'b0010100+4'b1001 + 7'b0011000;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #48 BIN 110000 
			9'b001110000:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[143:141];
				position[6:0] = 7'b0110100;
				
			end

			9'b010110000:
			begin
				colour[2:0] = inCube[146:144];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011110000:
			begin
				colour[2:0] = inCube[146:144];
				position[6:0] = 7'b0011000 +4'b1010+ 7'b0011000 ;
				drawY = 1;
				changeX = 1;
			end

			9'b100110000:
			begin
				colour[2:0] = inCube[146:144];
				position[6:0] = 7'b0011000 +4'b1010 + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b101110000:
			begin
				colour[2:0] = inCube[146:144];
				position[6:0] = 7'b0011000 +4'b1010+ 7'b0011000 ;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #49 BIN 110001
			9'b001110001:
			begin
				drawY =1;
				changeX = 1;
				colour[2:0] = inCube[146:144];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010110001:
			begin
				colour[2:0] = inCube[149:147];
				position[6:0] = 7'b0111000+2'b01;
				drawY =1;
				changeX = 0;
			end


			9'b011110001:
			begin
				colour[2:0] = inCube[149:147];
				position[6:0] = 7'b0011000 +4'b1010+ 7'b0011000;
				drawY =1;
				changeX = 1;
			end

			9'b100110001:
			begin
				colour[2:0] = inCube[149:147];
				position[6:0] = 7'b0011000+4'b1010 + 7'b0011000;
				drawY =1;
				changeX = 1;
			end

			9'b101110001:
			begin
				colour[2:0] = inCube[149:147];
				position[6:0] = 7'b0011000+4'b1010 + 7'b0011000;
				drawY =0;
				changeX = 1;
			end



			// PIECE #50 BIN 110010
			9'b001110010:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[149:147];
				position[6:0] = 7'b0111100+2'b10;
				
			end

			9'b010110010:
			begin
				colour[2:0] = inCube[152:150];
				position[6:0] = 7'b0111100+2'b10;
				drawY = 1;
				changeX = 0;
			end


			9'b011110010:
			begin
				colour[2:0] = inCube[152:150];
				position[6:0] = 7'b0011000+4'b1010 + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b100110010:
			begin
				colour[2:0] = inCube[152:150];
				position[6:0] = 7'b0011000 +4'b1010+ 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b101110010:
			begin
				colour[2:0] = inCube[152:150];
				position[6:0] = 7'b0011000 +4'b1010+ 7'b0011000;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #51 BIN 110011
			9'b001110011:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[152:150];
				position[6:0] = 7'b0110100;
				
			end

			9'b010110011:
			begin
				colour[2:0] = inCube[155:153];
				position[6:0] = 7'b0110100;
				drawY = 1;
				changeX = 0;
			end


			9'b011110011:
			begin
				colour[2:0] = inCube[155:153];
				position[6:0] = 7'b0011100+4'b1011 + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b100110011:
			begin
				colour[2:0] = inCube[155:153];
				position[6:0] = 7'b0011100+4'b1011 + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b101110011:
			begin
				colour[2:0] = inCube[155:153];
				position[6:0] = 7'b0011100+4'b1011 + 7'b0011000;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #52 BIN 110100
			9'b001110100:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[155:153];
				position[6:0] = 7'b0111000+2'b01;
				
			end

			9'b010110100:
			begin
				colour[2:0] = inCube[158:156];
				position[6:0] = 7'b0111000+2'b01;
				drawY = 1;
				changeX = 0;
			end


			9'b011110100:
			begin
				colour[2:0] = inCube[158:156];
				position[6:0] = 7'b0011100+4'b1011 + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b100110100:
			begin
				colour[2:0] = inCube[158:156];
				position[6:0] = 7'b0011100+4'b1011 + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b101110100:
			begin
				colour[2:0] = inCube[158:156];
				position[6:0] = 7'b0011100+4'b1011 + 7'b0011000;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #53 BIN 110101 
			9'b001110101:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[158:156];
				position[6:0] = 7'b0111100+2'b10;
				
			end

			9'b010110101:
			begin
				colour[2:0] = inCube[161:159];
				position[6:0] = 7'b0111100+2'b10;
				drawY = 1;
				changeX = 0;
			end


			9'b011110101:
			begin
				colour[2:0] = inCube[161:159];
				position[6:0] = 7'b0011100+4'b1011 + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b100110101:
			begin
				colour[2:0] = inCube[161:159];
				position[6:0] = 7'b0011100+4'b1011 + 7'b0011000;
				drawY = 1;
				changeX = 1;
			end

			9'b101110101:
			begin
				drawY = 0;
				changeX = 1;
				colour[2:0] = inCube[161:159];
				position[6:0] = 7'b0011100+4'b1011 + 7'b0011000;
				
			end


		endcase
	end

endmodule

module drawCubeStateTable (presDrawState, nxtDrawState, GO, clock);

	input[8:0] presDrawState;
	input GO, clock;
	output reg [8:0] nxtDrawState;

	

	always @(*)
	begin
	case(presDrawState)

		9'b000000000:
		begin
			if(GO)
				nxtDrawState <= 9'b001000000;
			else
				nxtDrawState <= 9'b000000000;
		end
		//Piece 000000
		9'b001000000: nxtDrawState = 9'b010000000 ;
		9'b010000000: nxtDrawState = 9'b011000000 ;
		9'b011000000: nxtDrawState = 9'b100000000 ;
		9'b100000000: nxtDrawState = 9'b101000000 ;
		9'b101000000: nxtDrawState = 9'b001000001 ;
		//Piece 000001
		9'b001000001: nxtDrawState = 9'b010000001 ;
		9'b010000001: nxtDrawState = 9'b011000001 ;
		9'b011000001: nxtDrawState = 9'b100000001 ;
		9'b100000001: nxtDrawState = 9'b101000001 ;
		9'b101000001: nxtDrawState = 9'b001000010 ;
		//Piece 000010 
		9'b001000010: nxtDrawState = 9'b010000010 ;
		9'b010000010: nxtDrawState = 9'b011000010 ;
		9'b011000010: nxtDrawState = 9'b100000010 ;
		9'b100000010: nxtDrawState = 9'b101000010 ;
		9'b101000010: nxtDrawState = 9'b001000011 ;
		//Piece 000011
		9'b001000011: nxtDrawState = 9'b010000011 ;
		9'b010000011: nxtDrawState = 9'b011000011 ;
		9'b011000011: nxtDrawState = 9'b100000011 ;
		9'b100000011: nxtDrawState = 9'b101000011 ;
		9'b101000011: nxtDrawState = 9'b001000100 ;
		//Piece 000100
		9'b001000100: nxtDrawState = 9'b010000100 ;
		9'b010000100: nxtDrawState = 9'b011000100 ;
		9'b011000100: nxtDrawState = 9'b100000100 ;
		9'b100000100: nxtDrawState = 9'b101000100 ;
		9'b101000100: nxtDrawState = 9'b001000101 ;
		//Piece 000101
		9'b001000101: nxtDrawState = 9'b010000101 ;
		9'b010000101: nxtDrawState = 9'b011000101 ;
		9'b011000101: nxtDrawState = 9'b100000101 ;
		9'b100000101: nxtDrawState = 9'b101000101 ;
		9'b101000101: nxtDrawState = 9'b001000110 ;
		//Piece 000110
		9'b001000110: nxtDrawState = 9'b010000110 ;
		9'b010000110: nxtDrawState = 9'b011000110 ;
		9'b011000110: nxtDrawState = 9'b100000110 ;
		9'b100000110: nxtDrawState = 9'b101000110 ;
		9'b101000110: nxtDrawState = 9'b001000111 ;
		//Piece 000111
		9'b001000111: nxtDrawState = 9'b010000111 ;
		9'b010000111: nxtDrawState = 9'b011000111 ;
		9'b011000111: nxtDrawState = 9'b100000111 ;
		9'b100000111: nxtDrawState = 9'b101000111 ;
		9'b101000111: nxtDrawState = 9'b001001000 ;
		//Piece 001000
		9'b001001000: nxtDrawState = 9'b010001000 ;
		9'b010001000: nxtDrawState = 9'b011001000 ;
		9'b011001000: nxtDrawState = 9'b100001000 ;
		9'b100001000: nxtDrawState = 9'b101001000 ;
		9'b101001000: nxtDrawState = 9'b001001001 ;
		//001001
		9'b001001001: nxtDrawState = 9'b010001001 ;
		9'b010001001: nxtDrawState = 9'b011001001 ;
		9'b011001001: nxtDrawState = 9'b100001001 ;
		9'b100001001: nxtDrawState = 9'b101001001 ;
		9'b101001001: nxtDrawState = 9'b001001010 ;
		//001010
		9'b001001010: nxtDrawState = 9'b010001010 ;
		9'b010001010: nxtDrawState = 9'b011001010 ;
		9'b011001010: nxtDrawState = 9'b100001010 ;
		9'b100001010: nxtDrawState = 9'b101001010 ;
		9'b101001010: nxtDrawState = 9'b001001011 ;
		//001011
		9'b001001011: nxtDrawState = 9'b010001011 ;
		9'b010001011: nxtDrawState = 9'b011001011 ;
		9'b011001011: nxtDrawState = 9'b100001011 ;
		9'b100001011: nxtDrawState = 9'b101001011 ;
		9'b101001011: nxtDrawState = 9'b001001100 ;
		//001100
		9'b001001100: nxtDrawState = 9'b010001100 ;
		9'b010001100: nxtDrawState = 9'b011001100 ;
		9'b011001100: nxtDrawState = 9'b100001100 ;
		9'b100001100: nxtDrawState = 9'b101001100 ;
		9'b101001100: nxtDrawState = 9'b001001101 ;
		//001101
		9'b001001101: nxtDrawState = 9'b010001101 ;
		9'b010001101: nxtDrawState = 9'b011001101 ;
		9'b011001101: nxtDrawState = 9'b100001101 ;
		9'b100001101: nxtDrawState = 9'b101001101 ;
		9'b101001101: nxtDrawState = 9'b001001110 ;
		//001110
		9'b001001110: nxtDrawState = 9'b010001110 ;
		9'b010001110: nxtDrawState = 9'b011001110 ;
		9'b011001110: nxtDrawState = 9'b100001110 ;
		9'b100001110: nxtDrawState = 9'b101001110 ;
		9'b101001110: nxtDrawState = 9'b001001111 ;
		//001111
		9'b001001111: nxtDrawState = 9'b010001111 ;
		9'b010001111: nxtDrawState = 9'b011001111 ;
		9'b011001111: nxtDrawState = 9'b100001111 ;
		9'b100001111: nxtDrawState = 9'b101001111 ;
		9'b101001111: nxtDrawState = 9'b001010000 ;
		//010000
		9'b001010000: nxtDrawState = 9'b010010000 ;
		9'b010010000: nxtDrawState = 9'b011010000 ;
		9'b011010000: nxtDrawState = 9'b100010000 ;
		9'b100010000: nxtDrawState = 9'b101010000 ;
		9'b101010000: nxtDrawState = 9'b001010001 ;
		//010001
		9'b001010001: nxtDrawState = 9'b010010001 ;
		9'b010010001: nxtDrawState = 9'b011010001 ;
		9'b011010001: nxtDrawState = 9'b100010001 ;
		9'b100010001: nxtDrawState = 9'b101010001 ;
		9'b101010001: nxtDrawState = 9'b001010010 ;
		//010010 
		9'b001010010: nxtDrawState = 9'b010010010 ;
		9'b010010010: nxtDrawState = 9'b011010010 ;
		9'b011010010: nxtDrawState = 9'b100010010 ;
		9'b100010010: nxtDrawState = 9'b101010010 ;
		9'b101010010: nxtDrawState = 9'b001010011 ;
		//010011 
		9'b001010011: nxtDrawState = 9'b010010011 ;
		9'b010010011: nxtDrawState = 9'b011010011 ;
		9'b011010011: nxtDrawState = 9'b100010011 ;
		9'b100010011: nxtDrawState = 9'b101010011 ;
		9'b101010011: nxtDrawState = 9'b001010100 ;
		//010100 
		9'b001010100: nxtDrawState = 9'b010010100 ;
		9'b010010100: nxtDrawState = 9'b011010100 ;
		9'b011010100: nxtDrawState = 9'b100010100 ;
		9'b100010100: nxtDrawState = 9'b101010100 ;
		9'b101010100: nxtDrawState = 9'b001010101 ;
		//010101 
		9'b001010101: nxtDrawState = 9'b010010101 ;
		9'b010010101: nxtDrawState = 9'b011010101 ;
		9'b011010101: nxtDrawState = 9'b100010101 ;
		9'b100010101: nxtDrawState = 9'b101010101 ;
		9'b101010101: nxtDrawState = 9'b001010110 ;
		//010110 
		9'b001010110: nxtDrawState = 9'b010010110 ;
		9'b010010110: nxtDrawState = 9'b011010110 ;
		9'b011010110: nxtDrawState = 9'b100010110 ;
		9'b100010110: nxtDrawState = 9'b101010110 ;
		9'b101010110: nxtDrawState = 9'b001010111 ;
		//010111 
		9'b001010111: nxtDrawState = 9'b010010111 ;
		9'b010010111: nxtDrawState = 9'b011010111 ;
		9'b011010111: nxtDrawState = 9'b100010111 ;
		9'b100010111: nxtDrawState = 9'b101010111 ;
		9'b101010111: nxtDrawState = 9'b001011000 ;
		//011000 
		9'b001011000: nxtDrawState = 9'b010011000 ;
		9'b010011000: nxtDrawState = 9'b011011000 ;
		9'b011011000: nxtDrawState = 9'b100011000 ;
		9'b100011000: nxtDrawState = 9'b101011000 ;
		9'b101011000: nxtDrawState = 9'b001011001 ;
		//011001 
		9'b001011001: nxtDrawState = 9'b010011001 ;
		9'b010011001: nxtDrawState = 9'b011011001 ;
		9'b011011001: nxtDrawState = 9'b100011001 ;
		9'b100011001: nxtDrawState = 9'b101011001 ;
		9'b101011001: nxtDrawState = 9'b001011010 ;
		//011010 
		9'b001011010: nxtDrawState = 9'b010011010 ;
		9'b010011010: nxtDrawState = 9'b011011010 ;
		9'b011011010: nxtDrawState = 9'b100011010 ;
		9'b100011010: nxtDrawState = 9'b101011010 ;
		9'b101011010: nxtDrawState = 9'b001011011 ;
		
		//011011 
		9'b001011011: nxtDrawState = 9'b010011011 ;
		9'b010011011: nxtDrawState = 9'b011011011 ;
		9'b011011011: nxtDrawState = 9'b100011011 ;
		9'b100011011: nxtDrawState = 9'b101011011 ;
		9'b101011011: nxtDrawState = 9'b001011100 ;
		//011100 
		9'b001011100: nxtDrawState = 9'b010011100 ;
		9'b010011100: nxtDrawState = 9'b011011100 ;
		9'b011011100: nxtDrawState = 9'b100011100 ;
		9'b100011100: nxtDrawState = 9'b101011100 ;
		9'b101011100: nxtDrawState = 9'b001011101 ;
		//011101 
		9'b001011101: nxtDrawState = 9'b010011101 ;
		9'b010011101: nxtDrawState = 9'b011011101 ;
		9'b011011101: nxtDrawState = 9'b100011101 ;
		9'b100011101: nxtDrawState = 9'b101011101 ;
		9'b101011101: nxtDrawState = 9'b001011110 ;
		//011110 
		9'b001011110: nxtDrawState = 9'b010011110 ;
		9'b010011110: nxtDrawState = 9'b011011110 ;
		9'b011011110: nxtDrawState = 9'b100011110 ;
		9'b100011110: nxtDrawState = 9'b101011110 ;
		9'b101011110: nxtDrawState = 9'b001011111 ;
		//011111 
		9'b001011111: nxtDrawState = 9'b010011111 ;
		9'b010011111: nxtDrawState = 9'b011011111 ;
		9'b011011111: nxtDrawState = 9'b100011111 ;
		9'b100011111: nxtDrawState = 9'b101011111 ;
		9'b101011111: nxtDrawState = 9'b001100000 ;
		//100000 
		9'b001100000: nxtDrawState = 9'b010100000 ;
		9'b010100000: nxtDrawState = 9'b011100000 ;
		9'b011100000: nxtDrawState = 9'b100100000 ;
		9'b100100000: nxtDrawState = 9'b101100000 ;
		9'b101100000: nxtDrawState = 9'b001100001 ;
		//100001 
		9'b001100001: nxtDrawState = 9'b010100001 ;
		9'b010100001: nxtDrawState = 9'b011100001 ;
		9'b011100001: nxtDrawState = 9'b100100001 ;
		9'b100100001: nxtDrawState = 9'b101100001 ;
		9'b101100001: nxtDrawState = 9'b001100010 ;
		//100010 
		9'b001100010: nxtDrawState = 9'b010100010 ;
		9'b010100010: nxtDrawState = 9'b011100010 ;
		9'b011100010: nxtDrawState = 9'b100100010 ;
		9'b100100010: nxtDrawState = 9'b101100010 ;
		9'b101100010: nxtDrawState = 9'b001100011 ;
		//100011 
		9'b001100011: nxtDrawState = 9'b010100011 ;
		9'b010100011: nxtDrawState = 9'b011100011 ;
		9'b011100011: nxtDrawState = 9'b100100011 ;
		9'b100100011: nxtDrawState = 9'b101100011 ;
		9'b101100011: nxtDrawState = 9'b001100100 ;
		
		
				//100100
		9'b001100100: nxtDrawState = 9'b010100100 ;
		9'b010100100: nxtDrawState = 9'b011100100 ;
		9'b011100100: nxtDrawState = 9'b100100100 ;
		9'b100100100: nxtDrawState = 9'b101100100 ;
		9'b101100100: nxtDrawState = 9'b001100101 ;
		//100101 100101
		9'b001100101: nxtDrawState = 9'b010100101 ;
		9'b010100101: nxtDrawState = 9'b011100101 ;
		9'b011100101: nxtDrawState = 9'b100100101 ;
		9'b100100101: nxtDrawState = 9'b101100101 ;
		9'b101100101: nxtDrawState = 9'b001100110 ;
		//100110 100110
		9'b001100110: nxtDrawState = 9'b010100110 ;
		9'b010100110: nxtDrawState = 9'b011100110 ;
		9'b011100110: nxtDrawState = 9'b100100110 ;
		9'b100100110: nxtDrawState = 9'b101100110 ;
		9'b101100110: nxtDrawState = 9'b001100111 ;
		//100111 100111
		9'b001100111: nxtDrawState = 9'b010100111 ;
		9'b010100111: nxtDrawState = 9'b011100111 ;
		9'b011100111: nxtDrawState = 9'b100100111 ;
		9'b100100111: nxtDrawState = 9'b101100111 ;
		9'b101100111: nxtDrawState = 9'b001101000 ;
		//101000
		9'b001101000: nxtDrawState = 9'b010101000;
		9'b010101000: nxtDrawState = 9'b011101000 ;
		9'b011101000: nxtDrawState = 9'b100101000;
		9'b100101000: nxtDrawState = 9'b101101000 ;
		9'b101101000: nxtDrawState = 9'b001101001 ;
		//101001 101001
		9'b001101001: nxtDrawState = 9'b010101001;
		9'b010101001: nxtDrawState = 9'b011101001 ;
		9'b011101001: nxtDrawState = 9'b100101001;
		9'b100101001: nxtDrawState = 9'b101101001 ;
		9'b101101001: nxtDrawState = 9'b001101010 ;
		//101010 101010
		9'b001101010: nxtDrawState = 9'b010101010;
		9'b010101010: nxtDrawState = 9'b011101010 ;
		9'b011101010: nxtDrawState = 9'b100101010 ;
		9'b100101010: nxtDrawState = 9'b101101010 ;
		9'b101101010: nxtDrawState = 9'b001101011 ;
		//101011 101011
		9'b001101011: nxtDrawState = 9'b010101011 ;
		9'b010101011: nxtDrawState = 9'b011101011 ;
		9'b011101011: nxtDrawState = 9'b100101011 ;
		9'b100101011: nxtDrawState = 9'b101101011 ;
		9'b101101011: nxtDrawState = 9'b001101100 ;
		//101100
		9'b001101100: nxtDrawState = 9'b010101100 ;
		9'b010101100: nxtDrawState = 9'b011101100 ;
		9'b011101100: nxtDrawState = 9'b100101100 ;
		9'b100101100: nxtDrawState = 9'b101101100 ;
		9'b101101100: nxtDrawState = 9'b001101101 ;
		
		//101101 
		9'b001101101: nxtDrawState = 9'b010101101;
		9'b010101101: nxtDrawState = 9'b011101101;
		9'b011101101: nxtDrawState = 9'b100101101;
		9'b100101101: nxtDrawState = 9'b101101101;
		9'b101101101: nxtDrawState = 9'b001101110;
		//101110 
		9'b001101110: nxtDrawState = 9'b010101110;
		9'b010101110: nxtDrawState = 9'b011101110;
		9'b011101110: nxtDrawState = 9'b100101110;
		9'b100101110: nxtDrawState = 9'b101101110;
		9'b101101110: nxtDrawState = 9'b001101111;
		//101111 
		9'b001101111: nxtDrawState = 9'b010101111;
		9'b010101111: nxtDrawState = 9'b011101111;
		9'b011101111: nxtDrawState = 9'b100101111;
		9'b100101111: nxtDrawState = 9'b101101111;
		9'b101101111: nxtDrawState = 9'b001110000;
		//110000 
		9'b001110000: nxtDrawState = 9'b010110000;
		9'b010110000: nxtDrawState = 9'b011110000;
		9'b011110000: nxtDrawState = 9'b100110000;
		9'b100110000: nxtDrawState = 9'b101110000;
		9'b101110000: nxtDrawState = 9'b001110001;
		//110001 
		9'b001110001: nxtDrawState = 9'b010110001;
		9'b010110001: nxtDrawState = 9'b011110001;
		9'b011110001: nxtDrawState = 9'b100110001;
		9'b100110001: nxtDrawState = 9'b101110001;
		9'b101110001: nxtDrawState = 9'b001110010;
		//110010 
		9'b001110010: nxtDrawState = 9'b010110010;
		9'b010110010: nxtDrawState = 9'b011110010;
		9'b011110010: nxtDrawState = 9'b100110010;
		9'b100110010: nxtDrawState = 9'b101110010;
		9'b101110010: nxtDrawState = 9'b001110011;
		//110011 
		9'b001110011: nxtDrawState = 9'b010110011;
		9'b010110011: nxtDrawState = 9'b011110011;
		9'b011110011: nxtDrawState = 9'b100110011;
		9'b100110011: nxtDrawState = 9'b101110011;
		9'b101110011: nxtDrawState = 9'b001110100;
		//110100 
		9'b001110100: nxtDrawState = 9'b010110100;
		9'b010110100: nxtDrawState = 9'b011110100;
		9'b011110100: nxtDrawState = 9'b100110100;
		9'b100110100: nxtDrawState = 9'b101110100;
		9'b101110100: nxtDrawState = 9'b001110101;
		//110101
		9'b001110101: nxtDrawState = 9'b010110101;
		9'b010110101: nxtDrawState = 9'b011110101;
		9'b011110101: nxtDrawState = 9'b100110101;
		9'b100110101: nxtDrawState = 9'b101110101;
		9'b101110101: nxtDrawState = 9'b111111111;

		9'b111111111:begin
			if (GO)
			begin
				nxtDrawState = 9'b111111111;
			end
			
			else
			begin
				nxtDrawState = 9'b000000000;
			end
			
		end
		default: nxtDrawState =  9'b000000000;

	endcase
	end

endmodule

module counterEnable (innerClk, Freq,Enable);

	input innerClk;
	input [27:0] Freq;
	reg [27:0] count;
	output Enable;
	
	always@(posedge innerClk)
		begin
		
			if (count >= Freq)
				count <= 27'd0;
			else
				count <= count + 1'b1;
		
		end
	assign Enable = (count==Freq)?1:0;

endmodule