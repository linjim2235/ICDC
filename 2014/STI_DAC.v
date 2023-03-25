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
	
	/////////////////////////////////////////sdssssssssssssssss
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
		next_state = 
	default: 
		next_state = INIT;
endcase
end

always @(posedge clk) begin
	
end


endmodule
