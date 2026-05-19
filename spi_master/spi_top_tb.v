`timescale 1ns/1ps
module spi_top_tb;

//=====================================================
// APB SIGNALS
//=====================================================

reg         p_clk;
reg         p_reset;

reg         p_select;
reg         p_enable;
reg         p_write;

reg  [2:0] p_addr;
reg  [7:0] p_data_in;

wire [7:0] p_data_out;
wire       p_ready;
wire       p_slverr;

//=====================================================
// SPI SIGNALS
//=====================================================

wire ss;
wire s_clk;
wire mosi;

reg  miso;

wire spi_interrupt_request;
reg [7:0]spidr;
reg [7:0]receive_buffer_reg;
reg [7:0]data_from_receive_buffer_reg;
reg receive_data;
reg send_data;

//=====================================================
// DUT INSTANTIATION
//=====================================================

spi_top dut (

    .p_clk(p_clk),
    .p_reset(p_reset),

    .p_select(p_select),
    .p_enable(p_enable),
    .p_write(p_write),

    .p_addr(p_addr),
    .p_data_in(p_data_in),

    .p_data_out(p_data_out),

    .p_ready(p_ready),
    .p_slverr(p_slverr),

    .ss(ss),
    .s_clk(s_clk),
    .mosi(mosi),

    .miso(miso),

    .spi_interrupt_request(spi_interrupt_request)

);


always@(*)
begin 
spidr=dut.m4.spidr;
receive_buffer_reg=dut.m3.receive_buffer_reg;
data_from_receive_buffer_reg=dut.data_from_receive_buffer_reg;
receive_data=dut.receive_data;
send_data=dut.send_data;
end 


//=====================================================
// CLOCK GENERATION
//=====================================================


initial
begin
    p_clk = 1'b0;
end

always #20 p_clk = ~p_clk;


//=====================================================
// INITIALIZATION TASK
//=====================================================

task initialize;
begin

    p_reset  = 1'b0;

    p_select = 1'b0;
    p_enable = 1'b0;
    p_write  = 1'b0;

    p_addr   = 3'b000;
    p_data_in = 8'h00;

    miso = 1'b0;

    repeat(5) @(posedge p_clk);

    p_reset = 1'b1;

end
endtask


//=====================================================
// IDLE TASK
//=====================================================

task idle_state;
begin

    p_select = 1'b0;
    p_enable = 1'b0;
    p_write  = 1'b0;

    @(posedge p_clk);

end
endtask


//=====================================================
// APB SETUP PHASE
//=====================================================

task apb_setup_phase(

    input        write,
    input [2:0] addr,
    input [7:0] data

);

begin

    p_select  = 1'b1;
    p_enable  = 1'b0;

    p_write   = write;

    p_addr    = addr;
    p_data_in = data;

    @(posedge p_clk);

end
endtask


//=====================================================
// APB ACCESS PHASE
//=====================================================

task apb_access_phase;
begin

    p_select = 1'b1;
    p_enable = 1'b1;

    @(posedge p_clk);
    @(posedge p_clk);
 

      p_select = 1'b1;
    p_enable = 1'b0;

end
endtask


//=====================================================
// APB WRITE TASK
//=====================================================

task apb_write(

    input [2:0] addr,
    input [7:0] data

);

begin

  

    apb_setup_phase(1'b1, addr, data);

    apb_access_phase;

    $display("WRITE : ADDR = %0h DATA = %0h TIME = %0t",
              addr, data, $time);

end
endtask


//=====================================================
// APB READ TASK
//=====================================================

task apb_read(

    input [2:0] addr

);

begin



    apb_setup_phase(1'b0, addr, 8'h00);

    apb_access_phase;

    #1;

    $display("READ : ADDR = %0h DATA = %0h TIME = %0t",
              addr, p_data_out, $time);

end
endtask


//=====================================================
// SPI MISO DRIVER
//=====================================================

task spi_slave_send_byte(

    input [7:0] data

);

integer i;
wait(!ss)
begin

    for(i=7; i>=0; i=i-1)
    begin

        @(negedge s_clk);

        miso = data[i];

    end

end
endtask


//=====================================================
// TEST SEQUENCE
//=====================================================

initial
begin

    initialize;
   repeat(6) @(posedge p_clk);
   idle_state;
    //-------------------------------------------------
    // CONFIGURE SPI CONTROL REGISTERS
    //-------------------------------------------------

    // SPICR1
    // SPE=1
    // MSTR=1

    apb_write(3'b000, 8'b01010000);

    // SPICR2
    apb_write(3'b001, 8'b00000000);

    // SPIBR
    apb_write(3'b010, 8'b00010001);

    //-------------------------------------------------
    // WRITE DATA TO SPIDR
    //-------------------------------------------------

    apb_write(3'b101, 8'hA5);

    //-------------------------------------------------
    // SPI SLAVE RETURNS DATA
    //-------------------------------------------------

    fork

        spi_slave_send_byte(8'h3C);

    join
 repeat(10) @(posedge p_clk);
    //-------------------------------------------------
    // READ RECEIVED DATA
    //-------------------------------------------------

    apb_read(3'b101);

    //-------------------------------------------------
    // WAIT
    //-------------------------------------------------

    #500;

    $finish;

end

endmodule
