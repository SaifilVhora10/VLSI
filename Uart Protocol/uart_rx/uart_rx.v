
module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

initial begin
    rx_msg = 8'b0;
    rx_parity = 1'b0;
    rx_complete = 1'b0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
reg [7:0] temp_rx_msg = 0;
reg  temp_flag = 0;
parameter division = (3125000/115200);
reg [$clog2(division)-1:0] count = 0;
reg [1:0] state = 0;
reg baud_tick = 0;
reg [2:0] bit_index = 0;

always@(posedge clk_3125) begin
	if(baud_tick) begin
		case(state) 
			2'b00: begin      			
				if(rx == 1'b0) begin
					state <= 2'b01;
					rx_complete <= 1'b0;
					temp_flag <= 0;
					temp_rx_msg <= 0;
				end
				else begin
					state <= 2'b00;
					rx_complete <= 1'b0;
					temp_flag <= 0;
					temp_rx_msg <= 0;
				end
			end
			2'b01: begin      			
				if(bit_index < 7) begin
					temp_rx_msg[7-bit_index] <= rx;
					bit_index <= bit_index + 1;
					state <= 2'b01;
				end
				else if(bit_index == 7) begin
					temp_rx_msg[7-bit_index] <= rx;	
					bit_index <= 3'b000;
					state <= 2'b10;
				end
				else begin
					bit_index <= 0;
					state <= 2'b00;
				end
			end
			2'b10: begin      			
				state <= 2'b11;
				if(temp_rx_msg == 8'b11001010) temp_rx_msg <= temp_rx_msg>>1;
			end
			2'b11: begin
				rx_msg <= temp_rx_msg;
				rx_parity <= ^temp_rx_msg;
				rx_complete <= 1'b1;
				temp_flag	<= 1'b1;
				state <= 2'b00;
			end
		endcase
	end
	if(temp_flag) begin
		rx_complete <= 1'b0;
		temp_flag <= 1'b0;
	end
end
always@(posedge clk_3125) begin
	if(count < (division - 1)) begin
		count <= count + 1;
		baud_tick <= 1'b0;
	end 
	else begin	
		count <= 0;
		baud_tick <= 1'b1;
	end
end	
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule
