// data_mem.v - data memory

module data_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64) (
    input       clk, wr_en,
    input [2:0] funct3,
    input       [ADDR_WIDTH-1:0] wr_addr, wr_data,
    output   reg   [DATA_WIDTH-1:0] rd_data_mem
);
// array of 64 32-bit words or data
reg  [DATA_WIDTH-1:0]                  data_ram [0:MEM_SIZE-1];
wire [ADDR_WIDTH-1:0] word_addr = wr_addr[DATA_WIDTH-1:2] % 64;
// combinational read logic
// word-aligned memory access
// assign rd_data_mem = data_ram[wr_addr[DATA_WIDTH-1:2] % 64];
// synchronous write logic
always @(posedge clk) begin
    if (wr_en) begin
    	case(funct3)
    		3'b000: begin // store byte
    			case (wr_addr[1:0])
    				2'b00: data_ram[word_addr][ 7: 0] = wr_data[7:0];
    				2'b01: data_ram[word_addr][15: 8] = wr_data[7:0];
    				2'b10: data_ram[word_addr][23:16] = wr_data[7:0];
    				2'b11: data_ram[word_addr][31:24] = wr_data[7:0];
    			endcase
    		end
    		3'b001: begin // store half
    			case(wr_addr[1])
    				1'b0: data_ram[word_addr][15: 0] = wr_data[15:0];
    				1'b1: data_ram[word_addr][31:16] = wr_data[31:16];
    			endcase
    		end
    		3'b010: data_ram[word_addr] <= wr_data; // store word
    	endcase
    end
end

always@(*) begin
	rd_data_mem = 32'b0;
	case(funct3)
		3'b000: begin  // load byte
			case(wr_addr[1:0])
				2'b00: rd_data_mem = {{24{data_ram[word_addr][ 7]}},data_ram[word_addr][ 7: 0]};
				2'b01: rd_data_mem = {{24{data_ram[word_addr][15]}},data_ram[word_addr][15:8]};
				2'b10: rd_data_mem = {{24{data_ram[word_addr][23]}},data_ram[word_addr][23:16]};
				2'b11: rd_data_mem = {{24{data_ram[word_addr][31]}},data_ram[word_addr][31:24]};
			endcase
		end
		
		3'b001: begin // load half
			if (wr_addr[1] == 1'b0)
				rd_data_mem = {{16{data_ram[word_addr][15]}}, data_ram[word_addr][15:0]};
			else
				rd_data_mem = {{16{data_ram[word_addr][31]}}, data_ram[word_addr][31:16]};
		end
			
		3'b100: begin //load unsigned
			case(wr_addr[1:0])
				2'b00: rd_data_mem = {24'b0,data_ram[word_addr][ 7: 0]};
				2'b01: rd_data_mem = {24'b0,data_ram[word_addr][15: 8]};
				2'b10: rd_data_mem = {24'b0,data_ram[word_addr][23:16]};
				2'b11: rd_data_mem = {24'b0,data_ram[word_addr][31:24]};
			endcase
		end
		3'b101: begin  // LH: Load Halfword (unsigned)
    			case (wr_addr[1])
       			1'b0: rd_data_mem = {16'b0,data_ram[word_addr][15: 0]};
        			1'b1: rd_data_mem = {16'b0,data_ram[word_addr][31:16]};
        			default: rd_data_mem = 32'b0;
    			endcase
		end
		3'b010: rd_data_mem = data_ram[word_addr]; //load word
	endcase
end
endmodule 