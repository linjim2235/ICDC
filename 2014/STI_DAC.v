module STI_DAC(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
	       so_data, so_valid,
	       pixel_finish, pixel_dataout, pixel_addr,
	       pixel_wr);

input		clk, reset;
input		load, pi_msb, pi_low, pi_end; 
input	[15:0]	pi_data;
input	[1:0]	pi_length;
input		pi_fill;
output		so_data, so_valid;

output  pixel_finish, pixel_wr;
output [7:0] pixel_addr;
output [7:0] pixel_dataout;
reg [31:0] buffer;
reg [2:0] current_state;
reg [2:0] next_state;
parameter INIT = 0;
parameter INPUT_DATA = 1;
parameter DEAL_WITH_DATA = 2;
parameter OUTPUT_SO = 3;
parameter OUTPUT_PIXEL = 4;
parameter FINISH = 5;

//==============================================================================
always @(posedge clk) begin
if(reset)
	current_state <= INIT;
else

	current_state <= next_state;
end

always @(*) begin
case (current_state)
	INIT:
		next_state =  (load)? INPUT_DATA : INIT;
	INPUT_DATA:
		next_state = DEAL_WITH_DATA;
	DEAL_WITH_DATA:
		next_state = OUTPUT_SO;
	OUTPUT_SO:
		next_state = OUTPUT_PIXEL;
	OUTPUT_PIXEL:
		next_state = FINISH;
	FINISH:
		next_state = FINISH;
	default: 
		next_state = INIT;
endcase
end

// buffer
always @(posedge clk) begin
if(reset)
	buffer <= 32'b0;
else if(current_state == INPUT_DATA)
begin
	case (pi_length)
		2'b10:
			buffer <= (pi_fill)?{pi_data, 16'b0}:{16'b0, pi_data};
		2'b11:
			buffer <= (pi_fill)?{pi_data, 16'b0}:{16'b0, pi_data};
		default: 
			buffer <= {16'b0, pi_data};
	endcase
end
end


endmodule
