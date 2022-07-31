module PWM(
	input wire CLK,
	input wire RST,
	input wire[15:0] Span_in,
	input wire[15:0] CntU_in,
	output reg Down,	//0:up count,1:down count
	output reg U_Hi,
	output reg U_Lo
	);

	parameter Dead = 16'h00f0;

	reg[15:0] CarH;
	reg[15:0] CarL;
	reg[15:0] Span;		//(Dead+Span) must be < 16'hfffd
	reg[15:0] Comp;		//(Down)?16'h0001:Span;
	reg[15:0] CntU;
	reg Edge;			//(CarTop||CarBtm)

	always@( posedge RST, posedge CLK ) begin
		if( RST ) begin
			CarH <= Dead;
			CarL <= 16'h0000;
			Span <= 16'hff00;
			Comp <= 16'hffff;
			CntU <= 16'h0000;
			Down <= 1'b0;
			U_Hi <= 1'b0;
			U_Lo <= 1'b0;
			Edge <= 1'b0;
		end
		else begin	//CLK
			
			Edge <= ( CarL == Comp )?1'b1:1'b0;	//(CarTop||CarBtm)
			
			if( Edge ) begin
				CntU <= CntU_in;
				Span <= Span_in;
				Down <= !Down;
			end
			
			//Compare
			if( CarH == CntU ) U_Hi <= !Down;
			if( CarL == CntU ) U_Lo <=  Down;
			
			//Count
			CarH <= CarH + {{15{Down}},1'b1};
			CarL <= CarL + {{15{Down}},1'b1};

			Comp <= (Down)?16'h0002:Span;
			
		end
	end

endmodule