module LASER (
input CLK,
input RST,
input [3:0] X,
input [3:0] Y,
output reg [3:0] C1X,
output reg [3:0] C1Y,
output reg [3:0] C2X,
output reg [3:0] C2Y,
output reg DONE);

reg current_state;
reg next_state;
parameter  INIT = 0;
parameter READ = 1;
parameter CAL_CIRCLE2_LOCATION = 2;
parameter CAL_COVER_RATE = 3;
parameter CAL_UP = 4;
parameter CAL_DOWN = 5;
parameter CAL_LEFT = 6;
parameter CAL_RIGHT = 7;

reg [5:0] max_cover;
reg [5:0] counter;
reg [3:0] bufferX [39:0];
reg [3:0] bufferY [39:0];
wire [4:0] add_1;
wire [4:0] add_2;
reg [3:0] temp_1;
reg [3:0] temp_2;
reg [3:0] temp_3;
reg [3:0] temp_4;
assign add_1 = (temp_1 + temp_2) >> 1;
assign add_2 = (temp_3 + temp_4) >> 1;
reg [5:0] counter;
integer i;

always @(posedge CLK or posedge RST) begin
    if(RST)
        current_state <= INIT;
    else 
        current_state <= next_state;
end

always @(*) begin
case (current_state)
    INIT:
        next_state =(RST)?INIT:READ;
    READ:
        next_state =  (counter == 6'd39)?CAL_CIRCLE2_LOCATION:READ;
    CAL_CIRCLE2_LOCATION:
        next_state = CAL_COVER_RATE;
    default: 
        next_state = INIT;
endcase
end
// buffer
always @(posedge CLK)
begin
    if(RST)
    begin
        for(i=0;i<40;i=i+1)
        begin
            bufferX[i] <= 4'b0;
            bufferY[i] <= 4'b0;
        end
        counter <= 0;
        temp_1 <= 0;
        temp_2 <= 0;
        temp_3 <= 0;
        temp_4 <= 0;
    end
    else if(next_state == READ)
    begin
        if(counter == 0)
        begin
            bufferX[counter] <= X;
            bufferY[counter] <= Y;
            temp_1 <= X;
            temp_3 <= Y;
        end
        else
        begin
            bufferX[counter] <= X;
            bufferY[counter] <= Y;
            temp_1 <= add_1;
            temp_3 <= add_2;
            temp_2 <= X;
            temp_4 <= Y;
        end
    end

end
// max_cover
always @(posedge CLK) begin
if(RST)
    max_cover <= 6'd0;
else if(current_state == CAL_COVER_RATE)
begin
end

end

// counter
always @(posedge CLK) begin
if(RST)
    counter <= 0;
else if(next_state == READ)
    counter <= counter + 1;
else if(current_state == CAL_CIRCLE2_LOCATION)
    counter <= 0;
else if(current_state == CAL_COVER_RATE)
    counter <= counter + 1;
end
// OUTPUT
always @(posedge CLK) begin
if(RST)
begin
    C1X <= 0;
    C1Y <= 0;
    C2X <= 0;
    C2Y <= 0;
    DONE <= 0;
end
else if(current_state == CAL_CIRCLE2_LOCATION)
begin
    C2X <= add_1;
    C2Y <= add_2;
end


end
endmodule


