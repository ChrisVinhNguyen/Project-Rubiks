module cubescramble(cube,cubeout,clock,reset,enable);
	input [161:0]cube;
	output[161:0]cubeout;
	input clock,reset,enable;
	wire[26:0] count;
	wire slowclock;
	wire domove;
	wire [4:0] move;
	wire[3:0]pstate,nstate;

	fibonacci_lfsr_5bit randommove(clock,reset,move);
	counter5 count123(reset,clock,domove,count);
	counterEnable ce125(clock,27'd25000000,slowclock);
	controller random(cube,cubeout,domove,move[3:0]);
	fsmc rfsmc(pstate,nstate,slowclock,enable,domove);
	fsmt rfsmt(pstate,nstate,count,enable);
endmodule


module fsmc(PresentState,NextState,clock,start,enable);

output reg enable;
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
		end
	S1:begin
		enable=1;
		end
	S2:begin
		enable=0;
		end
	default:begin
		enable=0;
		end
	endcase
end
endmodule

module fibonacci_lfsr_5bit(
  input clk,
  input rst_n,

  output reg [5:0] data
);

reg [5:0] data_next;

always @* begin
  data_next[4] = data[4]^data[1];
  data_next[3] = data[3]^data[0];
  data_next[2] = data[2]^data_next[4];
  data_next[1] = data[1]^data_next[3];
  data_next[0] = data[0]^data_next[2];
end

always @(posedge clk or negedge rst_n)
  if(!rst_n)
    data <= 5'h1f;
  else
    data <= data_next;

endmodule

module fsmt(PresentState,NextState,counter,enable);
input [3:0]PresentState;
input [4:0]counter;
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
				if(counter<5'b11111|counter==5'b11111) NextState = S1;
				else NextState = S2;
			end
	  S2:
	 		if(counter<5'b11111|counter==5'b11111) NextState = S1;
            else NextState = RESET_S;
		
		default:    
 		NextState = RESET_S;
        endcase
    end
endmodule

module counter5(clear,clock,enable,q);
	input clear,clock,enable;
	output reg [4:0] q; // declare q
	always @(posedge clock) // triggered every time clock rises
		begin
			if (clear == 1'b0) // when Clear b is 0
				q <= 0; // q is set to 0
			else if (q == 5'b11111) // when q is the maximum value for the counter
				q <= 0; // q reset to 0
			else if (enable == 1'b1) // increment q only when Enable is 1
				q <= q + 1; // increment q
		end
endmodule


