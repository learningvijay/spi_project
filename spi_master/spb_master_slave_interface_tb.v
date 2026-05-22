module spb_master_apb_slave_interface_tb;

reg p_clk;
reg p_reset;
reg p_select;
reg p_enable;
reg p_write;

wire spi_interrupt_request;

reg [2:0] p_addr;
reg [7:0] p_data_in;

reg ss;
reg receive_data;
reg [7:0] data_from_receive_buffer_reg;
reg tip;
wire p_ready;
wire p_slverr;
wire [7:0] p_data_out;
wire send_data;

wire mstr;
wire cpol;
wire cpha;
wire lsbfe;
wire spiswai;

wire [7:0] data_to_send_buffer_reg;

wire [1:0]spi_mode;

wire [2:0] spr;
wire [2:0] sppr;

wire [7:0]spicr1;
wire [7:0]spicr2;
wire [7:0]spibr;
wire [7:0]spisr;
wire [7:0]spidr;


spb_master_apb_slave_interface dut (
    .p_clk(p_clk),
    .p_reset(p_reset),
    .p_select(p_select),
    .p_enable(p_enable),
    .p_write(p_write),
    .p_ready(p_ready),
    .p_slverr(p_slverr),
    .spi_interrupt_request(spi_interrupt_request),

    .p_addr(p_addr),
    .p_data_in(p_data_in),

    .ss(ss),
    .receive_data(receive_data),
    .data_from_receive_buffer_reg(data_from_receive_buffer_reg),
    .tip(tip),

    .p_data_out(p_data_out),
    .send_data(send_data),

    .mstr(mstr),
    .cpol(cpol),
    .cpha(cpha),
    .lsbfe(lsbfe),
    .spiswai(spiswai),

    .data_to_send_buffer_reg(data_to_send_buffer_reg),

    .spi_mode(spi_mode),

    .spr(spr),
    .sppr(sppr)
);

assign spidr=dut.spidr;
assign spicr1=dut.spicr1;
assign spicr2=dut.spicr2;
assign spibr=dut.spibr;
assign spisr=dut.spisr;


initial p_clk=1'b0;
always #20 p_clk=~p_clk;

task initialize;
begin
    p_reset = 1'b0;
    p_select = 1'b0;
    p_enable = 1'b0;
    p_write  = 1'b0;


    p_addr   = 3'b000;
    p_data_in = 8'h00;

    ss = 1'b1;
    receive_data = 1'b0;
    data_from_receive_buffer_reg = 8'h00;
    tip = 1'b0;

  repeat(2) @(posedge p_clk);
    p_reset = 1'b1;
      ss = 1'b0;
end
endtask

task idle_state;
begin
    p_select = 1'b0;
    p_enable = 1'b0;
    p_write  = 1'b0;

    p_addr   = 3'b000;
    p_data_in = 8'h00;

    receive_data = 1'b0;

    @(posedge p_clk);
end
endtask

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
    @(posedge p_clk);
end
endtask

task apb_access_phase;
begin
    p_select = 1'b1;
    p_enable = 1'b1;

    @(posedge p_clk);
    @(posedge p_clk);
    @(posedge p_clk);

    p_select = 1'b0;
    p_enable = 1'b0;
end
endtask

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

task apb_read(
    input [2:0] addr
);
begin

    apb_setup_phase(1'b0, addr, 8'h00);
    apb_access_phase;

    $display("READ  : ADDR = %0h DATA = %0h TIME = %0t",
              addr, p_data_out, $time);
end
endtask

initial
begin
    initialize;

    // Write operations
    apb_write(3'b000, 8'b01010001);
      apb_write(3'b101, 8'hFF);
      
       repeat(10) @(posedge p_clk);
       data_from_receive_buffer_reg=8'b01011011;
       receive_data=1'b1;
    apb_write(3'b001, 8'h00001001);
    apb_write(3'b010, 8'b00000001);
     apb_write(3'b101, 8'hFF);

    // Read operations
    apb_read(3'b000);
    apb_read(3'b001);
    apb_read(3'b010);

    #50;
    $finish;
end

endmodule
