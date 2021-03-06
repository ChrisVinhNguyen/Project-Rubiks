/*module findpiece(clock,cube,colorone,colortwo,positionone,positiontwo);
	input[161:0]cube;
	input clock;
	input[2:0]colorone,colortwo;
	wire[8:0]presentstate,nextstate;
	output reg[6:0]positionone,positiontwo;
	
endmodule
	
	
module datapath(cube,color,position,enable,found,positionfound);
	input[161:0]cube;
	input[2:0]color;
	input[6:0]position;
	input enable;
	output found;
	output [6:0]positionfound;

//always@(*)
if(enable)
begin
   begin
	if(cube[position:position+2'b10]==color)
	begin
		found<=1'b1;
		positionfound<=position;
	end			
	else
		found<=1'b0;
   end
end	
endmodule
	
module controlpath(presentstate,nextstate,clock,start,positionone,enableone,enabletwo);
	input [8:0]presentstate,nextstate;
	input clock,start;
	output [6:0]positionone;
	

always @(posedge clock)
begin
	if(!start)
		presentstate<=RESET_S;
	else
		presentstate<=nextstate;
end

always @(*)
begin
	case(resentstate)
	RESET_S:begin
		positionone=7'b0000000;
		enableone=0;
		enabletwo=0;
		end
	S1:begin
		positionone=7'00000011;
		enableone=1;
		enabletwo=0;
		end
	T1:begin
		positionone=7'b;
		enableone=0;
		enabletwo=1;
		end
	S2:begin
		positionone=7';
		enableone=1;
		enabletwo=0;
		end
	T2:begin
		positionone=7'b;
		enableone=0;
		enabletwo=1;
		end
	S3:begin
		positionone=7';
		enableone=1;
		enabletwo=0;
		end
	T3:begin
		positionone=7'b;
		enableone=0;
		enabletwo=1;
		end
endmodule	
	
	
	
module statetable(presentstate,nextstate,start,found,foundt);

parameter RESET_S = 7'b0000000, S1 = 7'b0000001, S2 = 7'b0010, S3=7'b0000011,S4=7'b0000100,S5=7'b0000101,S6=7'b0000111,S7=7'b0001000,S8=7'b0001001,S9=7'b0001010,S10=7'b0001011;
parameter S11 = 7'b0001100, S12 = 7'b0001101, S13=7'b0001111,S14=7'b0010000,S15=7'b0010001,S16=7'b0010010,S17=7'b0010011,S18=7'b0010100,S19=7'b1111111,S20=7'b1111110;
parameter S21 = 7'b0010101, S22 = 7'b0010110, S23=7'b0010111,S24=7'b0011000,S25=7'b0011001,S26=7'b0011010,S27=7'b0011011,S28=7'b0011100,S29=7'b0011101,S30=7'b0011110;
parameter S31 = 7'b0011111, S32 = 7'b0100000, S33=7'b0100001,S34=7'b0100010,S35=7'b0100011,S36=7'b0100100,S37=7'b0100101,S38=7'b0100110,S39=7'b0100111,S40=7'b0101000;
parameter S41 = 7'b0101001, S42 = 7'b0101010, S43=7'b0101011,S44=7'b0101100,S45=7'b0101101,S46=7'b0101110,S47=7'b0101111,S48=7'b0110000,S49=7'b0110001,S50=7'b0110010;
parameter S51 = 7'b0110011, S52 = 7'b0110100, S53=7'b0110101,S54=7'b0110110,S55=7'b0110111,S56=7'b0111000,S57=7'b0111001,S58=7'b0111010,S59=7'b0111011,S60=7'b0111100;
parameter S61 = 7'b0111101, S62 = 7'b0111110, S63=7'b0111111,S64=7'b1000000,S65=7'b1000001,S66=7'b1000010,S67=7'b1000011,S68=7'b1000100,S69=7'b1000101,S70=7'b1000110;
parameter S71 = 7'b1000111, S72 = 7'b1001000, S73=7'b1001001,S74=7'b1001010,S75=7'b1001011,S76=7'b1001100,S77=7'b1001101,S78=7'b1001110,S79=7'b1001111,S80=7'b1010000;
parameter S81 = 7'b1010001, S82 = 7'b1010010, S83=7'b1010011,S84=7'b1010100,S85=7'b1010101,S86=7'b1010110,S87=7'b1010111,S88=7'b1011000,S89=7'b1011001,S90=7'b1011010;
parameter S91 = 7'b1011011, S92 = 7'b1011100, S93=7'b1011101,S94=7'b1011110,S95=7'b1011111,S96=7'b1100000,S97=7'b1100001,S98=7'b1100010,S99=7'b1100011,S100=7'b1100100;
parameter S101 = 7'b1100101, S102 = 7'b1100110, S103=7'b1100111,S104=7'b1101000,S105=7'b1101001,S106=7'b1101010,S107=7'b1101011,S108=7'b1101100;
parameter T1=7'b1101101, T2=7'b1101110, T3 = 7'b1101111, T4 = 7'b1110000,T5=7'b1110001, T6=7'b1110010, T7=7'b1110011, T8=7'b1110100,T9=7'b1110101,T10=7'b1110110; 
parameter T11=7'b1110111, T12=7'b1111000, T13 = 7'b1111001, T14 = 7'b1111010,T15=7'b1111011, T16=7'b1111100, T17=7'b1111101, T18=8'b10000000,T19=8'b10000001,T20=8'b10000010; 
parameter T21=8'b10000011, T22=8'b10000100, T23 = 8'b10000101, T24 = 8'b10000110,T25=8'b10000111, T26=8'b10001000, T27=8'b10001001, T28=8'b10001010,T29=8'b10001011,T30=8'b10001100;
parameter T31=8'b10001101, T32=8'b10001110, T33 = 8'b10001111, T34 = 8'b10010000,T35=8'b10010001, T36=8'b10010010, T37=8'b10010011, T38=8'b10010100,T39=8'b10010101,T40=8'b10010110;
parameter T41=8'b10010111, T42=8'b10011000, T43 = 8'b10011001, T44 = 8'b10011010,T45=8'b10011011, T46=8'b10011100, T47=8'b10011101, T48=8'b10011110,T49=8'b10011111,T50=8'b10100000;
parameter T51=8'b10100001, T52=8'b10100010, T53 = 8'b10100011, T54 = 8'b10100100,ERROR=8'b10100101;
	
	always@(*)
	begin
		case(presentstate)
		RESET_S:begin
				if(!start) nextstate=RESET_S;
				else nextstate = S1;
				end
		S1:begin
			if(found) nextstate=T1;
			else nextstate=S2;
			end
		S2:begin
			if(found) nextstate=T2;
			else nextstate=S3;
			end
		S3:begin
			if(found) nextstate=T3;
			else nextstate=S4;
			end
		S4:begin
			if(found) nextstate=T4;
			else nextstate=S5;
			end
		S5:begin
			if(found) nextstate=T5;
			else nextstate=S6;
			end	
		S6:begin
			if(found) nextstate=T6;
			else nextstate=S7;
			end	
		S7:begin
			if(found) nextstate=T7;
			else nextstate=S8;
			end
		S8:begin
			if(found) nextstate=T8;
			else nextstate=S9;
			end	
		endcase
		S9:begin
			if(found) nextstate=T9;
			else nextstate=S10;
			end
		S10:begin
			if(found) nextstate=T10;
			else nextstate=S11;
			end
		S11:begin
			if(found) nextstate=T11;
			else nextstate=S12;
			end
		S13:begin
			if(found) nextstate=T13;
			else nextstate=S14;
			end
		S14:begin
			if(found) nextstate=T14;
			else nextstate=S15;
			end
		S15:begin
			if(found) nextstate=T15;
			else nextstate=S16;
			end
		S16:begin
			if(found) nextstate=T16;
			else nextstate=S17;
			end
		S17:begin
			if(found) nextstate=T17;
			else nextstate=S18;
			end
		S18:begin
			if(found) nextstate=T18;
			else nextstate=S19;
			end
		S19:begin
			if(found) nextstate=T19;
			else nextstate=S20;
			end
		S20:begin
			if(found) nextstate=T20;
			else nextstate=S21;
			end
		S21:begin
			if(found) nextstate=T21;
			else nextstate=S22;
			end
		S22:begin
			if(found) nextstate=T22;
			else nextstate=S23;
			end
		S23:begin
			if(found) nextstate=T23;
			else nextstate=S24;
			end
		S24:begin
			if(found) nextstate=T24;
			else nextstate=ERROR;
			end
		T1:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S2;
			end
		T2:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S3;
			end
		T3:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S4;
			end
		T4:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S5;
			end
		T5:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S6;
			end
		T6:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S7;
			end
		T7:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S8;
			end
		T8:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S9;
			end
		T9:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S10;
			end
		T10:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S11;
			end
		T11:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S12;
			end
		T12:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S13;
			end
		T13:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S14;
			end
		T14:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S15;
			end
		T15:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S16;
			end
		T16:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S17;
			end
		T17:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S18;
			end
		T18:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S19;
			end
		T19:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S20;
			end
		T20:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S21;
			end
		T21:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S22;
			end
		T22:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S23;
			end
		T23:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=S24;
			end
		T24:begin
			if(foundt) nextstate=RESET_S;
			else nextstate=ERROR;
			end
		
	end	
endmodule*/