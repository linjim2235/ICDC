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
parameter CAL_CYCLE2_LOCATION = 2;
parameter CAL_COVER_RATE = 3;
parameter CAL_UP = 4;
parameter CAL_DOWN = 4;
parameter CAL_LEFT = 4;
parameter CAL_RIGHT = 4;

reg [3:0] x1;
reg [3:0] y1;
reg [3:0] x2;
reg [3:0] y2;


endmodule


