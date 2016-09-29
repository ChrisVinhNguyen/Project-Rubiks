
module ProjectRubiks
		(CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
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
	assign  freq = 28'd50000;
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
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
   	register x0(~resetn,xstart,autoPosition[6:0],~changeY,CLOCK_50);
    // Instanciate datapath
	datapath d0(xstart,autoPosition[6:0],enable, ~drawX,resetn,count,CLOCK_50,x,y);
    // Instanciate FSM control
	statetable s0(PresentState,NextState,count,~drawX);
	controlpath c0(PresentState,NextState,CLOCK_50,~drawX,enable,writeEn);
	 

	 //NEW RUBRICKS SHIT
	 //module drawCubeControl ( colour, nxtDrawState, position, changeY ,drawX,clock,drawState, inCube, GO )
	 drawCubeControl dcc(colour, nxtDrawState, autoPosition[6:0], changeY, drawX, laggedClock,presDrawState,testCUBE, ~KEY[1] );
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
				position[6:0] = 7'b0111000;
				
			end

			9'b010000001:
			begin
				colour[2:0] = inCube[5:3];
				position[6:0] = 7'b0111000;
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
				position[6:0] = 7'b0001000 ;
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
				position[6:0] = 7'b0111100;
				
			end

			9'b010000010:
			begin
				colour[2:0] = inCube[8:6];
				position[6:0] = 7'b0111100;
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
				position[6:0] = 7'b0001100 ;
				drawY = 1;
				changeX = 1;
			end

			9'b100000011:
			begin
				colour[2:0] = inCube[11:9];
				position[6:0] = 7'b0001100 ;
				drawY = 1;
				changeX = 1;
			end

			9'b101000011:
			begin
				colour[2:0] = inCube[11:9];
				position[6:0] = 7'b0001100 ;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #04 BIN000100
			9'b001000100:
			begin
				drawY =1;
				changeX = 1;
				colour[2:0] = inCube[11:9];
				position[6:0] = 7'b0111000;
				
			end

			9'b010000100:
			begin
				colour[2:0] = inCube[14:12];
				position[6:0] = 7'b0111000;
				drawY =1;
				changeX = 0;
			end


			9'b011000100:
			begin
				colour[2:0] = inCube[14:12];
				position[6:0] = 7'b0001100;
				drawY =1;
				changeX = 1;
			end

			9'b100000100:
			begin
				colour[2:0] = inCube[14:12];
				position[6:0] = 7'b0001100;
				drawY =1;
				changeX = 1;
			end

			9'b101000100:
			begin
				colour[2:0] = inCube[14:12];
				position[6:0] = 7'b0001100;
				drawY =0;
				changeX = 1;
			end



			// PIECE #05 BIN000101
			9'b001000101:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[14:12];
				position[6:0] = 7'b0111100;
				
			end

			9'b010000101:
			begin
				colour[2:0] = inCube[17:15];
				position[6:0] = 7'b0111100;
				drawY = 1;
				changeX = 0;
			end


			9'b011000101:
			begin
				colour[2:0] = inCube[17:15];
				position[6:0] = 7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b100000101:
			begin
				colour[2:0] = inCube[17:15];
				position[6:0] = 7'b0001100;
				drawY = 1;
				changeX = 1;
			end

			9'b101000101:
			begin
				colour[2:0] = inCube[17:15];
				position[6:0] = 7'b0001100;
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
				position[6:0] = 7'b0010000;
				drawY = 1;
				changeX = 1;
			end

			9'b100000110:
			begin
				colour[2:0] = inCube[20:18];
				position[6:0] = 7'b0010000;
				drawY = 1;
				changeX = 1;
			end

			9'b101000110:
			begin
				colour[2:0] = inCube[20:18];
				position[6:0] = 7'b0010000;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #07 BIN000111
			9'b001000111:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[20:18];
				position[6:0] = 7'b0111000;
				
			end

			9'b010000111:
			begin
				colour[2:0] = inCube[23:21];
				position[6:0] = 7'b0111000;
				drawY = 1;
				changeX = 0;
			end


			9'b011000111:
			begin
				colour[2:0] = inCube[23:21];
				position[6:0] = 7'b0010000;
				drawY = 1;
				changeX = 1;
			end

			9'b100000111:
			begin
				colour[2:0] = inCube[23:21];
				position[6:0] = 7'b0010000;
				drawY = 1;
				changeX = 1;
			end

			9'b101000111:
			begin
				colour[2:0] = inCube[23:21];
				position[6:0] = 7'b0010000;
				drawY = 0;
				changeX = 1;
			end



			// PIECE #08 BIN001000
			9'b001001000:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[23:21];
				position[6:0] = 7'b0111100;
				
			end

			9'b010001000:
			begin
				colour[2:0] = inCube[26:24];
				position[6:0] = 7'b0111100;
				drawY = 1;
				changeX = 0;
			end


			9'b011001000:
			begin
				colour[2:0] = inCube[26:24];
				position[6:0] = 7'b0010000;
				drawY = 1;
				changeX = 1;
			end

			9'b100001000:
			begin
				colour[2:0] = inCube[26:24];
				position[6:0] = 7'b0010000;
				drawY = 1;
				changeX = 1;
			end

			9'b101001000:
			begin
				drawY = 0;
				changeX = 1;
				colour[2:0] = inCube[26:24];
				position[6:0] = 7'b0010000;
				
			end
			
			9'b111111111:
			begin
				drawY = 1;
				changeX = 1;
				colour[2:0] = inCube[53:51];
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



			//FACE FRONT FACE FRONT FACE FRONT FACE FRONT FACE FRONT FACE FRONT



			//FACE RIGHT FACE RIGHT FACE RIGHT FACE RIGHT FACE RIGHT FACE RIGHT 



			//FACE BOTTOM FACE BOTTOM FACE BOTTOM FACE BOTTOM FACE BOTTOM FACE BOTTOM



			//FACE BACK FACE BACK FACE BACK FACE BACK FACE BACK FACE BACK FACE BACK 


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
		//SET THIS TO be 9'b001001001 to allow continoued drawing
		9'b101001000: nxtDrawState = 9'b111111111 ;
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