module spi_shift_reg(
input p_clk,p_reset,ss,lsbef,cpha,cpol,
input send_data,
           receive_data,
           miso_receive_s_clk_rising,
           miso_receive_s_clk_falling,
           mosi_send_s_clk_rising,
           mosi_send_s_clk_falling,
input [7:0]data_from_spidr,
input miso,

output mosi,
output wire [7:0]data_to_spidr
);

reg receive_buffer_reg;
reg send_buffer_reg; 

//it is the procedure to send the data from buffer to spidr based on receive signal which has been 
assign data_to_spidr=receive_data?buffer_reg:8'b0;

//it is the procedure to send h
always@(posedge p_clk or negedge p_reset)
begin
if(!p_reset)
begin
send_buffer_reg<=8'b0;
end
else
begin
if(send_data)
begin
send_buffer_reg<=data_from_spidr;
end
else
begin
send_buffer_reg<=send_buffer_reg;
end
end
end 


always@(posedge p_clk or negedge p_reset)
begin
if(!p_reset)begin
count2<=8'd0;
count3<=8'd7;
end
else 
if( ss)
begin
count2<=8'd0;
count3<=8'd7;
end
else
if(cpol^cphs)
begin

end
end


















endmodule
