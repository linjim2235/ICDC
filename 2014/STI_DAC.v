module STI_DAC(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
	       so_data, so_valid,
	       pixel_finish, pixel_dataout, pixel_addr,
	       pixel_wr);

input		clk, reset;
input		load, pi_msb, pi_low, pi_end; 
input	[15:0]	pi_data;
input	[1:0]	pi_length;
input		pi_fill;
output	reg 	so_data, so_valid;

output reg  pixel_finish, pixel_wr;
output reg [7:0] pixel_addr;
output reg [7:0] pixel_dataout;
reg [31:0] buffer;
reg [2:0] current_state;
reg [2:0] next_state;
reg [4:0] ptr;
reg [4:0] counter;
reg [31:0] pixel_buffer;
reg [2:0] counter_p;
reg [4:0] ptr_p;
parameter INIT = 0;
parameter INPUT_DATA = 1;
parameter DEAL_WITH_DATA = 2;
parameter OUTPUT_SO = 3;
parameter OUTPUT_PIXEL = 4;
parameter ADD_ZERO = 5;
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
		next_state = (counter == 0)? OUTPUT_PIXEL : OUTPUT_SO;
	OUTPUT_PIXEL:
	begin
		if(pi_end)
			next_state = ADD_ZERO;
		else
			next_state = (counter_p == 1)?INIT:OUTPUT_PIXEL;
	end
	ADD_ZERO:
		next_state = (pixel_addr == 8'd255)?FINISH:ADD_ZERO;
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
			buffer <= (pi_fill) ? {pi_data,16'b0} : {8'b0, pi_data, 8'b0};
		2'b11:
			buffer <= (pi_fill)?{pi_data, 16'b0}:{16'b0, pi_data};
		default: 
			buffer <= {pi_data,16'b0};
	endcase
end
else if(current_state == DEAL_WITH_DATA)
begin
	if(pi_length == 2'b00)
	begin
		if(!pi_low)
			buffer[31:24]= buffer[23:16];
	end
end
end

// counter and counter_p
always @(posedge clk) begin
	if(reset)
		counter <= 0;
	else if(current_state == INPUT_DATA)
	begin
	case(pi_length)
		2'b00:
		begin
			counter <= 8;
			counter_p <= 1;
		end
		2'b01:
		begin
			counter <= 16;
			counter_p <= 2;
		end
		2'b10:
		begin
			counter <= 24;
			counter_p <= 3;
		end
		2'b11:
		begin
			counter <= 32;
			counter_p <= 4;
		end
    endcase
	end
	else if(current_state == OUTPUT_SO)
		counter <= counter -1;
	else if(current_state == OUTPUT_PIXEL)
		counter_p <= counter_p -1;
end

// ptr 
always @(posedge clk) begin
if(reset)
	ptr <= 0;
else if(current_state == INPUT_DATA)
begin
	if(pi_msb)
		ptr <= 6'd31;
	else 
	begin
		case(pi_length)
		2'b00:
			ptr <= 24;
		2'b01:
			ptr <= 16;
		2'b10:
			ptr <= 8;
		2'b11:
			ptr <= 0;
		default:
			ptr <= 0;
		endcase
	end
end
else if(next_state == OUTPUT_SO)
	ptr <= (pi_msb) ? (ptr -1): (ptr +1);
end
// output_so
always @(posedge clk) begin
if(reset)
begin
	so_data <= 0;
	so_valid <= 0;
end
else if(next_state == OUTPUT_SO)
begin
	so_valid <= 1;
	so_data <= buffer[ptr];
	pixel_buffer[ptr_p] <= buffer[ptr];
end
else
begin
	so_valid <= 0;
	so_data <= 0;
end
end

// ptr_p
always @(posedge clk)
begin
    if(reset)
        ptr_p <= 31;
    else if(current_state == INPUT_DATA)
        ptr_p <= 31;
    else if(next_state == OUTPUT_SO)
        ptr_p <= ptr_p -1;
end

// output_pixel
always @(posedge clk) begin
if(reset)
begin
	pixel_addr <= 0;
	pixel_finish <= 0;
	pixel_wr <= 0;
	pixel_dataout <= 0;
end
else if(next_state == OUTPUT_PIXEL)
begin
	pixel_wr <= 1;
	pixel_dataout <= pixel_buffer[31:24];
	case (counter_p)
		3'd4:
			pixel_buffer[31:24] <= pixel_buffer[23:16];
		3'd3:
			pixel_buffer[31:24] <= pixel_buffer[15:8];
		3'd2:
			pixel_buffer[31:24] <= pixel_buffer[7:0];
	endcase
end
else if(next_state == ADD_ZERO)
begin
	pixel_wr <= 1;
	pixel_dataout <= 0;
end
else 
	pixel_wr <= 0;

if(current_state == OUTPUT_PIXEL || current_state == ADD_ZERO)
	pixel_addr <= pixel_addr + 1;

end

endmodule
