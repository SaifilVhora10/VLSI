
module pwm_generator(
    input clk_3125KHz,
    input [3:0] duty_cycle,
    output reg clk_195KHz, pwm_signal
);

initial begin
    clk_195KHz = 0; pwm_signal = 1;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

initial begin
        clk_195KHz = 0;       // Initialize divided clock to 0
        pwm_signal = 1;       // Initialize PWM signal to 1
    end
    reg [3:0] count = 4'b0000; // 4-bit counter to generate PWM and divided clock
    // Always block triggered on the rising edge of input clock
    always @(posedge clk_3125KHz) begin
        // PWM generation logic:
        // If counter value is less than duty cycle, PWM is high
        if(count < duty_cycle) begin
            pwm_signal <= 1'b1;
        end 
        else begin
            pwm_signal <= 1'b0;
        end
        // Divided clock generation (~195 KHz):
        // Clock is high for count 0-7, low for count 8-15
        if(count < 4'd8) begin
            clk_195KHz <= 1'b1;
        end
        else begin
            clk_195KHz <= 1'b0;
        end
        count <= count + 1'b1;
    end 

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
