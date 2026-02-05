// MazeSolver Bot: Task 2B - UART Transmitter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to generate UART Tx data packet to transmit the messages based on the input data.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Transmitter

Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit

Output: tx      - UART Transmission Line
        tx_done - message transmitted flag


        Baudrate : 115200 bps
*/

// module declaration
module uart_tx(
    input clk_3125,
    input parity_type,tx_start,
    input [7:0] data,
    output reg tx, tx_done
);
parameter division = (3125000/115200);
reg [$clog2(division)-1:0] count = 0;
reg [2:0] state = 0;
reg baud_tick = 0;
reg [2:0] bit_index = 0;
reg tx_temp2 = 1'b0;
reg temp_count = 0;
reg complete_flag = 0;

initial begin
    tx = 1'b1;
    tx_done = 1'b0;
end
always@(posedge clk_3125) begin
	tx_temp2 <= tx_start;
	if(!tx_temp2) begin
		if(baud_tick) begin
            case(state)
                3'b000: begin
                    if(bit_index < 3'd7) begin
                        bit_index <= bit_index + 1'b1;
                        tx <= data[7-bit_index];
                        state <= 3'b000;
                    end
                    else if(bit_index == 3'd7) begin
                        bit_index <= 3'b000;
                        state <= 3'b001;
                        tx <= data[0];
                    end
                end
				3'b001: begin
					tx <= (parity_type == 1'b0) ? (^data) : ~(^data); // even or odd parity bit
					state <= 3'b010;
				end
				3'b010: begin
					tx <= 1'b1;
					temp_count <= 1'b1;
					state <= 3'b011;
				end
				3'b011: begin
					state <= 3'b000;
					temp_count <= 1'b0;
					tx_done <= 1'b0;
					complete_flag <= 1'b1;
				end
            endcase
        end
	end
	if(tx_temp2 || tx_start) begin
		tx <= 1'b0;
		state <= 3'b000;
		bit_index <= 3'b000;
		count <= 0;
		tx_done <= 1'b0;
	end
	if(complete_flag && (count == 5'd1)) begin
		count <= 0;
		complete_flag <= 1'b0;
		bit_index <= 3'b000;
	end
	else begin
		if(count < (division - 1)) begin
			count <= count + 1;
			baud_tick <= 1'b0;
		end
    	else begin	
			count <= 0;
			baud_tick <= 1'b1;
		end
		if(count == 5'd26) begin
			tx_done <= temp_count;
		end
	end	
end
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////
endmodule