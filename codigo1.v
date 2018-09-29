module ff ( input data, input c, input r, output q);
reg q;
always @(posedge c or negedge r) 
begin
 if(r==1'b0)
  q <= 1'b0; 
 else 
  q <= data; 
end 
endmodule //End 

// FSM alto nível com Case
module statem(clk, reset, a, saida);

input clk, reset;
input [1:0] a;
output [2:0] saida;
reg [2:0] state;
parameter zero = 3'd0, um = 3'd1, dois = 3'd2, tres = 3'd3, quatro = 3'd4, cinco = 3'd5, seis = 3'd6, tres_ = 3'd7;

assign saida = (state == zero)? 3'd0:
		(state == um)? 3'd1:
		(state == dois)? 3'd2:
		(state == tres)? 3'd3:
		(state == quatro)? 3'd4:
		(state == cinco)? 3'd5:
		(state == seis)? 3'd6:3'd3;

always @(posedge clk or negedge reset)
	begin
		if (reset==0)
			state = zero;
		else
			case (state)
				zero: if ( a == 2'b01 ) state = dois;
					else if ( a == 2'b11 ) state = cinco;
					else state = um;
				um: if ( a == 2'b00 | a == 2'b01 ) state = dois;
					else state = tres;
				dois: if ( a == 2'b00 ) state = zero;
					else if ( a == 2'b01 ) state = quatro;
					else if ( a == 2'b10 ) state = tres_;
					else state = tres;
				tres: if ( a == 2'b11 ) state = cinco;
					else state = dois;
				quatro: if ( a == 2'b01 ) state = tres;
					else if ( a == 2'b11 ) state = cinco;
					else state = dois;
				cinco: if ( a == 2'b00 ) state = zero;
					else if ( a == 2'b11 ) state = seis;
					else state = tres;
				seis: if ( a == 2'b00 ) state = zero;
					else state = tres;
				tres_: if ( a == 2'b00 | a == 2'b10 ) state = um;
					else state = tres;

			endcase
	end
endmodule // End

// FSM com portas logicas
module statePorta(input clk, input res, input [1:0] a, output [2:0] s);

wire [2:0] e;
wire [2:0] p;

assign s = e;  // saida = estado atual

assign p[0]  =  e[2]&e[1]&e[0] | ~a[1]&a[0]&e[2] | a[0]&e[2]&~e[0] | a[1]&e[1]&~e[0] | a[1]&a[0]&~e[2] | 
				~a[0]&~e[2]&~e[1]&~e[0] | a[1]&~a[0]&~e[1]&e[0]; // 32 portas

assign p[1]  =  a[1]&~e[1]&e[0] | a[0]&e[2]&e[1] | ~a[0]&~e[2]&e[0] | ~a[1]&a[0]&e[0] | a[1]&e[1]&~e[0] | 
				~a[1]&a[0]&~e[1] | ~a[0]&e[2]&~e[1]&~e[0]; // 31 portas 

assign p[2] =   a[1]&a[0]&~e[1]&~e[0] | a[1]&a[0]&e[2]&~e[1] | ~a[1]&a[0]&~e[2]&e[1]&~e[0] | 
				a[1]&~a[0]&~e[2]&e[1]&~e[0] | a[1]&a[0]&~e[2]&e[1]&e[0]; // 32 portas
// Total de portas lógicas = 95

ff  e0(p[0],clk,res,e[0]);
ff  e1(p[1],clk,res,e[1]);
ff  e2(p[2],clk,res,e[2]);

endmodule // End

// FSM com memoria
module stateMem(input clk,input res, input [1:0] a, output [2:0] saida);

reg [5:0] StateMachine [0:31]; // 32 linhas e 6 bits de largura

initial
begin
	StateMachine[0] = 6'h08;  StateMachine[1] = 6'h11;
	StateMachine[2] = 6'h02;  StateMachine[3] = 6'h13;	
	StateMachine[4] = 6'h14;  StateMachine[5] = 6'h05;
	StateMachine[6] = 6'h06;  StateMachine[7] = 6'h0f;
	StateMachine[8] = 6'h10;  StateMachine[9] = 6'h11;
	StateMachine[10] = 6'h22;  StateMachine[11] = 6'h13;
	StateMachine[12] = 6'h1c;  StateMachine[13] = 6'h1d;
	StateMachine[14] = 6'h1e;  StateMachine[15] = 6'h1f;
	StateMachine[16] = 6'h08;  StateMachine[17] = 6'h19;
	StateMachine[18] = 6'h3a;  StateMachine[19] = 6'h13;	
	StateMachine[20] = 6'h14;  StateMachine[21] = 6'h1d;
	StateMachine[22] = 6'h1e;  StateMachine[23] = 6'h0f;
	StateMachine[24] = 6'h28;  StateMachine[25] = 6'h19;
	StateMachine[26] = 6'h1a;  StateMachine[27] = 6'h2b;
	StateMachine[28] = 6'h2c;  StateMachine[29] = 6'h35;
	StateMachine[30] = 6'h1e;  StateMachine[31] = 6'h1f;
end

wire [4:0] address;  // 32 linhas = 5 bits de endereco
wire [5:0] dout; // 6 bits de largura 3+3 = proximo estado + saida

assign address[0] = a[0];
assign address[1] = a[1];

assign dout = StateMachine[address];
assign saida = dout[2:0];

ff st0(dout[3],clk,res,address[2]);
ff st1(dout[4],clk,res,address[3]);
ff st2(dout[5],clk,res,address[4]);

endmodule // End

module main;
reg c,res;
reg [1:0] a;
wire [2:0] saida;
wire [2:0] saida1;
wire [2:0] saida2;

statem FSM(c,res,a,saida);
statePorta FSM1(c,res,a,saida1);
stateMem FSM2(c,res,a,saida2);


initial
    c = 1'b0;
  always
    c= #(1) ~c;

// visualizar formas de onda usar gtkwave out.vcd
initial  begin
     $dumpfile ("out.vcd"); 
     $dumpvars; 
   end 

// Matricula: 77463 = 1 00 10 11 10 10 01 01 11
//                A = 1, 0, 2, 3, 2, 2, 1, 1, 3

  initial 
    begin
     $monitor($time," c %b res %b a %b s %d smem %d sporta %d ",c,res,a,saida,saida2,saida1);
      #1 res=0; a=2'd0;
      #1 res=1;
      #8 a=2'd1;
      #8 a=2'd0;
      #8 a=2'd2;
      #8 a=2'd3;
      #8 a=2'd2;
      #8 a=2'd2;
      #8 a=2'd1;
      #8 a=2'd1;
      #8 a=2'd3;
      #4;
      $finish ;
    end
endmodule

