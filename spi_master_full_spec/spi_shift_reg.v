`timescale 1ns/1ps
module spi_shift_reg(
input p_clk,p_reset,ss,lsbef,cpha,cpol,spc0,bidiroe,
input send_data,
        receive_data,
        miso_receive_s_clk_rising,
        miso_receive_s_clk_falling,
        mosi_send_s_clk_rising,
        mosi_send_s_clk_falling,
input [7:0]data_from_spidr,
input miso,

output reg mosi,
output wire [7:0]data_to_spidr
);

reg [7:0]receive_buffer_reg;
reg [7:0]send_buffer_reg; 
reg [2:0]count0;
reg [2:0]count1;
reg [2:0]count2;
reg [2:0]count3;

//it is the procedure to send the data from buffer to spidr based on receive signal which has been 
assign data_to_spidr=receive_data?receive_buffer_reg:8'b0;

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
end
end 


always@(posedge p_clk or negedge p_reset)begin
    if(!p_reset)begin
      count2<=8'd0;
      count3<=8'd7;
    end
    else begin 
        if(ss)
         begin
          count2<=8'd0;
          count3<=8'd7;
         end
        else if(!ss && !spc0)begin
            if(cpol!=cpha)
              begin
                if (lsbef) begin
                    
                    if (miso_receive_s_clk_falling) begin
                        receive_buffer_reg[count2] <= miso;
                        if(count2 == 3'd7)
                        count2 <= 3'd0;
                        else
                        count2 <= count2 + 3'b001;
                    end
                end
                else begin
                    if (miso_receive_s_clk_falling) begin
                        receive_buffer_reg[count3] <= miso;
                        if(count3 == 3'd0)
                        count3 <= 3'd7;
                        else
                        count3 <= count3 - 3'b001;
                    end
                end
            end
            else begin
                 if (lsbef) begin
                    
                    if (miso_receive_s_clk_rising) begin
                        receive_buffer_reg[count2] <= miso;
                        if(count2 == 3'd7)
                        count2 <= 3'd0;
                        else
                        count2 <= count2 + 3'b001;
                    end

                end
                else begin
                    if (miso_receive_s_clk_rising) begin
                        receive_buffer_reg[count3] <= miso;
                        if(count3 == 3'd0)
                        count3 <= 3'd7;
                        else
                        count3 <= count3 - 3'b001;
                    end
                end
            end
        end
        else if (!ss && spc0) begin
            if (bidiroe==0) begin
                if(cpol!=cpha)
              begin
                if (lsbef) begin
                    
                    if (miso_receive_s_clk_falling) begin
                        receive_buffer_reg[count2] <= mosi;
                        if(count2 == 3'd7)
                        count2 <= 3'd0;
                        else
                        count2 <= count2 + 3'b001;
                    end
                end
                else begin
                    if (miso_receive_s_clk_falling) begin
                        receive_buffer_reg[count3] <= mosi;
                        if(count3 == 3'd0)
                        count3 <= 3'd7;
                        else
                        count3 <= count3 - 3'b001;
                    end
                end
            end
            else begin
                 if (lsbef) begin
                    
                    if (miso_receive_s_clk_rising) begin
                        receive_buffer_reg[count2] <= mosi;
                        if(count2 == 3'd7)
                        count2 <= 3'd0;
                        else
                        count2 <= count2 + 3'b001;
                    end

                end
                else begin
                    if (miso_receive_s_clk_rising) begin
                        receive_buffer_reg[count3] <= mosi;
                        if(count3 == 3'd0)
                        count3 <= 3'd7;
                        else
                        count3 <= count3 - 3'b001;
                    end
                end
            end
                
        end
        
    end   
end


always@(posedge p_clk or negedge p_reset)begin
     if(!p_reset)begin
      count1<=8'd0;
      count0<=8'd7;
     end
     else begin 
         if(ss)
         begin
          count1<=8'd0;
          count0<=8'd7;
         end
         else if(!ss && !spc0) begin
             if(cpol^cpha)
              begin
                if (lsbef) begin
                    
                    if (mosi_send_s_clk_falling) begin
                        mosi <= send_buffer_reg[count1];
                        if(count1 == 3'd7)
                        count1 <= 3'd0;
                        else
                        count1 <= count1 + 3'b001;
                        end
                end
                else begin
                    if (mosi_send_s_clk_falling) begin
                     mosi <= send_buffer_reg[count0];

                     if(count0 == 3'd0)
                      count0 <= 3'd7;
                    else
                      count0 <= count0 - 3'b001;
                    end
                end
            end
            else begin
                 if (lsbef) begin
                    
                    if (mosi_send_s_clk_rising) begin
                     mosi <= send_buffer_reg[count1];

                        if(count1 == 3'd7)
                          count1 <= 3'd0;
                        else
                         count1 <= count1 + 3'b001;
                        end
                end
                else begin
                   if (mosi_send_s_clk_rising) begin

                  mosi <= send_buffer_reg[count0];

                    if(count0 == 3'd0)
                      count0 <= 3'd7;
                    else
                     count0 <= count0 - 3'b001;
                    end
                end
            end
         end
         else if (!ss && spc0) begin
            if (bidiroe==1) begin
               if(cpol^cpha)
              begin
                if (lsbef) begin
                    
                    if (mosi_send_s_clk_falling) begin
                        mosi <= send_buffer_reg[count1];
                        if(count1 == 3'd7)
                        count1 <= 3'd0;
                        else
                        count1 <= count1 + 3'b001;
                        end
                end
                else begin
                    if (mosi_send_s_clk_falling) begin
                     mosi <= send_buffer_reg[count0];

                     if(count0 == 3'd0)
                      count0 <= 3'd7;
                    else
                      count0 <= count0 - 3'b001;
                    end
                end
            end
            else begin
                 if (lsbef) begin
                    
                    if (mosi_send_s_clk_rising) begin
                     mosi <= send_buffer_reg[count1];

                        if(count1 == 3'd7)
                          count1 <= 3'd0;
                        else
                         count1 <= count1 + 3'b001;
                        end
                end
                else begin
                   if (mosi_send_s_clk_rising) begin

                  mosi <= send_buffer_reg[count0];

                    if(count0 == 3'd0)
                      count0 <= 3'd7;
                    else
                     count0 <= count0 - 3'b001;
                    end
                end
            end 
                
            end  
        end
     end
end

endmodule
