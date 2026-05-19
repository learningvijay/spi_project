`timescale 1ns/1ps
module spi_master_apb_slave_interface(
    input p_clk,p_reset,p_select,p_enable,p_write,
    input [2:0] p_addr,
    input [7:0] p_data_in,
    input ss,
    input receive_data,
    input [7:0]data_from_receive_buffer_reg,
    input tip,
    
    output  reg [7:0]p_data_out,
    output reg send_data,
    output wire p_ready,p_slverr,
    output spi_interrupt_request,
    output mstr,cpol,cpha,lsbfe,spiswai,
    output reg [7:0]data_to_send_buffer_reg,
    output [1:0]spi_mode,
    output [2:0]spr,sppr
);


reg [7:0]spicr1;
reg [7:0]spicr2;
reg [7:0]spibr;
reg [7:0]spisr;
reg [7:0]spidr;
wire write_en;
wire read_en;
wire spie;
wire spe;
wire sptie;
wire ssoe;
wire modfen;
wire bidiroe;
wire spco;

 localparam IDLE=2'b00;
 localparam SETUP=2'b01;
 localparam ACCESS=2'b10;
 reg [1:0]PRESENT_STATE;
 reg [1:0]NEXT_STATE;
 
localparam [1:0]spi_run=2'b00;
localparam [1:0]spi_wait=2'b01;
localparam [1:0]spi_stop=2'b10;

reg [1:0]present_mode;
reg [1:0]next_mode;

assign  spie = spicr1[7];
assign  spe = spicr1[6];
assign  sptie = spicr1[5];
assign mstr = spicr1[4];
assign cpol = spicr1[3];
assign cpha = spicr1[2];
assign  ssoe =spicr1[1];
assign lsbfe = spicr1[0];
assign  modfen =spicr2[4];
assign  bidiroe=spicr2[3];
assign spiswai = spicr2[1];
assign spco = spicr2[0];
assign spr = spibr[2:0];
assign sppr = spibr[6:4];

// acesssing registers
always @(posedge p_clk or negedge p_reset) begin
    if (!p_reset) begin
        spicr1<=8'b00000100;
        spicr2<=8'b00000000;
        spibr<=8'b00000000;
        spisr<=8'b00100000;
        spidr<=8'b00000000;
        send_data<=1'b0;
    end
    else if(write_en) begin
        case(p_addr) 
             3'b000:spicr1<=p_data_in;
             3'b001:spicr2<=(p_data_in & 8'b00011011);
             3'b010: spibr<=(p_data_in & 8'b01110111);
             3'b101:spidr<=p_data_in;
             default:spidr<=spidr;
        endcase
     end
            
   
    else if ((receive_data)&&((present_mode==spi_run)||(present_mode==spi_wait))) begin
        spidr<=data_from_receive_buffer_reg;
        send_data<=1'b0;
    end
    else if ((spidr==p_data_in)&&((present_mode==spi_run)||(present_mode==spi_wait))) begin
         send_data<=1'b1;
        data_to_send_buffer_reg<=spidr;
        spidr<=8'b00000000;
      end
 else
 begin
 send_data<=1'b0;
   end 

end    
//spidr !=data_to_send_buffer_reg
//read access
always@(*) begin
    if (read_en) begin
        case(p_addr)
  
            3'b000:p_data_out=spicr1;
            3'b001:p_data_out=spicr2;
            3'b010:p_data_out=spibr;
            3'b011:p_data_out=spisr;
            3'b101:p_data_out=spidr;
            default:p_data_out=8'b00000000;

        endcase

    end
    else begin
        p_data_out=8'b00000000;
    end
end

// apb interface fsm 


always@(posedge p_clk or negedge p_reset) begin
    if (!p_reset) begin
        PRESENT_STATE<=IDLE;
    end
    else begin
        PRESENT_STATE<=NEXT_STATE;
    end
end

always@(*) begin
    case (PRESENT_STATE)
    IDLE:if(!p_enable && p_select) begin
                NEXT_STATE=SETUP;
            end
            else begin
                NEXT_STATE=IDLE;
            end
    SETUP:if(p_enable && p_select) begin
                NEXT_STATE=ACCESS;
            end
            else if(!p_enable && !p_select) begin
                NEXT_STATE=IDLE;
            end
            else begin
                NEXT_STATE=SETUP;
            end
    ACCESS:if(!p_enable && !p_select) begin
               NEXT_STATE=IDLE;
            end
            else if(!p_enable && p_select) begin
            NEXT_STATE=SETUP;
            end
            else begin
            NEXT_STATE=ACCESS;
            end
         
    default:NEXT_STATE=IDLE;
    endcase
end

// spi mode fsm

always@(posedge p_clk or negedge p_reset) begin
    if (!p_reset) begin
        present_mode<=spi_run;
    end
    else begin
        present_mode<=next_mode;
    end
end

always@(*) begin
    case (present_mode)
  
        spi_run:if (!spe) begin
                   next_mode=spi_wait;
                end 
                else begin
                    next_mode=spi_run;
                end
        spi_wait:if (spe) begin
                    next_mode=spi_run;
                end
                else if(spiswai)begin
                    next_mode=spi_stop;
                end
                else begin
                    next_mode=spi_wait;
                end
        spi_stop:if (spe) begin
                    next_mode=spi_run;
                end
                else if(!spiswai) begin
                    next_mode=spi_wait;
                end
                else begin
                    next_mode=spi_stop;
                end
        default: next_mode=spi_run;

    endcase
end

assign spi_mode = present_mode;
assign read_en=((PRESENT_STATE==ACCESS)&&!p_write);
assign write_en=((PRESENT_STATE==ACCESS)&& p_write);
assign p_slverr=(PRESENT_STATE==ACCESS)?!tip:1'b0;
assign p_ready=(PRESENT_STATE==ACCESS)?1'b1:1'b0;

assign spi_interrupt_request = spie & (spisr[7] | spisr[6] | spisr[5]);

 endmodule
